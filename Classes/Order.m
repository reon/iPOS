//
//  Order.m
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import "Order.h"
#import "OrderXmlMarshaller.h"
#import "iPOSFacade.h"

@implementation Order

@synthesize orderId, orderTypeId, salesPersonEmployeeId, store, customer, notes, purchaseOrderId, partialPaymentOnAccount;
@synthesize depositAuthorizationID, followUpdate,orderDCTO, promiseDate, requestDate, selectionId, taxExempt, isNewOrder, previousPayments;
#pragma mark Constructor/Deconstructor
-(id) init {
    self = [super init];
            
    if (self == nil) {
        return self;
        self.partialPaymentOnAccount = NO;
    }
    
    orderItemList = [[NSMutableArray arrayWithCapacity:0] retain];
    previousPayments = [[NSMutableArray arrayWithCapacity:0] retain];
    
    return self;
}

-(void) dealloc {
    [orderId release];
    [orderTypeId release];
    [salesPersonEmployeeId release];
    
    [store release];
    [customer release];
    
    [orderItemList release];
    
    [super dealloc];
}

#pragma mark -
#pragma Accessor Methods
- (void) setAsQuote {
    orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_QUOTE];
    
    // Open all order items
    if (orderItemList && [orderItemList count] > 0) {
        for (OrderItem *item in orderItemList) {
            [item setStatusToOpen];
        }
    }
}

- (NSNumber *) getOrderTypeId {
    // Determine if all items are closed or some are open.  Do this check for safety.
    if ([self isClosed]) {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_CLOSED]; 
    } else {
        self.orderTypeId = [NSNumber numberWithInt:ORDER_TYPE_OPEN];
    }
    
    return self.orderTypeId;
}

- (BOOL) isClosed {
    // Determine if all items are closed or some are open
    for (OrderItem *orderItem in orderItemList) {
        if (![orderItem isClosed]) {
            return NO;
        }
    }
    
    return YES;
}

- (BOOL) canViewDetails {
    return ([self.orderTypeId intValue] != ORDER_TYPE_CANCELLED);
}

- (BOOL) canEditDetails {
    if ([self.orderTypeId intValue] == ORDER_TYPE_CLOSED || [self.orderTypeId intValue] == ORDER_TYPE_RETURNED) {
        return NO;
    }
    return YES;
}

- (BOOL) canCancel {
    // Can only cancel an order if it is in quote or open status and all items in it are in open status
    if ([self.orderTypeId intValue] == ORDER_TYPE_OPEN || [self.orderTypeId intValue] == ORDER_TYPE_QUOTE) {
        for (OrderItem *orderItem in orderItemList) {
            if ([orderItem isOpen] == NO) {
                return NO;
            }
        }
        return YES;
    }
    return NO;
}

#pragma mark -
#pragma mark Marshalling
+ (Order *) fromXml:(NSString *)xmlString {
    OrderXmlMarshaller *marshaller = [[[OrderXmlMarshaller alloc] init] autorelease];
    return (Order *) [marshaller toObject:xmlString];
}

- (NSString *) toXml {
    OrderXmlMarshaller *marshaller = [[[OrderXmlMarshaller alloc] init] autorelease];
    return [marshaller toXml:self];
}

#pragma mark -
#pragma mark Validation methods
- (BOOL) validateAsNew {
    if (self.orderId != nil) {
        // Attach an error
        Error *error = [[[Error alloc] init] autorelease];
        
        error.message = [NSString stringWithFormat:@"Order is seems to have been alread created with id '%@'.", self.orderId];
        error.reference = self;
        
        [self addError:error];
        return NO;
    } 
    
    return YES;        
}

