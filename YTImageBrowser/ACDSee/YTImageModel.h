//
//  YTImageModel.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface YTImageModel : NSObject

/** image, url 有可能为空 引用时要判断 */
@property (nonatomic, strong) UIImage * image; //图片
@property (nonatomic, strong) NSURL * url;     //图片地址
@property (nonatomic, assign) NSInteger index; //位置索引
@property (nonatomic, assign) CGSize size;     //图片适配后大小
@property (nonatomic, assign, getter=ishttp) BOOL http; //网络请求成功与否

+ (NSArray*)IMGMessagesWithImgs:(NSArray*)imgs Urls:(NSArray*)urls;

@end
