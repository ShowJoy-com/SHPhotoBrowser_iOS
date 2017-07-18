//
//  SHPhotoBrowser.m
//  SHPhotoBrowserDemo
//
//  Created by Liushannoon on 16/7/16.
//  Copyright © 2016年 LiuShannoon. All rights reserved.
//

#import "SHPhotoBrowser.h"
#import "SHZoomingScrollView.h"
#import "SHPhotoBrowserConfig.h"
#import "UIView+SHExtension.h"
@interface SHPhotoBrowser () <SHZoomingScrollViewDelegate , UIScrollViewDelegate,UIActionSheetDelegate>

/**
 *  存放所有图片的容器
 */
@property (nonatomic , strong) UIScrollView  *scrollView;
/**
 *   保存图片的过程指示菊花
 */
@property (nonatomic , strong) UIActivityIndicatorView  *indicatorView;
/**
 *   保存图片的结果指示label
 */
@property (nonatomic , strong) UILabel *savaImageTipLabel;
/**
 *  正在使用的SHZoomingScrollView对象集
 */
@property (nonatomic , strong) NSMutableSet  *visibleZoomingScrollViews;
/**
 *  循环利用池中的SHZoomingScrollView对象集,用于循环利用
 */
@property (nonatomic , strong) NSMutableSet  *reusableZoomingScrollViews;
/**
 *  index label
 */
@property (nonatomic , strong) UILabel  *indeSHabel;
/**
 *  保存按钮
 */
@property (nonatomic , strong) UIButton *saveButton;
/**
 *  ActionSheet的otherbuttontitles
 */
@property (nonatomic , strong) NSArray  *actionOtherButtonTitles;
/**
 *  ActionSheet的title
 */
@property (nonatomic , strong) NSString  *actionSheetTitle;
/**
 *  actionSheet的取消按钮title
 */
@property (nonatomic , strong) NSString  *actionSheetCancelTitle;
/**
 *  actionSheet的高亮按钮title
 */
@property (nonatomic , strong) NSString  *actionSheetDeleteButtonTitle;
@property (nonatomic, assign) CGSize pageControlDotSize;
@property(nonatomic, strong) NSArray *images;
/**
 *  保存图片提示
 */
@property(nonatomic,strong)UILabel       * mlableShowSave;

@end

@implementation SHPhotoBrowser

#pragma mark    -   set / get

- (UILabel *)savaImageTipLabel
{
    if (_savaImageTipLabel == nil) {
        _savaImageTipLabel = [[UILabel alloc] init];
        _savaImageTipLabel.textColor = [UIColor whiteColor];
        _savaImageTipLabel.backgroundColor = [UIColor colorWithRed:0.1f green:0.1f blue:0.1f alpha:0.90f];
        _savaImageTipLabel.textAlignment = NSTextAlignmentCenter;
        _savaImageTipLabel.font = [UIFont boldSystemFontOfSize:17];
    }
    return _savaImageTipLabel;
}

- (UIActivityIndicatorView *)indicatorView
{
    if (!_indicatorView) {
        _indicatorView = [[UIActivityIndicatorView alloc] init];
        _indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
    }
    return _indicatorView;
}

- (UIImage *)placeholderImage
{
    if (!_placeholderImage) {
        _placeholderImage = [self SH_imageWithColor:[UIColor clearColor] size:CGSizeMake(400, 400)];
    }
    return _placeholderImage;
}


-(UIImage *)SH_imageWithColor:(UIColor *)color size:(CGSize)size
{
    if (size.width <= 0  ) {
        size = CGSizeMake(3, 3);
    }
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark    -   initial

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self initial];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self initial];
    }
    return self;
}

- (void)initial
{
    self.visibleZoomingScrollViews = [[NSMutableSet alloc] init];
    self.reusableZoomingScrollViews = [[NSMutableSet alloc] init];
    [self placeholderImage];
    
    _pageControlAliment = SHPhotoBrowserPageControlAlimentCenter;
    _showPageControl = YES;
    _pageControlDotSize = CGSizeMake(10, 10);
    _pageControlStyle = SHPhotoBrowserPageControlStyleAnimated;
    _hidesForSinglePage = YES;
    _currentPageDotColor = [UIColor whiteColor];
    _pageDotColor = [UIColor lightGrayColor];
    _browserStyle = SHPhotoBrowserStylePageControl;
    
    self.currentImageIndex = 0;
    self.imageCount = 0;
}

