//
//  YTPhotoInfo.h
//  YTPhotoBrowser
//
//  Created by TI on 2018/3/27.
//  Copyright © 2018年 ytclear. All rights reserved.
//

@class UIImage;

#import <Foundation/Foundation.h>

// 可扩展属性
typedef NS_ENUM(NSUInteger, YTPhotoSourceType) {
    YTPhotoSourceTypeImage = 0,  // 图片 (image不为nil)
    YTPhotoSourceTypeLocal,      // 本地图片 (同上)
    YTPhotoSourceTypePHKit,      // 相册libary (imagePath 不为nil)
    YTPhotoSourceTypeNetWork     // 网络图片 (同上)
};

@interface YTPhotoInfo : NSObject

// 该属性在这里不会用到，仅仅为使用者自定义内容，需要时方便使用它
@property (nonatomic, strong) NSObject *obj;

// 图片地址
@property (nonatomic, strong) NSString *imagePath;

// image
@property (nonatomic, strong) UIImage *image;

// image加载比例
@property (nonatomic, assign) float loadProgress;

// 是否是动态图
@property (nonatomic, assign, getter=isGif) BOOL gif;

// 图片来源类型,类型明确方便图片的获取
@property (nonatomic, assign, readonly) YTPhotoSourceType sourceType;

// 根据图片类型 创建一个YTPhotoInfo类 obj
+ (YTPhotoInfo *)photoInfoWithSourceType:(YTPhotoSourceType)sourceType;

+ (YTPhotoInfo *)photoInfoWithObj:(id)obj andSourceType:(YTPhotoSourceType)sourceType;

- (void)useThreadLoadGifImageData:(void(^)(NSData *imgData))threadImageData;

@end
