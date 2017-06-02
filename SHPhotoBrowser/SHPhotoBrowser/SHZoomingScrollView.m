//
//  SHZoomingScrollView.m
//  SHPhotoBrowserDemo
//
//  Created by Liushannoon on 16/7/15.
//  Copyright © 2016年 LiuShannoon. All rights reserved.
//

#import "SHZoomingScrollView.h"
#import "UIView+SHExtension.h"
#import "SHPhotoBrowserConfig.h"
@interface SHZoomingScrollView () <UIScrollViewDelegate>

@property (nonatomic , strong) UIImageView  *photoImageView;

@end

@implementation SHZoomingScrollView

#pragma mark    -   set / get

- (UIImageView *)imageView
{
    return self.photoImageView;
}

- (UIImage *)currentImage
{
    return self.photoImageView.image;
}

- (UIImageView *)photoImageView
{
    if (_photoImageView == nil) {
        _photoImageView = [[UIImageView alloc] init];
    }
    
    return _photoImageView;
}


#pragma mark    -   initial UI

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

/**
 *  初始化
 */
- (void)initial
{
    self.showsVerticalScrollIndicator = NO;
    self.showsHorizontalScrollIndicator = NO;
    self.delegate = self;
    self.backgroundColor= [UIColor clearColor];
    self.photoImageView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.photoImageView];

    UITapGestureRecognizer *singleTapBackgroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTapBackgroundView:)];
    UITapGestureRecognizer *doubleTapBackgroundView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doubleTapBackgroundView:)];
    doubleTapBackgroundView.numberOfTapsRequired = 2;
    [singleTapBackgroundView requireGestureRecognizerToFail:doubleTapBackgroundView];
    [self addGestureRecognizer:singleTapBackgroundView];
    [self addGestureRecognizer:doubleTapBackgroundView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = self.photoImageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) { // 长图才会出现这种情况
        frameToCenter.origin.x = floor((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floor((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    // Center
    if (!CGRectEqualToRect(self.photoImageView.frame, frameToCenter)){
        self.photoImageView.frame = frameToCenter;
    }

}

#pragma mark    -   UIScrollViewDelegate
    
- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.photoImageView;
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    self.scrollEnabled = YES;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    self.userInteractionEnabled = YES;
}

#pragma mark    -   private method - 手势处理,缩放图片

- (void)singleTap:(UITapGestureRecognizer *)singleTap
{
    if (self.zoomingScrollViewdelegate && [self.zoomingScrollViewdelegate respondsToSelector:@selector(zoomingScrollView:singleTapDetected:)]) {
        [self.zoomingScrollViewdelegate zoomingScrollView:self singleTapDetected:singleTap];
    }
}

- (void)doubleTap:(UITapGestureRecognizer *)doubleTap
{
    [self handleDoubleTap:[doubleTap locationInView:doubleTap.view]];
}

- (void)handleDoubleTap:(CGPoint)point
{
    self.userInteractionEnabled = NO;
    CGRect zoomRect = [self zoomRectForScale:[self willBecomeZoomScale] withCenter:point];
    [self zoomToRect:zoomRect animated:YES];
}

/**
 *  计算要伸缩到的目的比例
 */
- (CGFloat)willBecomeZoomScale
{
    if (self.zoomScale > self.minimumZoomScale) {
        return self.minimumZoomScale;
    } else {
        return self.maximumZoomScale;
    }
}

- (CGRect)zoomRectForScale:(CGFloat)scale withCenter:(CGPoint)center
{
    CGFloat height = self.frame.size.height / scale;
    CGFloat width  = self.frame.size.width  / scale;
    CGFloat x = center.x - width * 0.5;
    CGFloat y = center.y - height * 0.5;
    return CGRectMake(x, y, width, height);
}

- (void)singleTapBackgroundView:(UITapGestureRecognizer *)singleTap
{
    if (self.zoomingScrollViewdelegate && [self.zoomingScrollViewdelegate respondsToSelector:@selector(zoomingScrollView:singleTapDetected:)]) {
        [self.zoomingScrollViewdelegate zoomingScrollView:self singleTapDetected:singleTap];
    }
}

- (void)doubleTapBackgroundView:(UITapGestureRecognizer *)doubleTap
{
// TODO 需要再优化这里的算法
    self.userInteractionEnabled = NO;
    CGPoint point = [doubleTap locationInView:doubleTap.view];
    CGFloat touchX = point.x;
    CGFloat touchY = point.y;
    touchX *= 1/self.zoomScale;
    touchY *= 1/self.zoomScale;
    touchX += self.contentOffset.x;
    touchY += self.contentOffset.y;
    [self handleDoubleTap:CGPointMake(touchX, touchY)];
}

- (void)resetZoomScale
{
    self.maximumZoomScale = 1.0;
    self.minimumZoomScale = 1.0;
}

#pragma mark    -   public method

/**
 *  显示图片
 *
 *  @param image 图片
 */
- (void)setShowImage:(UIImage *)image
{
    self.photoImageView.image = image;
    [self setMaxAndMinZoomScales];
    [self setNeedsLayout];
    self.progress = 1.0;
}

/**
 *  显示图片
 *
 *  @param url         图片的高清大图链接
 *  @param placeholder 占位的缩略图 / 或者是高清大图都可以
 */
- (void)setShowHighQualityImageWithURL:(NSURL *)url placeholderImage:(UIImage *)placeholder
{
    if (!url) {
        [self setShowImage:placeholder];
        self.progress = 1.0f;
        return;
    }
    // 使用PINRemoteImage
    PINCache *cache = [[PINRemoteImageManager sharedImageManager] pinCache];
    UIImage *showImage = [UIImage imageWithData:[cache objectFromDiskForKey:[url absoluteString]]];
      // 使用SDWebImage
    //UIImage *showImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:[url absoluteString]];
    if (showImage) {
        self.photoImageView.image = showImage;
        [self setMaxAndMinZoomScales];
        self.progress = 1.0f;
        return;
    }
    self.photoImageView.image = placeholder;
    [self setMaxAndMinZoomScales];
    __weak typeof(self) weakSelf = self;
    // 使用SDWebImage
//    [weakSelf.photoImageView sd_setImageWithURL:url placeholderImage:placeholder options:SDWebImageRetryFailed | SDWebImageLowPriority| SDWebImageHandleCookies progress:^(NSInteger receivedSize, NSInteger expectedSize) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if (expectedSize>0) {
//                // 修改进度
//                weakSelf.progress = (CGFloat)receivedSize / expectedSize ;
//            }
//            [self resetZoomScale];
//        });
//        
//    } completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//        if (error) {
//            [self setMaxAndMinZoomScales];
//            SHFormatLog(@"加载图片失败 , 图片链接imageURL = %@ , 检查是否开启允许HTTP请求",imageURL);
//        } else {
//            weakSelf.photoImageView.image = image;
//            [weakSelf.photoImageView setNeedsDisplay];
//            [UIView animateWithDuration:0.25 animations:^{
//                [weakSelf setMaxAndMinZoomScales];
//            }];
//        }
//    }];
     // 使用PINRemoteImage
    [self.photoImageView pin_setImageFromURL:url completion:^(PINRemoteImageManagerResult * _Nonnull result) {
        if (result.error) {
             [self setMaxAndMinZoomScales];
        }else{
            self.photoImageView.image = showImage;
            self.progress = 1.0f;
            [weakSelf.photoImageView setNeedsDisplay];
            [UIView animateWithDuration:0.25 animations:^{
                [weakSelf setMaxAndMinZoomScales];
            }];
        }
       
    }];
}

/**
 *  根据图片和屏幕比例关系,调整最大和最小伸缩比例
 */
- (void)setMaxAndMinZoomScales
{
    // self.photoImageView的初始位置
    UIImage *image = self.photoImageView.image;
    if (image == nil || image.size.height==0) {
        return;
    }
    CGFloat imageWidthHeightRatio = image.size.width / image.size.height;
    self.photoImageView.SH_width = SHScreenW;
    self.photoImageView.SH_height = SHScreenW / imageWidthHeightRatio;
    self.photoImageView.SH_x = 0;
    if (self.photoImageView.SH_height > SHScreenH) {
        self.photoImageView.SH_y = 0;
        self.scrollEnabled = YES;
    } else {
        self.photoImageView.SH_y = (SHScreenH - self.photoImageView.SH_height ) * 0.5;
        self.scrollEnabled = NO;
    }
    self.maximumZoomScale = MAX(SHScreenH / self.photoImageView.SH_height, 3.0);
    self.minimumZoomScale = 1.0;
    self.zoomScale = 1.0;
    self.contentSize = CGSizeMake(self.photoImageView.SH_width, MAX(self.photoImageView.SH_height, SHScreenH));
}

/**
 *  重用，清理资源
 */
- (void)prepareForReuse
{
    [self setMaxAndMinZoomScales];
    self.photoImageView.image = nil;
    self.hasLoadedImage = NO;
}

@end