- (void)iniaialUI
{
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self setUpScrollView];
    [self setUpToolBars];
    [self showFirstImage];
    [self updatePageControlIndex];
    [self initShowLabelSave];
}

- (void)setUpScrollView
{
    CGRect rect = self.bounds;
    rect.size.width += SHPhotoBrowserImageViewMargin;
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.frame = rect;
    self.scrollView.SH_x = 0;
    self.scrollView.delegate = self;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.contentSize = CGSizeMake((self.scrollView.frame.size.width) * self.imageCount, 0);
    [self addSubview:self.scrollView];
    self.scrollView.contentOffset = CGPointMake(self.currentImageIndex * (self.scrollView.frame.size.width), 0);
    if (self.currentImageIndex == 0) { // 修复bug , 如果刚进入的时候是0,不会调用scrollViewDidScroll:方法,不会展示第一张图片
        [self showPhotos];
    }
}



- (void)setUpToolBars
{
    UILabel *indeSHabel = [[UILabel alloc] init];
    indeSHabel.textAlignment = NSTextAlignmentCenter;
    if (_browserViewStyle==SHPhotoBrowserViewStyleBlack) {
        indeSHabel.bounds = CGRectMake(0, 0, 80, 30);
        indeSHabel.SH_centerX = self.SH_width * 0.5;
        indeSHabel.SH_centerY = SHScreenH-20-35;
        indeSHabel.textColor = [UIColor whiteColor];
        indeSHabel.font = [UIFont systemFontOfSize:18];
        indeSHabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
        indeSHabel.layer.cornerRadius = indeSHabel.bounds.size.height * 0.5;
        indeSHabel.clipsToBounds = YES;
    }else if (_browserViewStyle==SHPhotoBrowserViewStyleWhite){
        indeSHabel.bounds = CGRectMake(0, 0, 25, 25);
        indeSHabel.SH_centerX = self.SH_width * 0.5;
        indeSHabel.SH_centerY = SHScreenH-25-35;
        indeSHabel.textColor = [UIColor whiteColor];
        indeSHabel.font = [UIFont systemFontOfSize:10];
        indeSHabel.backgroundColor = RGBColor(204, 204, 204);
        indeSHabel.layer.cornerRadius = indeSHabel.bounds.size.height * 0.5;
        indeSHabel.clipsToBounds = YES;
    }
    [self addSubview:indeSHabel];
    self.indeSHabel = indeSHabel;
}

/**
 * 初始化保存提示
 */
-(void)initShowLabelSave{
    if (_browserViewStyle==SHPhotoBrowserViewStyleBlack) {
        NSString * mstrtext = @"长按屏幕即可保存图片";
        UILabel * mlableIndex = [[UILabel alloc] initWithFrame:CGRectMake(0, 64, SHScreenH, 20)];
        mlableIndex.font=[UIFont systemFontOfSize:14];
        mlableIndex.SH_centerX = self.SH_width * 0.5;
        mlableIndex.text=mstrtext;
        mlableIndex.textColor=[UIColor whiteColor];
        mlableIndex.textAlignment=NSTextAlignmentCenter;
        [self addSubview:mlableIndex];
        _mlableShowSave = mlableIndex;
        [self performSelector:@selector(CancelSaveShow) withObject:@"" afterDelay:3.0];
    }
}

- (void)dealloc
{
    [self.reusableZoomingScrollViews removeAllObjects];
    [self.visibleZoomingScrollViews removeAllObjects];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _savaImageTipLabel.layer.cornerRadius = 5;
    _savaImageTipLabel.clipsToBounds = YES;
    [_savaImageTipLabel sizeToFit];
    _savaImageTipLabel.SH_height = 30;
    _savaImageTipLabel.SH_width += 20;
    _savaImageTipLabel.center = self.center;

    _indicatorView.center = self.center;
}

#pragma mark    -   private method

