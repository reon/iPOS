//
//  OrderItem.h
//  iPOS
//
//  Created by Torey Lomenda on 2/4/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ManagerInfo.h"
#import "ProductItem.h"

@interface OrderItem : NSObject {
    NSNumber *lineNumber;
    NSNumber *statusId;
    
    NSNumber *priceAuthorizationId;
    
    NSDecimalNumber *sellingPricePrimary;
    NSDecimalNumber *sellingPriceSecondary;
    
    NSDecimalNumber *quantityPrimary;
    NSDecimalNumber *quantitySecondary;
    
    ManagerInfo *managerApprover;
    ProductItem *item;
	
    // This boolean controls whether conversion converts to pieces or full boxes
    BOOL doConversionToFullBoxes;
    
	// These are for batch editing of the order.
	BOOL shouldDelete;
	BOOL shouldClose;
}

@property (nonatomic, retain) NSNumber *lineNumber;
@property (nonatomic, retain) NSNumber *statusId;
@property (nonatomic, retain) NSNumber *priceAuthorizationId;

@property (nonatomic, retain) NSDecimalNumber *sellingPricePrimary;
@property (nonatomic, retain) NSDecimalNumber *sellingPriceSecondary;
@property (nonatomic, retain) NSDecimalNumber *quantityPrimary;
@property (nonatomic, retain) NSDecimalNumber *quantitySecondary;

@property (nonatomic, retain) ManagerInfo *managerApprover;
@property (nonatomic, retain) ProductItem *item;

@property (nonatomic, assign) BOOL doConversionToFullBoxes;
@property (nonatomic, assign) BOOL shouldDelete;
@property (nonatomic, assign) BOOL shouldClose;

-(id) initWithItem: (ProductItem *) productItem AndQuantity: (NSDecimalNumber *) productQuantity;

- (void) setStatusToClosed;
- (void) setStatusToOpen;

- (BOOL) isTaxExempt;
- (BOOL) isClosed;
- (BOOL) allowClose;

#pragma mark -
#pragma mark Custom Accessors
- (BOOL) isConversionNeeded;
- (NSNumber *) getPiecesPerBox;
- (void) setQuantity: (NSDecimalNumber *) newQuantity;
- (void) setSellingPriceFrom: (NSDecimalNumber *) discount;

#pragma mark -
#pragma mark Order Item Calculations
- (NSDecimalNumber *) calcSellingPricePrimaryFrom: (NSDecimalNumber *) discount;
- (NSDecimalNumber *) calcSellingPriceSecondaryFrom: (NSDecimalNumber *) discount;
- (NSDecimalNumber *) calcLineRetailSubTotal;
- (NSDecimalNumber *) calcLineSubTotal;
- (NSDecimalNumber *) calcLineTax;
- (NSDecimalNumber *) calcLineDiscount;

#pragma mark -
#pragma mark UOM Switching support
- (void) toggleUOM;
- (NSString *) getUOMForDisplay;
- (NSString *) getQuantityForDisplay;
- (NSString *) getSellingPriceForDisplay;

@end
