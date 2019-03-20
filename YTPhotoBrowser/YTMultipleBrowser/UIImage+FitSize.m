//
//  UIImage+FitSize.m
//  newPark
//
//  Created by TI on 2018/3/30.
//  Copyright © 2018年 MHKJ. All rights reserved.
//

#import "UIImage+FitSize.h"

@implementation UIImage (FitSize)
// UIViewContentModeScaleAspectFit   宽高适配
// UIViewContentModeScaleAspectFill  宽高仅适配一个 截取一个
// UIViewContentModeScaleToFill      宽高不足拉伸 超出亚缩
// UIViewContentModeCenter           图片居中 超出截取
- (CGSize)imageFitSizeInSize:(CGSize)size andContentMode:(UIViewContentMode)contentMode{
    @autoreleasepool{
        CGSize fitSize = CGSizeZero;
        
        CGFloat width = self.size.width;
        CGFloat height = self.size.height;
        CGFloat kD_width = size.width;
        CGFloat kD_height = size.height;
        
        switch (contentMode) {
            case UIViewContentModeScaleAspectFill:
            case UIViewContentModeScaleToFill:
            {
                fitSize = size;
                break;
            }
            case UIViewContentModeCenter:
            {
                fitSize.width = MIN(width, kD_width);
                fitSize.height = MIN(height, kD_height);
                break;
            }
            default:
            {
                if ((width <= kD_width) && (height <= kD_height)) {
                    fitSize = self.size;
                }else{
                    BOOL ratio = (width/kD_width)>( height/kD_height);
                    
                    if (ratio) {
                        CGFloat height_fit = height*(kD_width/width);
                        fitSize = CGSizeMake(kD_width, height_fit);
                    }else{
                        CGFloat width_fit = width*(kD_height/height);
                        fitSize = CGSizeMake(width_fit, kD_height);
                    }
                }
                break;
            }
        }
        return fitSize;
    }
}

@end
