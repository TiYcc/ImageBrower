/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : YTPhotoSave.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/13
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <Foundation/Foundation.h>

@interface YTPhotoSave : NSObject

/** 判断相册是否被允许访问 允许:YES */
+ (BOOL)userAuthorizationPhotoStatus;

// 保存图片
// imgInfo 为NSString或者UIImage对象
+ (void)saveImage:(NSObject *)imgInfo;

@end
