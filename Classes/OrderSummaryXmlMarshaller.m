//
//  OrderSummaryXmlMarshaller.m
//  iPOS
//
//  Created by Dan C on 9/27/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "OrderSummaryXmlMarshaller.h"

#import "PreviousOrder.h"

@implementation OrderSummaryXmlMarshaller

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

-(id) toObject:(NSString *)xmlString {
    
    CXMLDocument *xmlParser = [[[CXMLDocument alloc] initWithXMLString:xmlString options:0 error:nil] autorelease];
    CXMLElement *root = [xmlParser rootElement];
    NSMutableArray *itemList = [NSMutableArray arrayWithCapacity:0];
    PreviousOrder *order = nil;
    
     for (CXMLElement *node in [root elementsForName:@"OrderList"]) {
         
         order = [[PreviousOrder alloc] init];
         
         order.orderDate = [node elementStringValue:@"OrderDate"];
         order.orderId = [node elementNumberValue:@"OrderID"];
         order.orderTotal =[node elementDecimalValue:@"OrderTotal"];
         order.orderType = [node elementStringValue:@"OrderType"];
         order.orderTypeId = [node elementNumberValue:@"OrderTypeID"];
         order.purchaseOrderNum = [node elementStringValue:@"PO"];
         [itemList addObject:order];
         
         [order release];
         order = nil;
     }
    
    return [NSArray arrayWithArray: itemList];
    
}

- (NSString *) toXml: (id) marshalObj {
    return nil;
}

@end
