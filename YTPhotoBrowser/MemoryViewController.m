/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : MemoryViewController.m
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/20
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "MemoryViewController.h"
#import "YTPhotoBrowseView.h"
#import "YTPhotoSave.h"
#import "UIImage+FitSize.h"
#import "YTAnimationImageView.h"
#import <SDWebImage/SDImageCache.h>

@interface MemoryViewController ()
<YTPhotoBrowseViewDelegate,YTPhotoBrowseViewDatasource>
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSArray<UIImageView *> *imageViews;

//  多图浏览
@property (nonatomic, strong) YTPhotoBrowseView *photoBrowseView;
@end

@implementation MemoryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // add iamge views
    [self addContentView];
    [self addImageViews];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    // 图片加载到运行内存里，若不置空，不会及时释放
    for (UIImageView *imageView in self.imageViews) {
        imageView.image = nil;
    }
    self.memoryModels = nil;
}

- (void)addContentView{
    self.contentView = [[UIView alloc]init];
    CGFloat height  = self.navigationController.navigationBar.bounds.size.height;
    CGSize  size = self.view.bounds.size;
    _contentView.frame = CGRectMake(0, height, size.width, size.height-height);
    [self.view addSubview:_contentView];
}

- (void)addImageViews;{
    CGSize  size = self.contentView.bounds.size;
    CGFloat imageW = size.width*0.5;
    CGFloat imageH = size.height*0.2;
    
    NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:10];
    for (int tag = 0; tag < 10; tag++) {
        UIImageView *imageView = [[YTAnimationImageView alloc]init];
        imageView.tag = tag;
        imageView.clipsToBounds = YES;
        imageView.userInteractionEnabled = YES;
        imageView.backgroundColor = [UIColor lightGrayColor];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.frame = CGRectMake((tag%2)*imageW, (tag/2)*imageH, imageW-1, imageH-1);
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
        [imageView addGestureRecognizer:tap];
        [imageArray addObject:imageView];
        [self.contentView addSubview:imageView];
    }
    self.imageViews = [imageArray copy];
    [self loadImageViewSourence];
}

- (void)loadImageViewSourence{
    for (UIImageView *imageView in self.imageViews) {
        if (imageView.tag >= self.memoryModels.count) return;
        
        MemoryModel *m = self.memoryModels[imageView.tag];
        
        if (m.image) {
            imageView.image = m.image;
            if (m.gif) {
                [m useThreadLoadGifImageData:^(NSData *imgData) {
                    [(YTAnimationImageView *)imageView setGifImageData:imgData];
                }];
            }
        }else{
            __weak __typeof (UIImageView *)weakImageView = imageView;
            m.imageFinishBlock = ^(MemoryModel *mm) {
                __strong __typeof (weakImageView)strongImageView = weakImageView;
                strongImageView.image = mm.image;
                if (mm.gif) {
                    [mm useThreadLoadGifImageData:^(NSData *imgData) {
                        [(YTAnimationImageView *)imageView setGifImageData:imgData];
                    }];
                }
            };
        }
    }
}

- (void)tapAction:(UIGestureRecognizer *)gesture{
    //  弹出 photoBrowseView 显示多图浏览
    [self.view addSubview:self.photoBrowseView];
    [self.photoBrowseView reloadDataAtPage:gesture.view.tag];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - 多图浏览

- (NSInteger)numberOfPhotosInPhotoBrowseView:(YTPhotoBrowseView *)photoBrowseView{
    return self.memoryModels.count;
}

- (YTPhotoInfo *)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView photoInfoAtPage:(NSInteger)page{
    MemoryModel *sm = self.memoryModels[page];
    YTPhotoInfo *info = [YTPhotoInfo photoInfoWithSourceType:YTPhotoSourceTypeNetWork];
    info.image = sm.image;
    info.imagePath = sm.imagePath;
    return info;
}

- (NSTimeInterval)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView willDismissAfterDelayAtPage:(NSInteger)page{
    // 有时候这样，动画看起更顺畅一些（个人感觉吧）
    return 0.15;
}

- (CGRect)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView EndFrameAnimationAtPage:(NSInteger)page{// 结束位置
    UIImageView *imv = self.imageViews[page];
    
    CGSize imageFitSize = imv.bounds.size;
    if (imv.image) {
        imageFitSize = [imv.image imageFitSizeInSize:imageFitSize andContentMode:UIViewContentModeScaleAspectFit];
    }
    
    // 计算位置 取出image所在屏幕位置，不是imageView的位置
    CGRect rect = [imv convertRect:imv.bounds toView:photoBrowseView.superview];
    rect.origin.x += (rect.size.width - imageFitSize.width)*0.5;
    rect.origin.y += (rect.size.height - imageFitSize.height)*0.5;
    rect.size = imageFitSize;
    return rect;
}

- (CGRect)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView BeginFrameAnimationAtPage:(NSInteger)page{ // 开始位置
    UIImageView *imv = self.imageViews[page];
    
    CGSize imageFitSize = imv.bounds.size;
    if (imv.image) {
        imageFitSize = [imv.image imageFitSizeInSize:imageFitSize andContentMode:UIViewContentModeScaleAspectFit];
    }
    
    // 计算位置   取出image所在屏幕位置，不是imageView的位置
    CGRect rect = [imv convertRect:imv.bounds toView:photoBrowseView.superview];
    rect.origin.x += (rect.size.width - imageFitSize.width)*0.5;
    rect.origin.y += (rect.size.height - imageFitSize.height)*0.5;
    rect.size = imageFitSize;
    return rect;
}

- (void)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView saveImageRequestAtPage:(NSInteger)page{
    YTPhotoInfo *info = photoBrowseView.currentPhotoView.photoInfo;
    if (info.isGif) {
        if (info.sourceType == YTPhotoSourceTypeLocal) {
            NSString *pathFile = [[NSBundle mainBundle] pathForResource:info.imagePath ofType:@"gif"];
            [YTPhotoSave saveImage:pathFile];
            return;
        }
        
        if (info.sourceType == YTPhotoSourceTypeNetWork) {
            NSString *pathFile = [[SDImageCache sharedImageCache] defaultCachePathForKey:info.imagePath];
            [YTPhotoSave saveImage:pathFile];
            return;
        }
    }
    [YTPhotoSave saveImage:info.image];
}

- (void)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView didDismissAtPage:(NSInteger)page{
    if (photoBrowseView.superview) [photoBrowseView removeFromSuperview];
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator

{
    if (_photoBrowseView) {
        CGRect frame = self.photoBrowseView.frame;
        frame.size = size;
        self.photoBrowseView.frame = frame;
        [self.photoBrowseView transition];
    }
}

- (YTPhotoBrowseView *)photoBrowseView{
    if (!_photoBrowseView) {
        CGRect bounds = [UIScreen mainScreen].bounds;
        _photoBrowseView = [[YTPhotoBrowseView alloc]initWithFrame:bounds andSetingModel:nil];
        _photoBrowseView.delegate = self;
        _photoBrowseView.dataSource = self;
    }
    return _photoBrowseView;
}

@end