- (UIWindow *)findTheMainWindow
{
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal);
        BOOL windowSizeIsEqualToScreen = (window.SH_width == SHScreenW && window.SH_height == SHScreenH);
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowSizeIsEqualToScreen) {
            return window;
        }
    }
    
    SHPBLog(@"SHPhotoBrowser在当前工程未匹配到合适的window,请根据工程架构酌情调整此方法,匹配最优窗口");
    if (SHPhotoBrowserDebug) {
        NSAssert(false, @"SHPhotoBrowser在当前工程未匹配到window,请根据工程架构酌情调整findTheMainWindow方法,匹配最优窗口");
    }
    
    UIWindow * delegateWindow = [[[UIApplication sharedApplication] delegate] window];
    return delegateWindow;
}

#pragma mark    -   private -- 长按图片相关

- (void)longPress:(UILongPressGestureRecognizer *)longPress
{
    SHZoomingScrollView *currentZoomingScrollView = [self zoomingScrollViewAtIndex:self.currentImageIndex];
    if (longPress.state == UIGestureRecognizerStateBegan) {
        SHPBLog(@"UIGestureRecognizerStateBegan , currentZoomingScrollView.progress %f",currentZoomingScrollView.progress);
        
        [self initActionSheet];

        if (self.actionOtherButtonTitles.count <= 0 && self.actionSheetDeleteButtonTitle.length <= 0 && self.actionSheetTitle.length <= 0) {
            return;
        }
        
        
    }
}
/**
 *  初始化选择组件
 */
-(void)initActionSheet{
    UIActionSheet *actionSheet = [[UIActionSheet alloc]
                                  initWithTitle:nil
                                  delegate:self
                                  cancelButtonTitle:@"取消"
                                  destructiveButtonTitle:nil
                                  otherButtonTitles:@"保存图片",nil];
    actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
    [actionSheet showInView:self];
}
/**
 *  选择框点击事件
 */
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    switch (buttonIndex) {
        case 0:
            [self saveImage];
            if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowserCurrentImageIndex:)]) {
                [self.delegate photoBrowserCurrentImageIndex:self.currentImageIndex];
            }

            break;
        default:
            break;
    }
}
-(void)CancelSaveShow{
    _mlableShowSave.hidden=YES;
}


#pragma mark    -   private -- save image

