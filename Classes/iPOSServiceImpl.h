//
//  POSServiceImpl.h
//  iPOS
//
//  Created by Torey Lomenda on 2/2/11.
//  Copyright 2011 Object Partners Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "iPOSService.h"

@interface iPOSServiceImpl : NSObject <iPOSService> {
    NSString *baseUrl;
    NSString *posSessionMgmtUri;
}

@property(nonatomic,retain) NSString *baseUrl;
@property(nonatomic, retain) NSString *posSessionMgmtUri;

-(void) setToDemoMode;
-(void) setToReleaseMode;

@end
