/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : YTPhotoBrowseSeting.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/19
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <UIKit/UIKit.h>

@interface YTPhotoBrowseSeting : NSObject

/** 各个属性默认值参考 YTPhotoBrowseSet.m - init */

// 是否开启保存按钮
@property (nonatomic, assign, getter=isOpenSave) BOOL openSave;

// 保存按钮tilte 当saveIcon有值时忽略saveTitle
@property (nonatomic, strong) NSString *saveTitle;

// 保存按钮图标
@property (nonatomic, strong) UIImage *saveIcon;

// 图片与图片之间的间距
@property (nonatomic, assign) CGFloat photosSpace;

// 图片是否支持缩放
@property (nonatomic, assign, getter=isZoomEnable) BOOL zoomEnable;

// 图片最大放大倍数 zoomEnablew = YES 生效
@property (nonatomic, assign) CGFloat maxImageScale;

// 图片最小放大倍数 zoomEnablew = YES 生效
@property (nonatomic, assign) CGFloat minImageScale;

// 图片是否能够移动 zoomEnablew = YES 生效
@property (nonatomic, assign, getter=isMoveEnable) BOOL moveEnable;

// 浏览器背景颜色
@property (nonatomic, strong) UIColor *backGroundColor;

// 加载图片时，UIActivityIndicatorView 圈圈颜色
@property (nonatomic, strong) UIColor *loadColor;

// 底部页数和保存按钮文字颜色
@property (nonatomic, strong) UIColor *textColor;

// 底部页数和保存按钮字体大小
@property (nonatomic, strong) UIFont *textFont;

@end
