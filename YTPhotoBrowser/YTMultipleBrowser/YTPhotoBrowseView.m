//
//  YTPhotoBrowseView.m
//  YTPhotoBrowser
//
//  Created by TI on 2018/3/27.
//  Copyright © 2018年 ytclear. All rights reserved.
//

#import "YTPhotoBrowseView.h"
#import "YTPhotoBrowseSeting.h"
#import "UIView+Frame.h"

#define KvUpdataFactor 0.75 // 滑动距离相对屏幕系数

@interface YTPhotoBrowseView()<UIScrollViewDelegate>{
    // 图片总数量
    NSInteger _imageCount;
    
    // 当前x位置
    CGFloat _currentOffsetX;
    
    // 手势
    UITapGestureRecognizer *_tapGR; // 单击
    UITapGestureRecognizer *_tapDoubleGR; // 双击
    UIPanGestureRecognizer *_panGR; // 滑动
}

// 类内属性
@property (nonatomic, strong) UIView *backgroundView;   // 背景图
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *allPhotoViews;      // 全部view
@property (nonatomic, strong) NSMutableArray *dequeuePhotoViews;  // 队列隐藏
@property (nonatomic, strong) NSMutableArray *currentPhotoViews;  // 当前显示

@property (nonatomic, strong) UILabel *pageLabel; // 当前页数/总页数
@property (nonatomic, strong) UIButton *saveImageBt; // 保存图片

@property (nonatomic, strong) YTPhotoBrowseSeting *setingModel;
@end

@implementation YTPhotoBrowseView

#pragma mark - Init
#pragma mark (Init Bacall)
- (instancetype)init{
    return [self initWithFrame:[UIScreen mainScreen].bounds andSetingModel:nil];
}

- (instancetype)initWithFrame:(CGRect)frame{
    return [self initWithFrame:frame andSetingModel:nil];
}

- (instancetype)initWithFrame:(CGRect)frame andSetingModel:(YTPhotoBrowseSeting *)setingModel{
    if (self = [super initWithFrame:frame]) {
        if (!setingModel) setingModel = [[YTPhotoBrowseSeting alloc]init];
        _setingModel = setingModel;
        [super setBackgroundColor:[UIColor clearColor]];
        self.backgroundView.backgroundColor = _setingModel.backGroundColor;
        [self initUI];
    }
    return self;
}

- (void)initUI{
    [self initSubView];
    [self initGR];
}

- (void)initSuperView{
    if (!self.superview) {
        UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
        [window addSubview:self];
    }
    [self.superview bringSubviewToFront:self];
}

- (void)initSubView{
    // 添加PhotoView
    NSInteger  subNumber = 3;
    for (int viewIndex = 1; viewIndex <= subNumber; viewIndex++) {
        YTPhotoView *photoView = [[YTPhotoView alloc]initWithFrame:self.scrollView.bounds];
        photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        photoView.photoSpace = _setingModel.photosSpace;
        photoView.minZoomScale = _setingModel.minImageScale;
        photoView.maxZoomScale = _setingModel.maxImageScale;
        photoView.loopColor = _setingModel.loadColor;
        // photoView block 实现
        __weak __typeof (self)weakSelf = self;
        photoView.readScaleBlock = ^(float scale, BOOL stopped){
            __strong __typeof (weakSelf)strongSelf = weakSelf;
            strongSelf.alpha = scale;
            if (stopped) [strongSelf tapAction:nil];
            
        };
        [self.allPhotoViews addObject:photoView];
        [self.scrollView addSubview:photoView];
    }
}

- (void)initGR{
    // 添加手势
    // 单击
    _tapGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapAction:)];
    [self addGestureRecognizer:_tapGR];
    
    if (_setingModel.isZoomEnable) {
        // 双击
        _tapDoubleGR = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(doubleTapAction:)];
        [_tapDoubleGR setNumberOfTapsRequired:2];
        [self addGestureRecognizer:_tapDoubleGR];
        //单击优先级滞后于双击
        [_tapGR requireGestureRecognizerToFail:_tapDoubleGR];
        
        if (_setingModel.isMoveEnable) {
            //滑动
            _panGR = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panGestureRecognizeraction:)];
            [self addGestureRecognizer:_panGR];
        }
    }
}