- (BOOL) validateAsNewQuote {
    [self validateAsNew];
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

- (BOOL) validateAsNewOrder {
    [self validateAsNew];
    
    if ([self.errorList count] > 0) {
        return NO;
    }
    
    return YES;
}

#pragma mark -
-(NSArray *) getOrderItems {
    return orderItemList;
}

-(void) addItemToOrder:(ProductItem *)item withQuantity: (NSDecimalNumber *) quantity {
    
    if (orderItemList != nil) {
        // We can add multiple items of the same type to an order
        OrderItem *orderItem = [[[OrderItem alloc] initWithItem:item AndQuantity:quantity] autorelease];
        
        [orderItemList addObject:orderItem];

        // Set the line number based on the index the item was added in
        orderItem.lineNumber = [NSNumber numberWithInt: [orderItemList count]];
        
        // Set the selling price to the retail price
        // Default the status to 1 (Open)
        [orderItem setStatusToOpen];
        
        // Set the order item to be a newly added
        orderItem.isNewLineItem = YES;
    }
}

- (void) addOrderItemToOrder:(OrderItem *)orderItem {
    
    [orderItemList addObject:orderItem];
}

-(void) removeItemFromOrder:(OrderItem *)item {
    if (orderItemList != nil) {
        
        // Remove the instance of order item
        for (OrderItem *orderItem in orderItemList) {
            if (orderItem == item) {
                [orderItemList removeObject:orderItem];
                break;
            }
        }   
        
        // Adjust the line number for the remaining order items (Start at 1)
        int index = 1;
        for (OrderItem *orderItem in orderItemList) {
            orderItem.lineNumber = [NSNumber numberWithInt:index++];
        }
    }
    
}

-(void) removeAll {
    if (orderItemList != nil) {
        [orderItemList removeAllObjects];
    }
}

- (void) mergeWith:(Order *) mergeOrder {
    // If there are errors just merge the errors, otherwise merge everything else
    if (mergeOrder.errorList && [mergeOrder.errorList count] > 0) {
        self.errorList = [NSArray arrayWithArray: mergeOrder.errorList];
        return;
    }

    if (mergeOrder.orderId && ![mergeOrder.orderId isEqualToNumber:[NSNumber numberWithInt:0]]) {
        self.orderId = mergeOrder.orderId;
    }
}

#pragma mark -
#pragma mark Order Calculations
- (NSDecimalNumber *) calcOrderRetailSubTotal {
    NSDecimalNumber *retailTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        retailTotal = [[item calcLineRetailSubTotal] decimalNumberByAdding:retailTotal];
    }
    
    return retailTotal;
}

- (NSDecimalNumber *) calcOrderSubTotal {
    NSDecimalNumber *subTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        subTotal = [[item calcLineSubTotal] decimalNumberByAdding:subTotal];
    }
    
    return subTotal;
}

- (NSDecimalNumber *) calcOrderTax {
    BOOL custTaxExempt = NO;
	
	// If the customer is not set yet, we will assume that they are not tax exempt
	if (customer != nil && [customer taxExempt] == YES) {
		custTaxExempt = YES;
	}
	
	NSDecimalNumber *taxTotal = [NSDecimalNumber zero];
    for (OrderItem *item in orderItemList) {
        // If the customer is tax exempt we won't bother with checking further or calculating the tax amount for the line item
        // If the customer is not tax exempt we also need to see if the line item itself is tax exempt or not.
        // Possible concern:  We are allocating a lot of autoreleased NSDecimalNumber objects here.  Performance issue?
        if (custTaxExempt == NO && ![item isTaxExempt]) {
            taxTotal = [[item calcLineTax] decimalNumberByAdding:taxTotal];
        }
    }
    
    return taxTotal;        
}

- (NSDecimalNumber *) calcOrderDiscountTotal {
    NSDecimalNumber *discountTotal = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        discountTotal = [[item calcLineDiscount] decimalNumberByAdding:discountTotal];
    }
    
    return discountTotal;
}

