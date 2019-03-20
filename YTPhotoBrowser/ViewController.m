//
//  ViewController.m
//  YTPhotoBrowser
//
//  Created by TI on 16/3/16.
//  Copyright © 2016年 ycctime.com. All rights reserved.
//

#import "ViewController.h"
#import "UIImage+GIF.h"
#import <Photos/Photos.h>
#import "MemoryViewController.h"
#import "SimpImageViewController.h"

#import "YTPhotoBrowseView.h" // 相册展示

@interface ViewController ()<YTPhotoBrowseViewDelegate,YTPhotoBrowseViewDatasource>
@property (nonatomic, strong) YTPhotoBrowseView *photoBrowseView;


@property (nonatomic, strong) NSArray *imagePaths;
@property (nonatomic, strong) NSArray *imageNames;
@property (nonatomic, strong) NSArray *photoAssets;
@end

@implementation ViewController

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator

{
    if (_photoBrowseView) {
        CGRect frame = self.photoBrowseView.frame;
        frame.size = size;
        self.photoBrowseView.frame = frame;
        [self.photoBrowseView transition];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // net
    self.imagePaths = @[@"https://www.popo8.com/host/data/201903/12/6/p1552437505_87774.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/4/p1552437506_80332.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/5/p1552437506_40960.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/4/p1552437506_52218.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/4/p1552437507_54502.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/7/p1552437507_98765.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/6/p1552437508_37979.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/3/p1552437509_28173.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/4/p1552437510_52604.jpg_b.jpg",
                        @"https://www.popo8.com/host/data/201903/12/4/p1552437511_31705.jpg_b.jpg"];
    
    // local
    self.imageNames = @[@"mm0",@"mm1",@"mm2",@"mm3",@"mm4",@"mm5",@"mm6",@"mm7",@"mm8",@"mm9"];
    
    
    // photo 下面的写法有些粗糙，不过重点不是这个，就没花时间整理
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    NSMutableArray *photoAssets = [NSMutableArray array];
    for (PHAssetCollection *assetCollection in smartAlbums) {
        PHFetchResult *fetchResult = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        for (PHAsset *asset in fetchResult) {
            if (asset) [photoAssets addObject:asset];
        }
    }
    self.photoAssets = [photoAssets copy];
}

- (void)didReceiveMemoryWarning {
    NSLog(@"警告！警告！内存出错了");
    [super didReceiveMemoryWarning];
}

- (IBAction)localPicture:(UIButton *)sender {
    SimpImageViewController *svc = [[SimpImageViewController alloc]init];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:9];
    for (NSString *imageName in self.imageNames) {
        SimpModel *m = [[SimpModel alloc]init];
        m.image = [UIImage sd_animatedGIFNamed:imageName];
        m.imagePath = imageName;
        m.type = 0;
        [marray addObject:m];
    }
    svc.models = [marray copy];
    
    [self.navigationController pushViewController:svc animated:YES];
}

- (IBAction)libarryPicture:(UIButton *)sender {
    [self.photoBrowseView reloadDataAtPage:0];
}

- (IBAction)networkingPicture:(UIButton *)sender {
    SimpImageViewController *svc = [[SimpImageViewController alloc]init];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:10];
    for (NSString *imagePath in self.imagePaths) {
        SimpModel *m = [[SimpModel alloc]init];
        m.imagePath = imagePath;
        m.type = 2;
        [marray addObject:m];
    }
    svc.models = [marray copy];
    
    [self.navigationController pushViewController:svc animated:YES];
}
- (IBAction)memaryOptimizeNetPicture:(id)sender {
    
    MemoryViewController *mvc = [[MemoryViewController alloc]init];
    NSMutableArray *marray = [NSMutableArray arrayWithCapacity:10];
    for (NSString *imagePath in self.imagePaths) {
        MemoryModel *m = [[MemoryModel alloc]init];
        m.imagePath = imagePath;
        [marray addObject:m];
    }
    mvc.memoryModels = [marray copy];
    
    [self.navigationController pushViewController:mvc animated:YES];
    
}

//-----------------

#pragma mark - 多图浏览

- (NSInteger)numberOfPhotosInPhotoBrowseView:(YTPhotoBrowseView *)photoBrowseView{
    return self.photoAssets.count;
}

- (YTPhotoInfo *)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView photoInfoAtPage:(NSInteger)page{
    PHAsset *asset = self.photoAssets[page];
    YTPhotoInfo *info = [YTPhotoInfo photoInfoWithSourceType:YTPhotoSourceTypePHKit];
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    __weak __typeof (YTPhotoInfo *)weakInfo = info;
    
    [imageManager requestImageDataForAsset:asset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        __strong __typeof (weakInfo)strongInfo = weakInfo;
        UIImage * image = [UIImage imageWithData:imageData];
        strongInfo.image = image;
    }];
    
    return info;
}


- (void)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView didDismissAtPage:(NSInteger)page{
    if (photoBrowseView.superview) [photoBrowseView removeFromSuperview];
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