#pragma mark - self func
#pragma mark Public Func
- (void)transition{
        CGSize contentSize = _scrollView.size;
        contentSize.width = contentSize.width*_imageCount;
        self.scrollView.contentSize = contentSize;
    
        for (YTPhotoView *photoView in self.allPhotoViews) {
            CGRect photoF = self.scrollView.bounds;
            photoF.origin.x = (photoView.tag*photoF.size.width);
            photoView.frame = photoF;
            [photoView transition];
        }
    
        [self.scrollView setContentOffset:_currentPhotoView.origin];
        _currentOffsetX = _currentPhotoView.left;
    
        self.pageLabel.frame = CGRectMake(0, self.height-30, self.width, 20);
        self.saveImageBt.frame = CGRectMake(self.width-55, self.height-30, 40, 20);
}

- (void)reloadDataAtPage:(NSInteger)page{
    _currentPage = page;
    // scroll view 内容大小
    _imageCount = [self numberOfPhotos];
    if (_imageCount == 0) return;
    
    CGSize contentSize = self.scrollView.bounds.size;
    contentSize.width = (contentSize.width)*_imageCount;
    self.scrollView.contentSize = contentSize;
    
    [self reload];
    
    // 滚动到当前图片位置
    [self.scrollView setContentOffset:_currentPhotoView.frame.origin];
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentPage+1,_imageCount];
    
    [self beginFrameAnimation];
}

#pragma mark Private Func
- (void)reload{
    // 内部cell合理排布
    [self.currentPhotoViews removeAllObjects];
    [self.dequeuePhotoViews removeAllObjects];
    
    NSInteger logicMax = MIN(_currentPage+1, _imageCount-1);
    NSInteger logicMin = MAX(_currentPage-1,0);
    YTPhotoView *photoView;
    for (NSInteger page = logicMin; page <= logicMax; page++) {
        // 取出view
        photoView = self.allPhotoViews[page-logicMin];
        // 把view加到对应的容器中
        [self updataPhotoView:photoView atPage:page];
        if (page == _currentPage) {
            _currentOffsetX = photoView.frame.origin.x;
            _currentPhotoView = photoView;
            [self.currentPhotoViews addObject:photoView];
        }else{
            [self.dequeuePhotoViews addObject:photoView];
        }
    }
    
    // 特殊情况处理
    switch (_imageCount) {
        case 1:{
            photoView = [self.allPhotoViews objectAtIndex:1];
            [photoView removeFromSuperview];
            photoView = [self.allPhotoViews objectAtIndex:2];
            [photoView removeFromSuperview];
        }break;
        case 2:{
            photoView = [self.allPhotoViews objectAtIndex:2];
            [photoView removeFromSuperview];
        }break;
        default:{
            if (self.dequeuePhotoViews.count==1) {
                photoView = [self.allPhotoViews lastObject];
                NSInteger page = 2;
                if (_currentPage != 0) {
                    page = _currentPage - 2;
                }
                [self updataPhotoView:photoView atPage:page];
                [self.dequeuePhotoViews addObject:photoView];
            }
        }break;
    }
}

// 对scrollView滑动进行逻辑封装
- (void)scrollViewDraggingScroll:(UIScrollView *)scrollView{
    @autoreleasepool {
        CGFloat width = scrollView.width;
        CGFloat offset_x = scrollView.contentOffset.x;
        CGFloat pageFloat = offset_x/width;
        
        CGFloat poorValue = width*KvUpdataFactor; // 滑动更新界面设定值
        CGFloat big_offset_x = _currentOffsetX + poorValue;
        CGFloat low_offset_x = _currentOffsetX - poorValue;
        
        // 滑动距离超过poorValue时进行更新
        if (offset_x > big_offset_x) {
            [self scrollViewWillPageToIndex:ceilf(pageFloat)];
        } else if (offset_x < low_offset_x) {
            [self scrollViewWillPageToIndex:floorf(pageFloat)];
        }
    }
}

- (void)scrollViewWillPageToIndex:(NSUInteger)pageIndex{
    if ((_currentPage==pageIndex)||(pageIndex>=_imageCount)) return;
    _currentPhotoView = [self dequeueReusablePhotoViewAtPage:_currentPage = pageIndex];
    self.pageLabel.text = [NSString stringWithFormat:@"%ld/%ld",_currentPage+1,_imageCount];
}

