//
//  YTPhotoView.m
//  YTPhotoBrowser
//
//  Created by TI on 2018/3/27.
//  Copyright © 2018年 ytclear. All rights reserved.
//

#import "YTPhotoView.h"
#import "YTPhotoInfo.h"

#import "UIView+Frame.h"
#import "UIImage+FitSize.h"

#import "YTAnimationImageView.h"

@interface YTPhotoView()<UIAlertViewDelegate,UIScrollViewDelegate>{
    CGSize _imgSize;
}
@property (nonatomic, assign) UIViewContentMode imageViewContentMode;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIActivityIndicatorView *loopView;
@end


@implementation YTPhotoView

#pragma mark - Init
- (instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        self.imageViewContentMode = UIViewContentModeScaleAspectFit;
    }
    return self;
}

#pragma mark - Public Func
// 图片缩放到最大或者最小
- (void)shortcutZoomAnimated:(BOOL)animated{
    if (self.scrollView.zoomScale > self.scrollView.minimumZoomScale)
        [self.scrollView setZoomScale:_scrollView.minimumZoomScale animated:animated];
    else
        [self.scrollView setZoomScale:_scrollView.maximumZoomScale animated:animated];
}

// 图片缩放
- (void)shortcutZoomScale:(CGFloat)scale andAnimated:(BOOL)animated{
    [self.scrollView setZoomScale:scale animated:animated];
}

- (void)transition{
    self.scrollView.contentSize = _scrollView.bounds.size;
    [self shortcutZoomScale:1.0 andAnimated:YES];
    [self updataImageSize:self.imageView.image andContentMode:self.contentMode];
    self.imageView.frame = CGRectMake(0, 0, _imgSize.width, _imgSize.height);
    [self scrollViewDidZoom:self.scrollView];
}

#pragma mark - Private Func
- (void)imageViewSetImg:(UIImage *)image andContentMode:(UIViewContentMode)contentMode{
    [self.loopView stopAnimating];
    
    UIImage *oldImage = self.imageView.image;
    if ((!oldImage)||(oldImage.size.width != image.size.width)) {
        self.scrollView.zoomScale = 1.0;
        self.scrollView.contentSize = _scrollView.bounds.size;
        [self updataImageSize:image andContentMode:contentMode];
        
        self.imageView.frame = CGRectMake(0, 0, _imgSize.width, _imgSize.height);
        self.imageView.contentMode = contentMode;
        [self scrollViewDidZoom:_scrollView];
    }
        
        self.imageView.image = image;
        if (_photoInfo.isGif) {
            __weak __typeof (self)weakSelf = self;
            [_photoInfo useThreadLoadGifImageData:^(NSData *imgData) {
                __strong __typeof (weakSelf)strongSelf = weakSelf;
                [(YTAnimationImageView *)strongSelf.imageView setGifImageData:imgData];
            }];
        }
}

- (void)updataImageSize:(UIImage *)image andContentMode:(UIViewContentMode)contentMode{
    // 最大放大倍数动态计算
    _imgSize = [image imageFitSizeInSize:_scrollView.contentSize andContentMode:contentMode];
    CGSize scrollSize = _scrollView.bounds.size;
    CGFloat maxScale = MAX(_imgSize.width/scrollSize.width, _imgSize.height/scrollSize.height);
    self.maxZoomScale = MAX(_maxZoomScale, maxScale);
}

#pragma mark - Scroll View Delegate
// 对 imageView 进行放大缩小操作
- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return self.imageView;
}

