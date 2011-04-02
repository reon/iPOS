//
//  UIViewController+ViewControllerLayout.h
//  iPOS
//
//  Created by Steven McCoole on 3/7/11.
//  Copyright 2011 NA. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIViewController (ViewControllerLayout)

- (CGFloat) navBarHeight;
- (CGFloat) tabBarHeight;
- (CGRect) rectForNav;
- (CGRect) rectForTab;
- (CGRect) rectForNavAndTab;

@end