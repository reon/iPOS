//
//  PaymentServiceTestCase.m
//  iPOS
//
//  Created by Torey Lomenda on 4/14/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//
#import <SenTestingKit/SenTestingKit.h>

#import "iPOSFacade.h"
#import "CreditCardPayment.h"

@interface PaymentServiceTestCase : SenTestCase

- (void) testPosCCPaymentAndSignature;
-(void) testRefundService;

@end

@implementation PaymentServiceTestCase

- (void) testPosCCPaymentAndSignature {
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    Order *orderForPayment = nil;
    Store *store = nil;
    Customer *customer = nil;
    CreditCardPayment *ccPayment = nil;
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.paymentService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    // Test the cc payment
    orderForPayment = [[[Order alloc] init] autorelease];
    orderForPayment.orderId = [NSNumber numberWithInt:1414];
    customer = [[[Customer alloc] init] autorelease];
    customer.customerId = [NSNumber numberWithInt:1414];
    orderForPayment.customer = customer;
    store = [[[Store alloc] init] autorelease];
    store.storeId = [NSNumber numberWithInt:1414];
    orderForPayment.store = store;
    orderForPayment.salesPersonEmployeeId = [NSNumber numberWithInt:1414];
     
    ccPayment = [[[CreditCardPayment alloc] initWithOrder:orderForPayment] autorelease];
    ccPayment.paymentAmount = [NSDecimalNumber decimalNumberWithString:@"23.14"];
    ccPayment.nameOnCard = @"Torey Lomenda";
    ccPayment.expireDate = @"0212";
    ccPayment.cardNumber = @"4323710232259925";
    [facade tenderPaymentWithCC:ccPayment];
    STAssertTrue([ccPayment.errorList count] == 0, ((Error *) [ccPayment.errorList objectAtIndex:0]).message);
    
    // Test the signature
    [ccPayment attachSignature:@""
        "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"
        "MhIEwUIOB/wL9eD3zEFjnpQAAAABJRU5ErkJggg=="];
    BOOL acceptedSignature = [facade acceptSignatureFor:ccPayment];
    STAssertTrue(acceptedSignature, @"Expected the signature to be accepted");
}

-(void) testRefundService{
    
    iPOSFacade *facade = [iPOSFacade sharedInstance];
    
    Refund *refund = [[Refund alloc] init];
    refund.orderId = [NSNumber numberWithInt:1];
    refund.customerId = [NSNumber numberWithInt:2];
    refund.storeId = [NSNumber numberWithInt:1200];
    refund.salesPersonId = [NSNumber numberWithInt:20];
    refund.refundDate = @"2011-07-02T00:00:00";
    
    RefundItem *item = [[RefundItem alloc] init];
    item.amount = [NSDecimalNumber decimalNumberWithString:@"6.00"];
    item.orderPaymentTypeID = [NSNumber numberWithInt:1];
    
    [refund addRefundItem:item];
    
    // We are setting to demo mode
    [((iPOSServiceImpl *) facade.posService) setToDemoMode];
    [((iPOSServiceImpl *) facade.paymentService) setToDemoMode];
    
    BOOL loginResult = [facade login:@"123" password:@"456"];
    STAssertTrue(loginResult, @"I expected the login result to be true :-(");
    
    [facade sendRefundRequest:refund];
    
}

@end