// 放大或缩小时图片位置(frame)调整,保证居中
- (void)scrollViewDidZoom:(UIScrollView *)scrollView{
    @autoreleasepool {
        CGFloat Wo = scrollView.frame.size.width - scrollView.contentInset.left - scrollView.contentInset.right;
        CGFloat Ho = scrollView.frame.size.height - scrollView.contentInset.top - scrollView.contentInset.bottom;
        CGFloat W = self.imageView.frame.size.width;
        CGFloat H = self.imageView.frame.size.height;
        CGRect rct = self.imageView.frame;
        rct.origin.x = MAX((Wo-W)*0.5, 0);
        rct.origin.y = MAX((Ho-H)*0.5, 0);
        self.imageView.frame = rct;
    }
    
    if (_readScaleBlock) {
        _readScaleBlock(self.scrollView.zoomScale,NO);
    };
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale{
    if ((self.scrollView.zoomScale < 1.0)&&_readScaleBlock) {
        _readScaleBlock(self.scrollView.zoomScale,YES);
    }
}

#pragma mark - kvo
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context{
    if ([keyPath isEqualToString:@"image"]) {
        [self imageViewSetImg:_photoInfo.image andContentMode:self.imageViewContentMode];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - get && set
#pragma mark get
- (UIScrollView *)scrollView{
    if (!_scrollView) {
        CGRect bounds = self.bounds;
        bounds.size.width -= self.photoSpace;
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:bounds];
        scrollView.delegate = self;
        CGSize size = self.frame.size;
        scrollView.contentSize = size;
        scrollView.alwaysBounceVertical = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.maximumZoomScale = _maxZoomScale;
        scrollView.minimumZoomScale = _minZoomScale;
        scrollView.center = CGPointMake(size.width*0.5, size.height*0.5);
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView = scrollView];
    }
    return _scrollView;
}

- (UIImageView *)imageView{
    if (!_imageView) {
        UIImageView *imageView = [[YTAnimationImageView alloc]init];
        [imageView setClipsToBounds:YES];
        imageView.userInteractionEnabled = YES;
        imageView.contentMode = _imageViewContentMode;
        [self.scrollView addSubview:_imageView = imageView];
    }
    return _imageView;
}

- (UIActivityIndicatorView *)loopView{
    if (!_loopView) {
        UIActivityIndicatorView *loopView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        loopView.color = self.loopColor;
        loopView.center = self.scrollView.center;
        [self addSubview:_loopView = loopView];
        [self bringSubviewToFront:loopView];
    }
    return _loopView;
}

- (CGSize)imageFitSize{
    return _imgSize;
}

- (CGFloat)scale{
    return self.scrollView.zoomScale;
}

#pragma mark set
- (void)setPhotoInfo:(YTPhotoInfo *)photoInfo{
    [self.scrollView setZoomScale:1.0f];
    if (!photoInfo) return;
    
    if (_photoInfo) {
        [_photoInfo removeObserver:self forKeyPath:@"image"];
        _photoInfo = nil;
        self.imageView.image = nil;
    }
    
    _photoInfo = photoInfo;
    if (photoInfo.image) {
        [self imageViewSetImg:photoInfo.image andContentMode:self.imageViewContentMode];
    } else [self.loopView startAnimating];
    
    // 开启 kvo
    [photoInfo addObserver:self forKeyPath:@"image" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)setMaxZoomScale:(CGFloat)maxZoomScale{
    _maxZoomScale = maxZoomScale;
    if (_scrollView) {
        _scrollView.maximumZoomScale = maxZoomScale;
    }
}

- (void)setMinZoomScale:(CGFloat)minZoomScale{
    _minZoomScale = minZoomScale;
    if (_scrollView) {
        _scrollView.minimumZoomScale = minZoomScale;
    }
}

- (void)setImageViewContentMode:(UIViewContentMode)imageViewContentMode{
    switch (imageViewContentMode) {
        case UIViewContentModeScaleToFill:
        case UIViewContentModeScaleAspectFit:
        case UIViewContentModeScaleAspectFill:
        case UIViewContentModeCenter:
            break;
        default:
            imageViewContentMode = UIViewContentModeScaleAspectFit;
            break;
    }
    _imageViewContentMode = imageViewContentMode;
    if (_imageView) {
        _imageView.contentMode = imageViewContentMode;
    }
}

- (void)dealloc{
    if (_photoInfo) [_photoInfo removeObserver:self forKeyPath:@"image"];
    
    if (_imageView) {
        [(YTAnimationImageView *)_imageView timeInvalidate];
    }
}

@end