- (void)saveImage
{
    SHZoomingScrollView *zoomingScrollView = [self zoomingScrollViewAtIndex:self.currentImageIndex];
    if (zoomingScrollView.progress < 1.0) {
        self.savaImageTipLabel.text = SHPhotoBrowserLoadingImageText;
        [self addSubview:self.savaImageTipLabel];
        [self.savaImageTipLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
        return;
    }
    if (zoomingScrollView.currentImage && [zoomingScrollView.currentImage isKindOfClass:[UIImage class]]) {
        UIImageWriteToSavedPhotosAlbum(zoomingScrollView.currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        [self addSubview:self.indicatorView];
        [self.indicatorView startAnimating];
    }
    
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo;
{
    [self.indicatorView removeFromSuperview];
    [self addSubview:self.savaImageTipLabel];
    if (error) {
        self.savaImageTipLabel.text = SHPhotoBrowserSaveImageFailText;
    } else {
        self.savaImageTipLabel.text = SHPhotoBrowserSaveImageSuccessText;
    }
    [self.savaImageTipLabel performSelector:@selector(removeFromSuperview) withObject:nil afterDelay:1.0];
}

#pragma mark    -   private ---loadimage

- (void)showPhotos
{
    // 只有一张图片
    if (self.imageCount == 1) {
        [self setUpImageForZoomingScrollViewAtIndex:0];
        return;
    }
    
    CGRect visibleBounds = self.scrollView.bounds;
    NSInteger firstIndex = floor((CGRectGetMinX(visibleBounds)) / CGRectGetWidth(visibleBounds));
    NSInteger lastIndex  = floor((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
    
    if (firstIndex < 0) {
        firstIndex = 0;
    }
    if (firstIndex >= self.imageCount) {
        firstIndex = self.imageCount - 1;
    }
    if (lastIndex < 0){
        lastIndex = 0;
    }
    if (lastIndex >= self.imageCount) {
        lastIndex = self.imageCount - 1;
    }
    
    // 回收不再显示的zoomingScrollView
    NSInteger zoomingScrollViewIndex = 0;
    for (SHZoomingScrollView *zoomingScrollView in self.visibleZoomingScrollViews) {
        zoomingScrollViewIndex = zoomingScrollView.tag - 100;
        if (zoomingScrollViewIndex < firstIndex || zoomingScrollViewIndex > lastIndex) {
            [self.reusableZoomingScrollViews addObject:zoomingScrollView];
            [zoomingScrollView prepareForReuse];
            [zoomingScrollView removeFromSuperview];
        }
    }
    
    // _visiblePhotoViews 减去 _reusablePhotoViews中的元素
    [self.visibleZoomingScrollViews minusSet:self.reusableZoomingScrollViews];
    while (self.reusableZoomingScrollViews.count > 2) { // 循环利用池中最多保存两个可以用对象
        [self.reusableZoomingScrollViews removeObject:[self.reusableZoomingScrollViews anyObject]];
    }
    
    // 展示图片
    for (NSInteger index = firstIndex; index <= lastIndex; index++) {
        if (![self isShowingZoomingScrollViewAtIndex:index]) {
            [self setUpImageForZoomingScrollViewAtIndex:index];
        }
    }
}

/**
 *  判断指定的某个位置图片是否在显示
 */
- (BOOL)isShowingZoomingScrollViewAtIndex:(NSInteger)index
{
    for (SHZoomingScrollView* view in self.visibleZoomingScrollViews) {
        if ((view.tag - 100) == index) {
            return YES;
        }
    }
    return NO;
}

/**
 *  获取指定位置的SHZoomingScrollView , 三级查找,正在显示的池,回收池,创建新的并赋值
 *
 *  @param index 指定位置索引
 */
- (SHZoomingScrollView *)zoomingScrollViewAtIndex:(NSInteger)index
{
    for (SHZoomingScrollView* zoomingScrollView in self.visibleZoomingScrollViews) {
        if ((zoomingScrollView.tag - 100) == index) {
            return zoomingScrollView;
        }
    }
    SHZoomingScrollView* zoomingScrollView = [self dequeueReusableZoomingScrollView];
    [self setUpImageForZoomingScrollViewAtIndex:index];
    return zoomingScrollView;
}

/**
 *   加载指定位置的图片
 */
- (void)setUpImageForZoomingScrollViewAtIndex:(NSInteger)index
{
    SHZoomingScrollView *zoomingScrollView = [self dequeueReusableZoomingScrollView];
    zoomingScrollView.zoomingScrollViewdelegate = self;
    [zoomingScrollView addGestureRecognizer:[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)]];
    zoomingScrollView.tag = 100 + index;
    zoomingScrollView.frame = CGRectMake((self.scrollView.SH_width) * index, 0, self.SH_width, self.SH_height);
    self.currentImageIndex = index;
    if (zoomingScrollView.hasLoadedImage == NO) {
        if ([self highQualityImageURLForIndex:index]) { // 如果提供了高清大图数据源,就去加载
            [zoomingScrollView setShowHighQualityImageWithURL:[self highQualityImageURLForIndex:index] placeholderImage:[self placeholderImageForIndex:index]];
        } else if ([self assetForIndex:index]) {
            ALAsset *asset = [self assetForIndex:index];
            CGImageRef imageRef = asset.defaultRepresentation.fullScreenImage;
            [zoomingScrollView setShowImage:[UIImage imageWithCGImage:imageRef]];
            CGImageRelease(imageRef);
        } else {
            [zoomingScrollView setShowImage:[self placeholderImageForIndex:index]];
        }
        zoomingScrollView.hasLoadedImage = YES;
    }
    
    [self.visibleZoomingScrollViews addObject:zoomingScrollView];
    [self.scrollView addSubview:zoomingScrollView];
}

/**
 *  从缓存池中获取一个SHZoomingScrollView对象
 */
- (SHZoomingScrollView *)dequeueReusableZoomingScrollView
{
    SHZoomingScrollView *photoView = [self.reusableZoomingScrollViews anyObject];
    if (photoView) {
        [self.reusableZoomingScrollViews removeObject:photoView];
    } else {
        photoView = [[SHZoomingScrollView alloc] init];
    }
    return photoView;
}

/**
 *  获取指定位置的占位图片,和外界的数据源交互
 */
- (UIImage *)placeholderImageForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:placeholderImageForIndex:)]) {
        return [self.datasource photoBrowser:self placeholderImageForIndex:index];
    } else if(self.images.count>index) {
        if ([self.images[index] isKindOfClass:[UIImage class]]) {
            return self.images[index];
        } else {
            return self.placeholderImage;
        }
    }
    return self.placeholderImage;
}

