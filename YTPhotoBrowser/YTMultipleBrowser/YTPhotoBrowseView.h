//
//  YTPhotoBrowseView.h
//  YTPhotoBrowser
//
//  Created by TI on 2018/3/27.
//  Copyright © 2018年 ytclear. All rights reserved.
//


#import "YTPhotoBrowseSeting.h"
#import "YTPhotoView.h"

@class YTPhotoBrowseView;

@protocol YTPhotoBrowseViewDatasource <NSObject>

// 多少张图片
- (NSInteger)numberOfPhotosInPhotoBrowseView:(YTPhotoBrowseView *)photoBrowseView;

// page对应图片信息
- (YTPhotoInfo *)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView photoInfoAtPage:(NSInteger)page;

@end

@protocol YTPhotoBrowseViewDelegate <NSObject>
@optional
// 动画显示photoBrowseView 返回的开始动画位置
- (CGRect)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView BeginFrameAnimationAtPage:(NSInteger)page;

// 图片浏览器将要在@return时间后消失，返回时间也许对你的动画效果看起来舒服些
// 可以返回0，你也可以尝试下0.15看下效果。
- (NSTimeInterval)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView willDismissAfterDelayAtPage:(NSInteger)page;

// 动画消失photoBrowseView 返回的结束动画位置
// 该代理会在photoBrowseView:willDismissAfterDelayAtPage:代理后触发
// 触发将被延迟到photoBrowseView:willDismissAfterDelayAtPage:返回的时间
- (CGRect)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView EndFrameAnimationAtPage:(NSInteger)page;

// 图片保存请求
- (void)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView saveImageRequestAtPage:(NSInteger)page;

// 图片浏览器已经消失
- (void)photoBrowseView:(YTPhotoBrowseView *)photoBrowseView didDismissAtPage:(NSInteger)page;

@end

@interface YTPhotoBrowseView : UIView
// 代理
@property (nonatomic, assign) id <YTPhotoBrowseViewDatasource> dataSource;
@property (nonatomic, assign) id <YTPhotoBrowseViewDelegate> delegate;

// 当前位置
@property (nonatomic, assign, readonly) NSInteger currentPage;

// 当前图片显示view
@property (nonatomic, strong, readonly) YTPhotoView *currentPhotoView;

// 初始化对象和配置信息
- (instancetype)initWithFrame:(CGRect)frame andSetingModel:(YTPhotoBrowseSeting *)setingModel;

// 重载界面
- (void)reloadDataAtPage:(NSInteger)page;

// 屏幕发生了旋转
- (void)transition;
@end
