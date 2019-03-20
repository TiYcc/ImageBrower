/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : YTAnimationImageView.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/19
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <UIKit/UIKit.h>

@interface YTAnimationImageView : UIImageView

// 获取动画图片 data
- (void)setGifImageData:(NSData *)imageData;

// 释放动画
- (void)timeInvalidate;

@end