/**
 *  获取指定位置的高清大图URL,和外界的数据源交互
 */
- (NSURL *)highQualityImageURLForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:highQualityImageURLForIndex:)]) {
        NSURL *url = [self.datasource photoBrowser:self highQualityImageURLForIndex:index];
        if (!url) {
            SHPBLog(@"高清大图URL数据 为空,请检查代码 , 图片索引:%zd",index);
            return nil;
        }
        if ([url isKindOfClass:[NSString class]]) {
            url = [NSURL URLWithString:(NSString *)url];
        }
        if (![url isKindOfClass:[NSURL class]]) {
            SHPBLog(@"高清大图URL数据有问题,不是NSString也不是NSURL , 错误数据:%@ , 图片索引:%zd",url,index);
        }
//        NSAssert([url isKindOfClass:[NSURL class]], @"高清大图URL数据有问题,不是NSString也不是NSURL");
        return url;
    } else if(self.images.count>index) {
        if ([self.images[index] isKindOfClass:[NSURL class]]) {
            return self.images[index];
        } else if ([self.images[index] isKindOfClass:[NSString class]]) {
            NSURL *url = [NSURL URLWithString:self.images[index]];
            return url;
        } else {
            return nil;
        }
    }
    return nil;
}

/**
 *  获取指定位置的 ALAsset,获取图片
 */
- (ALAsset *)assetForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:assetForIndex:)]) {
        return [self.datasource photoBrowser:self assetForIndex:index];
    } else if (self.images.count > index) {
        if ([self.images[index] isKindOfClass:[ALAsset class]]) {
            return self.images[index];
        } else {
            return nil;
        }
    }
    return nil;
}

/**
 *  获取多图浏览,指定位置图片的UIImageView视图,用于做弹出放大动画和回缩动画
 */
- (UIView *)sourceImageViewForIndex:(NSInteger)index
{
    if (self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
        return [self.datasource photoBrowser:self sourceImageViewForIndex:index];
    }
    return nil;
}

/**
 *  第一个展示的图片 , 点击图片,放大的动画就是从这里来的
 */
