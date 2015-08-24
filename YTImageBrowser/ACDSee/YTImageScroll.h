//
//  YTImageScroll.h
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YTImageModel.h"

@interface YTImageScroll : UIScrollView

@property (nonatomic, strong) UIImageView * imgView;
@property (nonatomic, strong) YTImageModel * imgM;

/**恢复图片原始状态 可选择是否包含动画*/
- (void)replyStatuseAnimated:(BOOL)animated;

/**双击事件(父视触发，选着性调用)*/
- (void)doubleTapAction;

/**在横竖屏变化是调用 重新布局*/
- (void)layoutSubview;

@end