- (NSDecimalNumber *) calcBalanceDue {
    
    NSDecimalNumber *balanceDue = [NSDecimalNumber zero];
    if (customer) {
        NSDecimalNumber *balanceClosedItems = [self calcClosedItemsBalance];
        
        if ([customer isRetailCustomer]) {
            // Retail customers pay 50% of total balance or total of all closed items (whichever is greater)
            NSDecimalNumber *balance50Percent = [[[self calcOrderSubTotal] 
                                                  decimalNumberByAdding:[self calcOrderTax]] 
                                                  decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString: @"0.5"]];
            if ([balanceClosedItems compare:balance50Percent] == NSOrderedDescending) {
                balanceDue = [balanceDue decimalNumberByAdding:balanceClosedItems];
            } else {
                balanceDue = [balanceDue decimalNumberByAdding:balance50Percent];
            }

                                                  
        } else {
            // Assume the customer is a Contractor and only pays for closed items
            
                balanceDue = [balanceDue decimalNumberByAdding:balanceClosedItems];
                
                if (partialPaymentOnAccount && [customer isPaymentOnAccountEligable])
                {
                    //If there was payment on the account, set the balance due as the payment on account - balanceDue
                    balanceDue = [balanceDue decimalNumberBySubtracting:customer.amountAppliedOnAccount];
                }
        }
    }
    
    return balanceDue;
}

/* Calculates the profit margin for a given order 
 For display use banker rounding - look at cart display for example*/
-(NSDecimalNumber *) calculateProfitMargin {
    NSDecimalNumber *totalExtendedCost = [NSDecimalNumber zero];
    NSDecimalNumber *totalExtendedPrice = [NSDecimalNumber zero];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:0 
                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    
    for (OrderItem *item in orderItemList)
    {
        totalExtendedCost = [totalExtendedCost decimalNumberByAdding:item.calculateExtendedCost];
        totalExtendedPrice = [totalExtendedPrice decimalNumberByAdding:item.calculateExtendedPrice];
    }
    
    
    NSDecimalNumber *costTimesPrice = [totalExtendedCost decimalNumberByDividingBy: totalExtendedPrice];
    
    NSDecimalNumber *oneMinusCostPrice = [[NSDecimalNumber one] decimalNumberBySubtracting: costTimesPrice  ];
        
    NSDecimalNumber *tempMargin = [oneMinusCostPrice decimalNumberByMultiplyingBy: 
                                   [NSDecimalNumber decimalNumberWithString:@"100.0"] withBehavior: roundUp];
    
    NSDecimalNumber *pointFive = [NSDecimalNumber decimalNumberWithString:@"0.05"];
    NSDecimalNumber *profitMargin = [tempMargin decimalNumberBySubtracting: [tempMargin decimalNumberByMultiplyingBy: pointFive]];
    
    return profitMargin;
}

- (NSDecimalNumber *) calcClosedItemsBalance {
    NSDecimalNumber *balance = [NSDecimalNumber zero];
    
    for (OrderItem *item in orderItemList) {
        if ([item isClosed]) {
            // Fixed to ensure balance is accumulative [Defect:  2011-06-01]
            balance = [balance decimalNumberByAdding:[[item calcLineSubTotal] decimalNumberByAdding: [item calcLineTax]]];
        }
    }
    
    return balance;
        
}

#pragma mark -
#pragma mark Refund methods

-(TenderDecision) isRefundEligble{
    
    if (!previousPayments)
    {
        previousPayments = (NSMutableArray *)[[iPOSFacade sharedInstance] getPaymentHistoryForOrderid:self.orderId];
    }
    
    NSDecimalNumber *previousBalancePaid = [NSDecimalNumber zero];
    NSDecimalNumberHandler *roundUp = [NSDecimalNumberHandler decimalNumberHandlerWithRoundingMode:NSRoundUp scale:2 
                                                                                  raiseOnExactness:NO raiseOnOverflow:NO 
                                                                                  raiseOnUnderflow:NO raiseOnDivideByZero:NO];

    for(Payment *currentPayment in previousPayments)
    {
        previousBalancePaid = [previousBalancePaid decimalNumberByAdding:currentPayment.paymentAmount];
    }
    
    NSDecimalNumber *currentBalanceDue = [[self calcBalanceDue]  decimalNumberByRoundingAccordingToBehavior:roundUp];
  
    NSComparisonResult comparisonresult = [previousBalancePaid compare:currentBalanceDue];
    
    if (comparisonresult == NSOrderedSame)
    {
        return NOCHANGE;
    }
    else if (comparisonresult == NSOrderedAscending)
    {
        return TENDER;
    }
    else
    {
        return REFUND;
    }
}

@end
