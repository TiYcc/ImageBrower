//
//  YTPhotoView.h
//  YTPhotoBrowser
//
//  Created by TI on 2018/3/27.
//  Copyright © 2018年 ytclear. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTPhotoInfo.h"

// 滑动回调，界面透明消失
typedef void (^currentScaleBlock)(float scale, BOOL stopped);

@interface YTPhotoView : UIView

// 图片信息
@property (nonatomic, strong) YTPhotoInfo *photoInfo;

// 图片与图片之间的间距
@property (nonatomic, assign) CGFloat photoSpace;

// 菊花颜色
@property (nonatomic, strong) UIColor *loopColor;

// 图片放大最大倍数值
@property (nonatomic, assign) CGFloat maxZoomScale;

// 图片缩小最小倍数值
@property (nonatomic, assign) CGFloat minZoomScale;

// 回调 block
@property (nonatomic, copy) currentScaleBlock readScaleBlock;

// 图片根据屏幕宽高适配过后的size
@property (nonatomic, assign, readonly) CGSize imageFitSize;

// 缩放比例
@property (nonatomic, assign, readonly) CGFloat scale;

// 当图片当前放大倍数小于maxZoomScale时,放大到maxZoomScale,反之缩小到minZoomScale
- (void)shortcutZoomAnimated:(BOOL)animated;

// 图片请求放大倍数
- (void)shortcutZoomScale:(CGFloat)scale andAnimated:(BOOL)animated;

// 屏幕旋转
- (void)transition;
@end