- (YTPhotoView *)dequeueReusablePhotoViewAtPage:(NSUInteger)uPage{
    // 找出当前应该显示的cell
    YTPhotoView *current_pv;
    YTPhotoView *other_pv;
    for (YTPhotoView *photoView in self.dequeuePhotoViews) {
        if (photoView.tag == uPage) {
            current_pv = photoView;
        }else{
            other_pv = photoView;
        }
    }
    
    // 把当前cell调放到对应位置
    if (current_pv) {
        [self.dequeuePhotoViews removeObject:current_pv];
        [self.dequeuePhotoViews addObject:[self.currentPhotoViews firstObject]];
        [self.currentPhotoViews removeAllObjects];
        [self.currentPhotoViews addObject:current_pv];
        
        _currentOffsetX = current_pv.x;
    } else {
        // 容错处理 各种原因可能找不到当前cell
        [self didDismiss];
        return current_pv;
    }
    
    // 更新一个cell来适配下次滑动
    if (other_pv) {
        // 确定位置
        NSInteger other_pv_page = (current_pv.tag>_currentPhotoView.tag)?uPage+1:uPage-1;
        if ((other_pv_page>=0)&&(other_pv_page<_imageCount)) {
            // 更新cell图片信息
            [self updataPhotoView:other_pv atPage:other_pv_page];
        }
    }
    
    return current_pv;
}

- (void)updataPhotoView:(YTPhotoView *)photoView atPage:(NSInteger)page{
    photoView.transform = CGAffineTransformIdentity;
    // 计算位置
    CGRect scrollVF = self.scrollView.bounds;
    scrollVF.origin.x = (page*scrollVF.size.width);
    photoView.frame = scrollVF;
    photoView.tag = page;
    // 赋值图片信息
    photoView.photoInfo = [self photoInfoAtPage:page];
}

#pragma mark - 代理 & 手势
#pragma mark Photo Brower View DataSource Action
- (NSInteger)numberOfPhotos{ // 图片数量
    if (self.dataSource&&[self.dataSource respondsToSelector:@selector(numberOfPhotosInPhotoBrowseView:)]) {
        return [self.dataSource numberOfPhotosInPhotoBrowseView:self];
    }
    return 0;
}

- (YTPhotoInfo *)photoInfoAtPage:(NSInteger)page{ // 某个位置图片详细信息
    if (self.dataSource&&[self.dataSource respondsToSelector:@selector(photoBrowseView:photoInfoAtPage:)]) {
        return [self.dataSource photoBrowseView:self photoInfoAtPage:page];
    }
    return nil;
}

#pragma mark Photo Brower View Delegate Action
- (void)beginFrameAnimation{
    if ([self.delegate respondsToSelector:@selector(photoBrowseView:BeginFrameAnimationAtPage:)]) {
        CGRect rect = [self.delegate photoBrowseView:self BeginFrameAnimationAtPage:_currentPage];
        if (rect.size.width == 0) {
            [self initSuperView];
            return;
        }
        
        @autoreleasepool {
            CGFloat end_center_x = _currentPhotoView.center.x;
            CGFloat begin_center_x = _currentPhotoView.left+rect.origin.x+(rect.size.width+_setingModel.photosSpace)*0.5;
            CGPoint center = CGPointMake(begin_center_x, rect.origin.y+rect.size.height*0.5);
            _currentPhotoView.center = center;
            
            CGSize imageFitSize = _currentPhotoView.imageFitSize;
            _currentPhotoView.transform = CGAffineTransformMakeScale(rect.size.width/imageFitSize.width,rect.size.height/imageFitSize.height);
            [self initSuperView];
            self.alpha = 0.f;
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 1.f;
                _currentPhotoView.center = CGPointMake(end_center_x, self.superview.y);
                _currentPhotoView.transform = CGAffineTransformIdentity;
            }];
        }
    }else{
        [self initSuperView];
        
        self.alpha = 0.f;
        _currentPhotoView.alpha = 0.f;
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.f;
            _currentPhotoView.alpha = 1.f;
        }];
    }
}

