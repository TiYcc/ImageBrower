//
//  YTImageModel.m
//  YTImageBrowser
//
//  Created by TI on 15/8/24.
//  Copyright (c) 2015年 YccTime. All rights reserved.
//

#import "YTImageModel.h"

#define Max_Count_Obj 5000
#define Device_Size ([UIScreen mainScreen].bounds.size)

@implementation YTImageModel

+(NSArray *)IMGMessagesWithImgs:(NSArray *)imgs Urls:(NSArray *)urls{
    //根据图片及图片网址来创建一组该对象 最多为(Max_Count_Obj)个
    NSInteger max =  MAX(imgs.count, urls.count);
    NSInteger maxInt = MIN(Max_Count_Obj, max);
    NSMutableArray * imgModels = [NSMutableArray arrayWithCapacity:maxInt];
    for (int i = 0; i < maxInt; i++) {
        YTImageModel * img = [YTImageModel new];
        
        img.image = i < imgs.count?imgs[i]:nil;
        id objUrl = i < urls.count?urls[i]:nil;
        if (objUrl) {
            if ([objUrl isMemberOfClass:[NSURL class]]) {
                img.url = objUrl;
            }else{
                img.url = [NSURL URLWithString:objUrl];
            }
            if (!img.image || (img.image.size.width < 1.0f)) {
                img.image = [UIImage imageNamed:@"default_img"];
            }
        }
        img.index = i;
        img.http = NO;
        
        [imgModels addObject:img];
    }
    return imgModels;
}

-(void)setImage:(UIImage *)image{
    if (image) {
        _image = image;
        self.size = [self imageSize];
    }
}

-(CGSize)imageSize{//图片根据屏幕大小来调整size,保证与屏幕比例适配
    CGFloat wid = _image.size.width;
    CGFloat heig = _image.size.height;
    if ((wid <= Device_Size.width) && (heig <= Device_Size.height)) {
        return _image.size;
    }
    
    CGFloat scale_poor = (wid/Device_Size.width)-( heig/Device_Size.height);
    CGSize endSize = CGSizeZero;
    
    if (scale_poor > 0) {
        CGFloat height_now = heig*(Device_Size.width/wid);
        endSize = CGSizeMake(Device_Size.width, height_now);
    }else{
        CGFloat width_now = wid*(Device_Size.height/heig);
        endSize = CGSizeMake(width_now, Device_Size.height);
    }
    
    return endSize;
}

@end
