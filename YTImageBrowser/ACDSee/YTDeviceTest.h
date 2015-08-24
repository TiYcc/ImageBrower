//
//  YTDeviceTest.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YTDeviceTest : NSObject

/**判断相册是否被允许访问 返回YES为允许访问*/
+ (BOOL)userAuthorizationStatus;

@end
