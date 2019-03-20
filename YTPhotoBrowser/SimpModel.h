/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : SimpModel.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/13
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <Foundation/Foundation.h>
@class UIImage;

@interface SimpModel : NSObject
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) NSInteger type;
@end
