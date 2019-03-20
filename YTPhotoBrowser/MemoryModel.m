/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : MemoryModel.m
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/20
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "MemoryModel.h"
#import "SDWebImageManager.h"

@implementation MemoryModel

- (void)setImagePath:(NSString *)imagePath{
    _imagePath = imagePath;
    NSURL *url = [NSURL URLWithString:imagePath];
    SDWebImageManager *manger = [SDWebImageManager sharedManager];
    manger.imageCache.shouldCacheImagesInMemory = NO;
    SDWebImageOptions options = SDWebImageRefreshCached;
    
    __weak __typeof (self)weakSelf = self;
    [manger downloadImageWithURL:url options:options progress:nil completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        if (image) [strongSelf neatImage:image];
    }];
}

- (void)neatImage:(UIImage *)image{
    if (image.images) {
        // 延迟处理gif图片是为了防止SDImageCache写入硬盘不及时。
        NSData *imageData = UIImagePNGRepresentation(image.images.firstObject);
        [self performSelector:@selector(delayDealGifImage:) withObject:imageData afterDelay:0.25];
    }else {
        self.image = image;
        if (self.imageFinishBlock) {
            self.imageFinishBlock(self);
        }
    }
}

- (void)delayDealGifImage:(NSData *)imageData{
    self.gif = YES;
    self.image = [UIImage imageWithData:imageData];
    if (self.imageFinishBlock) {
        self.imageFinishBlock(self);
    }
}

- (void)useThreadLoadGifImageData:(void (^)(NSData *))threadImageData{
    NSString *pathFile = [[SDImageCache sharedImageCache] defaultCachePathForKey:self.imagePath];
    NSData *imgData = [NSData dataWithContentsOfFile:pathFile];
    dispatch_async(dispatch_get_main_queue(), ^{
        if (threadImageData) threadImageData(imgData);
    });
}

@end
