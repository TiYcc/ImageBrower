//
//  ViewController.m
//  ACDSee
//
//  Created by TI on 15/7/14.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "ViewController.h"
#import "YTImageBrowerController.h"
#import "MBProgressHUD.h"
#import "UIButton+AFNetworking.h"
#import "objc/runtime.h"
@interface ViewController ()<YTImageBrowerControllerDelegate,MBProgressHUDDelegate>{
    CGFloat angle;
    MBProgressHUD * HUD;
}

@property (nonatomic, strong) NSMutableArray * imgs;
@property (nonatomic, strong) UIImageView * imgView;
@property (nonatomic, strong) YTImageBrowerController * acdSC;
@property (nonatomic, strong) UIView * backView;
@property (nonatomic, strong) UIView * confiView;
@property (nonatomic, strong) NSArray * urls;

@end

@implementation ViewController

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSMutableArray *)imgs{
    if (!_imgs) {
        _imgs = [NSMutableArray array];
    }
    return _imgs;
}

- (UIImageView *)imgView{
    if (!_imgView) {
        _imgView = [[UIImageView alloc]init];
        [_imgView setClipsToBounds:YES];
        [_imgView setContentMode:UIViewContentModeScaleAspectFit];
        
        [self.view addSubview:_imgView];
    }
    return _imgView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initHUD];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deviceAngle) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)initHUD{
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    HUD.delegate = self;
    [self.view addSubview:HUD];
    
    [HUD showWhileExecuting:@selector(imgsInit) onTarget:self withObject:nil animated:YES];
}

- (void)imgsInit{
    CGRect frame = self.view.bounds;
    frame.size.height *= 0.5;
    
    self.confiView = [[UIView alloc]initWithFrame:frame];
    self.confiView.center = self.view.center;
    [self.view addSubview:self.confiView];
    self.urls = [[self httpImgUrls] copy];
    if (self.urls.count < 4) {
        return;
    }
    for (int i = 0; i < 4; i++) {
        CGRect rect = self.confiView.bounds;
        rect.size.width *= 0.5;
        rect.size.height *= 0.5;
        rect.origin.x = (i%2) * rect.size.width;
        rect.origin.y = i > 1?rect.size.height:0;
        UIButton * imgBt = [[UIButton alloc]initWithFrame:rect];
        imgBt.tag = i+1;
        NSURL * url = [NSURL URLWithString:self.urls[i]];
        NSData * data = [NSData dataWithContentsOfURL:url];
        UIImage * image = [UIImage imageWithData:data];
        
        [imgBt setImage:image forState:UIControlStateNormal];
        [imgBt addTarget:self action:@selector(img:) forControlEvents:UIControlEventTouchUpInside];
        [imgBt.imageView setContentMode:UIViewContentModeScaleAspectFit];
        [self.confiView addSubview:imgBt];
        
    }
    
    self.backView = [[UIView alloc]initWithFrame:self.view.bounds];
    self.backView.backgroundColor = [UIColor blackColor];
    self.backView.alpha = 0.0f;
    
    [self.view addSubview:self.backView];
}

- (void)img:(UIButton*)sender{
    [self.imgs removeAllObjects];
    
    CGRect frame = [sender.superview convertRect:sender.frame toView:self.view];
    self.imgView.frame = frame;
    self.imgView.image = sender.imageView.image;
    for (UIButton * b in self.confiView.subviews) {
        if (!b.imageView.image) {
            return;
        }
        [self.imgs addObject:b.imageView.image];
    }
    self.acdSC = [[YTImageBrowerController alloc]initWithDelegate:self Imgs:self.imgs Urls:self.urls PageIndex:(sender.tag - 1)];
}

#pragma delegate

- (void)deviceAngle{
    UIDeviceOrientation  dev = [[UIDevice currentDevice] orientation];
    switch (dev) {
        case 3:
            angle = M_PI_2;
            break;
        case 4:
            angle = -M_PI_2;
            break;
        case 5:
        case 6:
        case 0:
            break;
        default:
            angle = 0.0f;
            break;
    }
}

- (void)ACDSeeControllerInitEnd:(CGSize)size{
    CGRect frame = self.view.frame;
    if (angle != 0.0f) {
        frame.size.width = size.height;
        frame.size.height = size.width;
    }else{
        frame.size = size;
    }
    [UIView animateWithDuration:0.3f animations:^{
        self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, angle);
        self.imgView.frame = frame;
        self.imgView.center = self.view.center;
        self.backView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            __weak __typeof (self)weekSelf = self;
            [self presentViewController:self.acdSC animated:NO completion:^{
                weekSelf.imgView.transform = CGAffineTransformIdentity;
            }];
        }
    }];
}

- (void)ACDSeeControllerWillDismiss:(CGSize)size Img:(UIImage *)img Index:(NSInteger)index{
    self.acdSC = nil;
    
    CGRect frame = self.view.bounds;
    CGPoint center = self.view.center;
    if (angle != 0.0f) {
        frame.size.width = size.height;
        frame.size.height = size.width;
        center = CGPointMake(center.y, center.x);
    }else{
        frame.size = size;
    }
    self.imgView.transform = CGAffineTransformRotate(self.imgView.transform, angle);
    self.imgView.frame = frame;
    self.imgView.image = img;
    self.imgView.center = center;
    
    UIButton * bt = (UIButton*)[self.confiView viewWithTag:(index + 1)];
    CGRect rect = [bt.superview convertRect:bt.frame toView:self.view];
    
    [UIView animateWithDuration:0.4f animations:^{
        self.imgView.transform = CGAffineTransformIdentity;
        self.imgView.frame = rect;
        self.backView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if (finished) {
            NSLog(@"ni ma 成功");
            [self.imgView removeFromSuperview];
        }
    }];
    
}

#pragma mark - self

- (NSArray*)httpImgUrls{
    NSString * str = @"http://api.ucar9.com/index.php?act=threadview&bbsid=21&tid=12793131&font=(null)&key=1746cf9639f70d639e10fa7ebcb8f7f2&3g=0";
    str = [str stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString * html = [NSString stringWithContentsOfURL:[NSURL URLWithString:str] encoding:NSUTF8StringEncoding error:nil];
    
    NSArray * array = [html componentsSeparatedByString:@"'"];
    NSMutableArray * imgHttps = [NSMutableArray arrayWithCapacity:100];
    for (NSString * imgHttp in array) {
        if ([imgHttp hasSuffix:@"jpg"]) {
            [imgHttps addObject:imgHttp];
        }
    }
    return imgHttps;
}

- (void)hudWasHidden:(MBProgressHUD *)hud {
    [HUD removeFromSuperview];
    HUD = nil;
}

@end
