/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : MemoryViewController.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/20
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <UIKit/UIKit.h>
#import "MemoryModel.h"

@interface MemoryViewController : UIViewController
@property (nonatomic, strong) NSArray<MemoryModel *> *memoryModels;
@end
