/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Catgray     : Copyright © 2019年 ycctime.com. All rights reserved.
# File        : SimpImageViewController.h
# Package     : YTPhotoBrowser
# Author      : TI
# Date        : 2019/3/13
# Describe    :
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

#import <UIKit/UIKit.h>
#import "SimpModel.h"

@interface SimpImageViewController : UIViewController
@property (nonatomic, strong) NSArray<SimpModel *> *models;
@end
