//
//  YTPhotoInfo.m
//  YTPhotoBrowser
//
//  Created by TI on 2018/3/27.
//  Copyright © 2018年 ytclear. All rights reserved.
//

#import "SDWebImageManager.h"
#import "UIImage+GIF.h"
#import "YTPhotoInfo.h"

@interface YTPhotoInfo()
@property (nonatomic, assign) NSInteger observerCount;
@end

@implementation YTPhotoInfo

- (instancetype)initWithObj:(id)obj andSourceType:(YTPhotoSourceType)sourceType{
    if (self = [super init]) {
        _sourceType = sourceType;
        _loadProgress = 0.f;
        _observerCount = 0;
    }
    return self;
}

+ (YTPhotoInfo *)photoInfoWithSourceType:(YTPhotoSourceType)sourceType{
    return [YTPhotoInfo photoInfoWithObj:nil andSourceType:sourceType];
}

+ (YTPhotoInfo *)photoInfoWithObj:(id)obj andSourceType:(YTPhotoSourceType)sourceType{
    return [[YTPhotoInfo alloc]initWithObj:obj andSourceType:sourceType];
}

- (void)setImagePath:(NSString *)imagePath{
    if (!imagePath) return;
    
    _imagePath = imagePath;
    switch (_sourceType) {
        case YTPhotoSourceTypeLocal:{
            [self local:imagePath];
        }break;
            
        case YTPhotoSourceTypeNetWork:
        {
            [self netWork:[NSURL URLWithString:imagePath]];
        }break;
            
        case YTPhotoSourceTypePHKit:
        {
            
        }break;
            
        default:
            break;
    }
}

#pragma mark - 加载image数据源
- (void)local:(NSString *)imageName{
    UIImage *image = [UIImage sd_animatedGIFNamed:imageName];
    if (image.images) {
        self.gif = YES;
        self.image = [image.images.firstObject copy];
    }else self.image = image;
}

- (void)netWork:(NSURL *)url{
    
    SDWebImageManager *manger = [SDWebImageManager sharedManager];
    manger.imageCache.shouldCacheImagesInMemory = NO;
    SDWebImageOptions options = SDWebImageRefreshCached|SDWebImageProgressiveDownload|SDWebImageHighPriority;
    
    __weak __typeof (self)weakSelf = self;
    [manger downloadImageWithURL:url options:options progress:^(NSInteger receivedSize, NSInteger expectedSize) {
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        strongSelf.loadProgress = receivedSize/expectedSize;
    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        __strong __typeof (weakSelf)strongSelf = weakSelf;
        if (image) [strongSelf neatImage:image];
    }];
}

#pragma mark - 处理拿到的image 主要是内存优化
- (void)neatImage:(UIImage *)image{
    if (image.images) {
        // 延迟处理gif图片是为了防止SDImageCache写入硬盘不及时。
        NSData *imageData = UIImagePNGRepresentation(image.images.firstObject);
        [self performSelector:@selector(delayDealGifImage:) withObject:imageData afterDelay:0.25];
    }else self.image = image;
}

- (void)delayDealGifImage:(NSData *)imageData{
    self.gif = YES;
    self.image = [UIImage imageWithData:imageData];
}

- (void)useThreadLoadGifImageData:(void(^)(NSData *imgData))threadImageData{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        
        NSData *imgData = nil;
        // 本地 - 本地路径
        if (self.sourceType == YTPhotoSourceTypeLocal) {
            NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[self.imagePath stringByAppendingString:@"@2x"] ofType:@"gif"];
            imgData = [NSData dataWithContentsOfFile:retinaPath];
            
            if (!imgData) {
                NSString *path = [[NSBundle mainBundle] pathForResource:self.imagePath ofType:@"gif"];
                imgData = [NSData dataWithContentsOfFile:path];
            }
        }
        
        // 网络 - SDImageCache
        if (self.sourceType == YTPhotoSourceTypeNetWork) {
           NSString *pathFile = [[SDImageCache sharedImageCache] defaultCachePathForKey:self.imagePath];
            imgData = [NSData dataWithContentsOfFile:pathFile];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (threadImageData) threadImageData(imgData);
        });
    });
}

#pragma mark - kvo & kvc
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context{
    self.observerCount++;
    [super addObserver:observer forKeyPath:keyPath options:options context:context];
}

- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath{
    if (self.observerCount>0) {
        self.observerCount--;
        [super removeObserver:observer forKeyPath:keyPath];
    }
}

@end
