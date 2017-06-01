//
//  UIView+SHExtension.h
//  TopHot
//
//  Created by Liushannoon on 16/4/20.
//  Copyright © 2016年 Liushannoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#define SHScreenBounds [UIScreen mainScreen].bounds
#define SHScreenSize [UIScreen mainScreen].bounds.size
#define SHScreenW [UIScreen mainScreen].bounds.size.width
#define SHScreenH [UIScreen mainScreen].bounds.size.height
#define SH_autoSizeScaleX ([UIScreen mainScreen].bounds.size.width / 375)
#define SH_autoSizeScaleY ([UIScreen mainScreen].bounds.size.height / 667)

#define SHDeprecated(instead) NS_DEPRECATED(2_0, 2_0, 2_0, 2_0, instead)
#define SHKeyWindow [UIApplication sharedApplication].windows.firstObject

/**
 *  动画类型
 */
typedef NS_ENUM(NSUInteger, SHAnimationType){
    /**
     *  弹性动画放大
     */
    SHAnimationTypeToBigger = 1,
    /**
     *  缩小的弹性动画
     */
    SHAnimationTypeToSmaller = 2
};

@interface UIView (SHExtension)

@property (nonatomic, assign) CGFloat height SHDeprecated("请使用SH_height");
@property (nonatomic, assign) CGFloat width SHDeprecated("请使用SH_width");
@property (nonatomic, assign) CGFloat x  SHDeprecated("请使用SH_x");
@property (nonatomic, assign) CGFloat y SHDeprecated("请使用SH_y");
@property (nonatomic, assign) CGFloat centerX SHDeprecated("请使用SH_centerX");
@property (nonatomic, assign) CGFloat centerY SHDeprecated("请使用SH_centerY");

@property (nonatomic, assign) CGFloat SH_height;
@property (nonatomic, assign) CGFloat SH_width;
@property (nonatomic, assign) CGFloat SH_x;
@property (nonatomic, assign) CGFloat SH_y;
@property (nonatomic, assign) CGSize SH_size;
@property (nonatomic, assign) CGFloat SH_centerX;
@property (nonatomic, assign) CGFloat SH_centerY;

/**
 * 判断一个控件是否真正显示在主窗口
 */
- (BOOL)SH_isShowingOnKeyWindow;

/**
 *  加载xibview
 */
+ (instancetype)SH_viewFromXib ;

/**
 *  显示一个5*5点的红色提醒圆点
 *
 *  @param redX x坐标
 *  @param redY y坐标
 */
- (void)SH_showRedTipViewInRedX:(CGFloat)redX redY:(CGFloat)redY SHDeprecated("请使用其他同类方法");
/**
 *  在view上面绘制一个指定width宽度的红色提醒圆点
 *
 *  @param redX  x坐标
 *  @param redY  y坐标
 *  @param width 宽度
 */
- (void)SH_showRedTipViewInRedX:(CGFloat)redX redY:(CGFloat)redY redTipViewWidth:(CGFloat)width ;
/**
 *  在view上面绘制一个指定width宽度的 指定颜色的提醒圆点
 *
 *  @param redX  x坐标
 *  @param redY  y坐标
 *  @param width 圆点的直径
 *  @param backgroundColor 圆点的颜色
 */
- (void)SH_showRedTipViewInRedX:(CGFloat)redX redY:(CGFloat)redY redTipViewWidth:(CGFloat)width backgroundColor:(UIColor *)backgroundColor;
/**
 *  显示一个5*5点的红色提醒圆点
 *
 *  @param redX x坐标
 *  @param redY y坐标
 *  @param numberCount 展示的数字
 */
- (void)SH_showRedTipViewWithNumberCountInRedX:(CGFloat)redX redY:(CGFloat)redY numberCount:(NSInteger)numberCount;

/**
 *  隐藏红色提醒圆点
 */
- (void)SH_hideRedTipView;

/**
 *  类方法,对指定的layer进行弹性动画
 *
 *  @param layer 进行动画的图层
 *  @param type  动画类型
 */
+ (void)SH_showOscillatoryAnimationWithLayer:(CALayer *)layer type:(SHAnimationType)type;
/**
 *  给视图添加虚线边框
 *
 *  @param lineWidth  线宽
 *  @param lineMargin 每条虚线之间的间距
 *  @param lineLength 每条虚线的长度
 *  @param lineColor 每条虚线的颜色
 */
- (void)SH_addDottedLineBorderWithLineWidth:(CGFloat)lineWidth lineMargin:(CGFloat)lineMargin lineLength:(CGFloat)lineLength lineColor:(UIColor *)lineColor;

@end
