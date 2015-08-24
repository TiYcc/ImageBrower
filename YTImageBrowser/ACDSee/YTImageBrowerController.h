//
//  YTImageBrowerController.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YTImageBrowerControllerDelegate <NSObject>

@optional

/*
 ** img   图片
 ** index 第几张图片 为0时是第一张
 ** size  图片大小
 */

- (void)ACDSeeControllerInitEnd:(CGSize)size;

- (void)ACDSeeControllerWillDismiss:(CGSize)size Img:(UIImage*)img Index:(NSInteger)index;

@end

@interface YTImageBrowerController : UIViewController

/*
 ** targart 代理,可为nil
 ** img_s 默认显示图片组,可为nil
 ** url_s 网络加载图片地址,可为nil
 ** index 开始图片位置 为0时是第一张
 */
- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate Imgs:(NSArray*)imgs Urls:(NSArray*)urls PageIndex:(NSInteger)index;

/*
 ** targart 代理,可为nil
 ** imgModels 参考 "YTImageModel.h"
 ** index 开始图片位置 为0时是第一张
 */
- (instancetype)initWithDelegate:(id<YTImageBrowerControllerDelegate>)delegate ImgModels:(NSArray*)imgModels PageIndex:(NSInteger)index;

@end