- (NSTimeInterval)willDismissAfterDelay{ // 界面消失
    if (self.delegate&&[self.delegate respondsToSelector:@selector(photoBrowseView:willDismissAfterDelayAtPage:)]) {
        return [self.delegate photoBrowseView:self willDismissAfterDelayAtPage:_currentPage];
    }
    return 0;
}

- (void)endFrameAnimation{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(photoBrowseView:EndFrameAnimationAtPage:)]) {
        
        CGRect rect = [self.delegate photoBrowseView:self EndFrameAnimationAtPage:_currentPage];
        if (rect.size.width == 0) {
            [self didDismiss];
            return;
        }
        
        @autoreleasepool{
            CGFloat center_x = (self.width+_setingModel.photosSpace)*_currentPage+rect.origin.x+(rect.size.width+_setingModel.photosSpace)*0.5;
            CGPoint center = CGPointMake(center_x, rect.origin.y+rect.size.height*0.5);
            
            CGSize imageFitSize = _currentPhotoView.imageFitSize;
            CGFloat scaleWidth = rect.size.width/imageFitSize.width;
            CGFloat scaleHeight = rect.size.height/imageFitSize.height;
            
            [UIView animateWithDuration:0.25 animations:^{
                self.alpha = 0.f;
                _currentPhotoView.center = center;
                _currentPhotoView.transform = CGAffineTransformMakeScale(scaleWidth,scaleHeight);
            } completion:^(BOOL finished) {
                if (finished) {
                    [self didDismiss];
                }
            }];
        }
    }else{
        
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 0.f;
            _currentPhotoView.alpha = 0.f;
        } completion:^(BOOL finished) {
            if (finished) {
                [self didDismiss];
            }
        }];
    }
}

- (void)didDismiss{
    [self removeFromSuperview];
    
    if (_currentPhotoView) {
        _currentPhotoView.transform = CGAffineTransformIdentity;
        _currentPhotoView.alpha = 1.f;
    }
    
    if ([self.delegate respondsToSelector:@selector(photoBrowseView:didDismissAtPage:)]) {
        [self.delegate photoBrowseView:self didDismissAtPage:_currentPage];
    }
}

- (void)saveImage{
    self.saveImageBt.enabled = NO;
    [self.saveImageBt crossfadeWithDuration:1.5 completion:^{
        self.saveImageBt.enabled = YES;
    }];
    
    if ([self.delegate respondsToSelector:@selector(photoBrowseView:saveImageRequestAtPage:)]) {
        [self.delegate photoBrowseView:self saveImageRequestAtPage:_currentPage];
    }
}

#pragma mark Gesture Recognizer Action
- (void)tapAction:(UITapGestureRecognizer *)tap{ // 单击
    
    if (tap == nil) {
        [self didDismiss];
        return;
    }
    
    if (_currentPhotoView) {
        [_currentPhotoView shortcutZoomScale:1 andAnimated:YES];
    };
    
    NSTimeInterval delay = [self willDismissAfterDelay];
    [self performSelector:@selector(endFrameAnimation) withObject:nil afterDelay:delay];
}

- (void)doubleTapAction:(UITapGestureRecognizer *)tap{ // 双击
    if (_currentPhotoView) {
        [_currentPhotoView shortcutZoomAnimated:YES];
    }
}

// 上下滑动时 动画
- (void)panGestureRecognizeraction:(UIPanGestureRecognizer *)pan{
    YTPhotoView *photoView = _currentPhotoView;
    static CGPoint beganCenter;
    static CGFloat beganScale;
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            [photoView shortcutZoomScale:1.0 andAnimated:YES];
            beganCenter = photoView.center;
            beganScale = photoView.scale;
        }break;
        case UIGestureRecognizerStateChanged:{
            @autoreleasepool {
                CGPoint transPoint = [pan translationInView:self];
                
                CGFloat maxTransY = MAX(0, transPoint.y);
                CGPoint centerCell = CGPointMake(beganCenter.x+transPoint.x, beganCenter.y+transPoint.y);
                [photoView setCenter:centerCell];
                
                // 根据滑动距离来决定缩放比例 最高缩放原来比例的0.5倍
                CGFloat currentScale = (beganScale*self.height)/(self.height+fabs(maxTransY));
                photoView.transform = CGAffineTransformMakeScale(currentScale,currentScale);
                self.alpha = pow(currentScale, 3);//透明度 是缩放比的3次幂
            }
        }break;
            
        default:{
            CGPoint vPoint = [pan velocityInView:self];
            CGPoint transPoint = [pan translationInView:self];
            if ((vPoint.x > 100 | vPoint.y > 200)&&(transPoint.y > 25)) {
                [self endFrameAnimation];
                return;
            }
            
            [UIView animateWithDuration:0.15 animations:^{
                photoView.center = beganCenter;
                photoView.transform = CGAffineTransformIdentity;
                self.alpha = 1.0;
            }];
        }break;
    }
}

