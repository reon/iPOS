//
//  CustomerListViewController.h
//  iPOS
//
//  Created by Torey Lomenda on 10/31/11.
//  Copyright (c) 2011 Object Partners Inc. All rights reserved.
//


#import "iPOSFacade.h"

@interface SSCustomerListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    iPOSFacade *facade;
    
    UITableView *customerListTableView;
    UIBarButtonItem *closeBarButton;
    
    NSString *searchString;
    
    NSArray *customerList;
    
    BOOL doGetOrdersOnSelection;
}

@property (nonatomic, retain) NSArray *customerList;
@property (nonatomic, retain) NSString *searchString;
@property (nonatomic, assign, getter=isDoGetOrdersOnSelection) BOOL doGetOrdersOnSelection;
@property (nonatomic, assign) BOOL contractor;


@end
