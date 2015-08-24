//
//  YTDeviceTest.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTDeviceTest.h"
@import AssetsLibrary;
@import UIKit;

@implementation YTDeviceTest

+ (BOOL)userAuthorizationStatus{
    ALAuthorizationStatus statu =  [ALAssetsLibrary authorizationStatus];
    switch (statu) {
        case ALAuthorizationStatusAuthorized:
        case ALAuthorizationStatusDenied:
            return YES;
        default:
        {
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"无法访问相册" message:@"请在iPhone的“设置-隐私-照片”中允许访问您的照片" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
            return NO;
        }
    }
}

@end