- (void)showFirstImage
{
    // 获取到用户点击的那个UIImageView对象,进行坐标转化
    CGRect startRect;
    if (self.sourceImageView) {
        
    } else if(self.datasource && [self.datasource respondsToSelector:@selector(photoBrowser:sourceImageViewForIndex:)]) {
        self.sourceImageView = [self.datasource photoBrowser:self sourceImageViewForIndex:self.currentImageIndex];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.alpha = 1.0;
        }];
        SHPBLog(@"需要提供源视图才能做弹出/退出图片浏览器的缩放动画");
        return;
    }
    startRect = [self.sourceImageView.superview convertRect:self.sourceImageView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.image = [self placeholderImageForIndex:self.currentImageIndex];
    tempView.frame = startRect;
    [self addSubview:tempView];
    
    CGRect targetRect; // 目标frame
    UIImage *image = self.sourceImageView.image;
    
//TODO 完善image为空的闪退
    if (image == nil) {
        SHPBLog(@"需要提供源视图才能做弹出/退出图片浏览器的缩放动画");
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    CGFloat width = SHScreenW;
    CGFloat height = SHScreenW / imageWidthHeightRatio;
    CGFloat x = 0;
    CGFloat y;
    if (height > SHScreenH) {
        y = 0;
    } else {
        y = (SHScreenH - height ) * 0.5;
    }
    targetRect = CGRectMake(x, y, width, height);
    self.scrollView.hidden = YES;
    self.alpha = 1.0;
    tempView.frame = targetRect;
    // 动画修改图片视图的frame , 居中同时放大
    [UIView animateWithDuration:SHPhotoBrowserShowImageAnimationDuration animations:^{
        tempView.frame = targetRect;
    } completion:^(BOOL finished) {
        [tempView removeFromSuperview];
        self.scrollView.hidden = NO;
    }];
}

#pragma mark    -   SHZoomingScrollViewDelegate

/**
 *  单击图片,退出浏览
 */
- (void)zoomingScrollView:(SHZoomingScrollView *)zoomingScrollView singleTapDetected:(UITapGestureRecognizer *)singleTap
{
    [UIView animateWithDuration:0.15 animations:^{
        self.savaImageTipLabel.alpha = 0.0;
        self.indicatorView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.savaImageTipLabel removeFromSuperview];
        [self.indicatorView removeFromSuperview];
    }];
    NSInteger currentIndex = zoomingScrollView.tag - 100;
    UIView *sourceView = [self sourceImageViewForIndex:currentIndex];
    if (sourceView == nil) {
        [self dismiss];
        return;
    }
    self.scrollView.hidden = YES;
    self.indeSHabel.hidden = YES;
    self.saveButton.hidden = YES;

    CGRect targetTemp = [sourceView.superview convertRect:sourceView.frame toView:self];
    
    UIImageView *tempView = [[UIImageView alloc] init];
    tempView.contentMode = sourceView.contentMode;
    tempView.clipsToBounds = YES;
    tempView.image = zoomingScrollView.currentImage;
    tempView.frame = CGRectMake( - zoomingScrollView.contentOffset.x + zoomingScrollView.imageView.SH_x,  - zoomingScrollView.contentOffset.y + zoomingScrollView.imageView.SH_y, zoomingScrollView.imageView.SH_width, zoomingScrollView.imageView.SH_height);
    [self addSubview:tempView];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [UIView animateWithDuration:SHPhotoBrowserHideImageAnimationDuration animations:^{
        tempView.frame = targetTemp;
        self.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self showPhotos];
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentImageIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updatePageControlIndex];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger pageNum = floor((scrollView.contentOffset.x + scrollView.bounds.size.width * 0.5) / scrollView.bounds.size.width);
    self.currentImageIndex = pageNum == self.imageCount ? pageNum - 1 : pageNum;
    [self updatePageControlIndex];
}
/**
 *  修改图片指示索引label
 */
- (void)updatePageControlIndex
{
    /*
    //1张图片不显示索引
    if (self.imageCount == 1 && self.hidesForSinglePage == YES) {
        self.indeSHabel.hidden = YES;
        return;
    }
     */
    if (_browserViewStyle==SHPhotoBrowserViewStyleBlack) {
        NSString *title = [NSString stringWithFormat:@"%zd / %zd",self.currentImageIndex+1,self.imageCount];
        self.indeSHabel.text = title;
    }else if (_browserViewStyle==SHPhotoBrowserViewStyleWhite){
        NSString *title = [NSString stringWithFormat:@"%zd/%zd",self.currentImageIndex+1,self.imageCount];
        self.indeSHabel.text = title;
    }

  
}

#pragma mark    -   public method

/**
 *  快速创建并进入图片浏览器
 *
 *  @param currentImageIndex 开始展示的图片索引
 *  @param imageCount        图片数量
 *  @param datasource        数据源
 *
 */
+ (instancetype)showPhotoBrowserWithCurrentImageIndex:(NSInteger)currentImageIndex imageCount:(NSUInteger)imageCount datasource:(id<SHPhotoBrowserDatasource>)datasource
{
    SHPhotoBrowser *browser = [[SHPhotoBrowser alloc] init];
    browser.imageCount = imageCount;
    browser.currentImageIndex = currentImageIndex;
    browser.datasource = datasource;
    [browser show];
    return browser;
}


