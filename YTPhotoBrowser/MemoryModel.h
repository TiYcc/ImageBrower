/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : MemoryModel.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/20
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <Foundation/Foundation.h>
@class UIImage,MemoryModel;

typedef void (^imageFinish)(MemoryModel *mm);

@interface MemoryModel : NSObject
@property (nonatomic, strong) NSString *imagePath;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign, getter=isGif) BOOL gif;
@property (nonatomic, copy) imageFinish imageFinishBlock;

- (void)useThreadLoadGifImageData:(void(^)(NSData *imgData))threadImageData;
@end
