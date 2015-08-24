//
//  YTNetworkLoad.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^progressBlock)(float progress);

@interface YTNetworkLoad : NSOperation

@property (nonatomic, copy) progressBlock updataBlock;

- (instancetype)initWithUrl:(NSURL*)url success:(void (^)(id data))success failure:(void (^)(NSError * error))failure;

- (void)cancel;

@end