- (void)show
{
    if (_browserViewStyle==SHPhotoBrowserViewStyleBlack) {
        self.backgroundColor=SHPhotoBrowserBackgrounColor;
    }else if (_browserViewStyle==SHPhotoBrowserViewStyleWhite){
        self.backgroundColor=[UIColor whiteColor];
    }
    if (self.imageCount <= 0) {
        return;
    }
    if (self.currentImageIndex >= self.imageCount) {
        self.currentImageIndex = self.imageCount - 1;
    }
    if (self.currentImageIndex < 0) {
        self.currentImageIndex = 0;
    }
    UIWindow *window = [self findTheMainWindow];
    
    self.frame = window.bounds;
    self.alpha = 1.0;
    [window addSubview:self];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    [self iniaialUI];
}

/**
 *  退出
 */
- (void)dismiss
{
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
    [UIView animateWithDuration:SHPhotoBrowserHideImageAnimationDuration animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelPhotoBrowser)]) {
        [self.delegate cancelPhotoBrowser];
    }
}

/**
 *  初始化底部ActionSheet弹框数据
 *
 *  @param title                  ActionSheet的title
 *  @param delegate               SHPhotoBrowserDelegate
 *  @param cancelButtonTitle      取消按钮文字
 *  @param deleteButtonTitle      删除按钮文字
 *  @param otherButtonTitles      其他按钮数组
 */
- (void)setActionSheetWithTitle:(nullable NSString *)title delegate:(nullable id<SHPhotoBrowserDelegate>)delegate cancelButtonTitle:(nullable NSString *)cancelButtonTitle deleteButtonTitle:(nullable NSString *)deleteButtonTitle otherButtonTitles:(nullable NSString *)otherButtonTitle, ...
{
    NSMutableArray *otherButtonTitlesArray = [NSMutableArray array];
    NSString *buttonTitle;
    va_list argumentList;
    if (otherButtonTitle) {
        [otherButtonTitlesArray addObject:otherButtonTitle];
        va_start(argumentList, otherButtonTitle);
        while ((buttonTitle = va_arg(argumentList, id))) {
            [otherButtonTitlesArray addObject:buttonTitle];
        }
        va_end(argumentList);
    }
    self.actionOtherButtonTitles = otherButtonTitlesArray;
    self.actionSheetTitle = title;
    self.actionSheetCancelTitle = cancelButtonTitle;
    self.actionSheetDeleteButtonTitle = deleteButtonTitle;
    if (delegate) {
        self.delegate = delegate;
    }
}

/**
 *  保存当前展示的图片
 */
- (void)saveCurrentShowImage
{
    [self saveImage];
}

#pragma mark    -   public method  -->  SHPhotoBrowser简易使用方式:一行代码展示

/**
 一行代码展示(在某些使用场景,不需要做很复杂的操作,例如不需要长按弹出actionSheet,从而不需要实现数据源方法和代理方法,那么可以选择这个方法,直接传数据源数组进来,框架内部做处理)
 
 @param images            图片数据源数组(,内部可以是UIImage/NSURL网络图片地址/ALAsset)
 @param currentImageIndex 展示第几张
 
 @return SHPhotoBrowser实例对象
 */
+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex
{
    if (images.count <=0 || images ==nil) {
        SHPBLog(@"一行代码展示图片浏览的方法,传入的数据源为空,不进入图片浏览,请检查传入数据源");
        return nil;
    }
    SHPhotoBrowser *browser = [[SHPhotoBrowser alloc] init];
    browser.imageCount = images.count;
    browser.currentImageIndex = currentImageIndex;
    browser.browserViewStyle=SHPhotoBrowserViewStyleBlack;
    browser.images = images;
    [browser show];
    return browser;
}

+ (instancetype)showPhotoBrowserWithImages:(NSArray *)images currentImageIndex:(NSInteger)currentImageIndex withStyle:(SHPhotoBrowserViewStyle)style
{
    if (images.count <=0 || images ==nil) {
        SHPBLog(@"一行代码展示图片浏览的方法,传入的数据源为空,不进入图片浏览,请检查传入数据源");
        return nil;
    }
    SHPhotoBrowser *browser = [[SHPhotoBrowser alloc] init];
    browser.imageCount = images.count;
    browser.currentImageIndex = currentImageIndex;
    browser.images = images;
    browser.browserViewStyle=style;
    [browser show];
    return browser;
}

@end
