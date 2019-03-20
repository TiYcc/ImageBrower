//
//  UIView+Frame.h
//  leavePark
//
//  Created by TI on 2018/11/19.
//  Copyright © 2018年 MHKJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Frame)

//frame
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) CGFloat top;
@property (nonatomic, assign) CGFloat left;
@property (nonatomic, assign) CGFloat bottom;
@property (nonatomic, assign) CGFloat right;
@property (nonatomic, assign) CGFloat width;
@property (nonatomic, assign) CGFloat height;
@property (nonatomic, assign) CGFloat x;
@property (nonatomic, assign) CGFloat y;
@property (nonatomic,readonly, assign) CGFloat maxX;
@property (nonatomic,readonly, assign) CGFloat maxY;

//bounds
@property (nonatomic, assign) CGSize boundsSize;
@property (nonatomic, assign) CGFloat boundsWidth;
@property (nonatomic, assign) CGFloat boundsHeight;

//content
@property (nonatomic, readonly) CGRect contentBounds;
@property (nonatomic, readonly) CGPoint contentCenter;

//additional frame
- (void)setLeft:(CGFloat)left right:(CGFloat)right;
- (void)setWidth:(CGFloat)width right:(CGFloat)right;
- (void)setTop:(CGFloat)top bottom:(CGFloat)bottom;
- (void)setHeight:(CGFloat)height bottom:(CGFloat)bottom;

//animation
- (void)crossfadeWithDuration:(NSTimeInterval)duration;
- (void)crossfadeWithDuration:(NSTimeInterval)duration completion:(void (^)(void))completion;

@end
