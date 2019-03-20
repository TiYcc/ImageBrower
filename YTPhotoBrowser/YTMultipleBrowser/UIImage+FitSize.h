//
//  UIImage+FitSize.h
//  newPark
//
//  Created by TI on 2018/3/30.
//  Copyright © 2018年 MHKJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (FitSize)

//size        : image最大显示尺寸
//contentMode : image在imageView显示模型
- (CGSize)imageFitSizeInSize:(CGSize)size andContentMode:(UIViewContentMode)contentMode;

@end
