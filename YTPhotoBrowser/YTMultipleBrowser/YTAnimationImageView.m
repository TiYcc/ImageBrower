/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : YTAnimationImageView.m
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/19
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "YTAnimationImageView.h"

@interface YTAnimationImageView(){
    CGImageSourceRef sourceRef;
    NSTimeInterval sourceTime;
}
@property (nonatomic, strong) NSTimer *animationTime;
@property (nonatomic, assign) NSInteger animationTag;
@property (nonatomic, assign) NSInteger imageCount;
@end

@implementation YTAnimationImageView

#pragma mark - public method
- (void)setGifImageData:(NSData *)imageData{
    if (!imageData) return;
    sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)imageData, NULL);
    self.imageCount = CGImageSourceGetCount(sourceRef);
    
    // 这样写可能会有些小问题 完全为了性能和逻辑简化
    sourceTime = durationWithSourceAtIndex(sourceRef, MIN(_imageCount, 1));
    
    [self startAnimating];
}

- (void)timeInvalidate{
    if (self.animationTime) [self.animationTime invalidate];
    if (sourceRef) CFRelease(sourceRef);
    
    self.animationTime = nil;
    self.animationTag = 0;
    self.imageCount = 0;
    sourceRef = nil;
    sourceTime = 0.;
}

- (void)setImage:(UIImage *)image{
    [self timeInvalidate];
    
    if (image.images){
        // 防止对image.images +1强引用
        NSData *imageData = UIImagePNGRepresentation(image.images.firstObject);
        image = [UIImage imageWithData:imageData];
    }
    
    [super setImage:image];
}

- (void)startAnimating{
    [self.animationTime invalidate];
    if (sourceTime <= 0) return;
    
    self.animationTime = [NSTimer timerWithTimeInterval:sourceTime target:self selector:@selector(imagesAnimation) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop]addTimer:self.animationTime forMode:NSRunLoopCommonModes];
}

#pragma mark - private method
- (void)imagesAnimation{
    if (_animationTag == (self.imageCount-1)) _animationTag = 0;
    else _animationTag++;
    
    UIImage *image = [self imageWithSource];
    if (image) [super setImage:image];
}

- (UIImage *)imageWithSource{
    if (sourceRef&&_animationTime) {
        CGImageRef cgImg = CGImageSourceCreateImageAtIndex(sourceRef, self.animationTag, NULL);
        UIImage *image = [UIImage imageWithCGImage:cgImg];
        CGImageRelease(cgImg);
        return image;
    }
    
    [self timeInvalidate];
    return nil;
}

float durationWithSourceAtIndex(CGImageSourceRef source, NSUInteger index) {
    float duration = 0.1f;
    //获取当前帧的属性字典--c类型
    CFDictionaryRef propertiesRef = CGImageSourceCopyPropertiesAtIndex(source, index, nil);
    //强转为oc对象
    NSDictionary *properties = (__bridge NSDictionary *)propertiesRef;
    //获取当前帧的gif属性
    NSDictionary *gifProperties = properties[(NSString *)kCGImagePropertyGIFDictionary];
    //获取当前帧的持续时间
    NSNumber *delayTime = gifProperties[(NSString *)kCGImagePropertyGIFUnclampedDelayTime];
    
    if (delayTime) duration = delayTime.floatValue;
    else {
        delayTime = gifProperties[(NSString *)kCGImagePropertyGIFDelayTime];
        if (delayTime) duration = delayTime.floatValue;
    }
    //释放
    CFRelease(propertiesRef);
    
    if (duration == 0) duration = 0.1;
    
    return duration;
}

@end