#pragma mark - Scroll View Delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!scrollView.isDragging) return;
    [self scrollViewDraggingScroll:scrollView];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    [self scrollViewDraggingScroll:scrollView];
    _currentOffsetX = scrollView.contentOffset.x;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    _currentOffsetX = scrollView.contentOffset.x;
}

#pragma mark - get && set
#pragma mark get
- (UIView *)backgroundView{
    if(!_backgroundView){
        UIView *backgroundView = [[UIView alloc]initWithFrame:self.bounds];
        backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:_backgroundView = backgroundView];
        [self sendSubviewToBack:_backgroundView];
    }
    return _backgroundView;
}

- (UIScrollView *)scrollView{
    if (!_scrollView) {
        CGRect frame = self.bounds;
        frame.size.width += _setingModel.photosSpace;
        UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:frame];
        scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        scrollView.center = CGPointMake(self.width*0.5, self.height*0.5);
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.showsVerticalScrollIndicator = NO;
        scrollView.alwaysBounceVertical = NO;
        scrollView.pagingEnabled = YES;
        scrollView.delegate = self;
        
        [self addSubview:_scrollView = scrollView];
    }
    return _scrollView;
}

- (UILabel *)pageLabel{
    if (!_pageLabel) {
        UILabel *pageLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, self.height-30, self.width, 20)];
        pageLabel.textColor = _setingModel.textColor;
        pageLabel.font = _setingModel.textFont;
        pageLabel.textAlignment = NSTextAlignmentCenter;
        pageLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:_pageLabel = pageLabel];
        if (_setingModel.isOpenSave) {
            [self addSubview:self.saveImageBt];
        }
    }
    return _pageLabel;
}

- (UIButton *)saveImageBt{
    if (!_saveImageBt) {
        CGRect frame = CGRectZero;
        frame.size = CGSizeMake(40, 20);
        frame.origin.x = self.width-frame.size.width-15;
        frame.origin.y = self.height-frame.size.height-10;
        UIButton *saveImageBt = [[UIButton alloc]initWithFrame:frame];
        [saveImageBt addTarget:self action:@selector(saveImage) forControlEvents:UIControlEventTouchUpInside];
        if (_setingModel.saveIcon.size.width>1) {
            [saveImageBt setImage:_setingModel.saveIcon forState:UIControlStateNormal];
        }else{
            saveImageBt.titleLabel.font = _setingModel.textFont;
            [saveImageBt setTitle:_setingModel.saveTitle forState:UIControlStateNormal];
            [saveImageBt setTitleColor:_setingModel.textColor forState:UIControlStateNormal];
        }
        _saveImageBt = saveImageBt;
    }
    return _saveImageBt;
}

- (NSMutableArray *)allPhotoViews{
    if (!_allPhotoViews) {
        _allPhotoViews = [NSMutableArray arrayWithCapacity:3];
    }
    return _allPhotoViews;
}

- (NSMutableArray *)dequeuePhotoViews{
    if (!_dequeuePhotoViews) {
        _dequeuePhotoViews = [NSMutableArray arrayWithCapacity:2];
    }
    return _dequeuePhotoViews;
}

- (NSMutableArray *)currentPhotoViews{
    if (!_currentPhotoViews) {
        _currentPhotoViews = [NSMutableArray arrayWithCapacity:1];
    }
    return _currentPhotoViews;
}

- (CGFloat)alpha{
    return self.backgroundView.alpha;
}

- (UIColor *)backgroundColor{
    return self.backgroundView.backgroundColor;
}

#pragma mark set
- (void)setAlpha:(CGFloat)alpha{
    self.backgroundView.alpha = alpha;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor{
    self.backgroundView.backgroundColor = backgroundColor;
}

@end
