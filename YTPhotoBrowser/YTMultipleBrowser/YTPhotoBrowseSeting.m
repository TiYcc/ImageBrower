/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : YTPhotoBrowseSeting.m
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/19
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import "YTPhotoBrowseSeting.h"

@implementation YTPhotoBrowseSeting
- (instancetype)init{
    if (self = [super init]) {
        self.openSave = YES;
        self.saveTitle = @"保存";
        self.photosSpace = 10.f;
        self.zoomEnable = YES;
        self.maxImageScale = 2.f;
        self.minImageScale = 1.f;
        self.moveEnable = YES;
        self.backGroundColor = [UIColor blackColor];
        self.textColor = [UIColor whiteColor];
        self.loadColor = [UIColor blueColor];
        self.textFont = [UIFont systemFontOfSize:[UIFont labelFontSize]];
    }
    return self;
}
@end
