/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : YTPhotoSave.m
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/13
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "YTPhotoSave.h"
@import Photos;

@implementation YTPhotoSave

+ (BOOL)userAuthorizationPhotoStatus{ // 相册
    PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
    switch (status) {
        case PHAuthorizationStatusAuthorized:
            return YES;
        case PHAuthorizationStatusNotDetermined:
            return NO;
        case PHAuthorizationStatusDenied:
        case PHAuthorizationStatusRestricted:
        default:
        {
            NSString *title = @"无法访问相册";
            NSString *message = @"请在iPhone/iPad的“设置-隐私-照片”中允许访问您的照片";
            [[self class] showTitle:title message:message];
            return NO;
        }
    }
}

+ (void)saveImage:(NSObject *)imgInfo{
    if ([[self class] userAuthorizationPhotoStatus]) {
        [[self class] saveImageToPhotoLibrary:imgInfo];
    } else {
        [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
            if (status == PHAuthorizationStatusAuthorized) {
                [[self class] saveImageToPhotoLibrary:imgInfo];
            }
        }];
    }
}

+ (void)saveImageToPhotoLibrary:(NSObject *)imgInfo{
    if (!imgInfo) return;
    
    // 1. 存储图片到"相机胶卷"
    [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
        // 新建一个PHAssetChangeRequest对象, 保存图片到"相机胶卷"
        if ([imgInfo isKindOfClass:[NSString class]]) {
            
            NSURL *fileUrl = [NSURL fileURLWithPath:(NSString *)imgInfo];
            [PHAssetChangeRequest creationRequestForAssetFromImageAtFileURL:fileUrl];
        }else{
            [PHAssetChangeRequest creationRequestForAssetFromImage:(UIImage *)imgInfo];
        }
        
    } completionHandler:^(BOOL success, NSError * _Nullable error) {
        // success == 1  保存成功 反之失败
        NSString *message = success?@"图片保存成功":@"图片保存失败";
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            [[self class] showTitle:@"保存图片" message:message];
        }];
    }];
}

+ (void)showTitle:(NSString *)title message:(NSString *)message{
    UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"确定",nil];
    
    [alertView show];
}

@end
