//
//  SHPhotoBrowserConfig.h
//  SHPhotoBrowserDemo
//
//  Created by Liushannoon on 16/7/16.
//  Copyright © 2016年 LiuShannoon. All rights reserved.
//

#import "SHPhotoBrowserTypeDefine.h"
#import <PINRemoteImage/PINImageView+PINRemoteImage.h>

#define SHPhotoBrowserDebug 1
//是否开启断言调试模式
#define IsOpenAssertDebug 1

/**
 *  进度视图类型类型
 */
typedef NS_ENUM(NSUInteger, SHProgressViewMode){
    /**
     *  圆环形
     */
    SHProgressViewModeLoopDiagram = 1,
    /**
     *  圆饼型
     */
    SHProgressViewModePieDiagram = 2
};

// 图片保存成功提示文字
#define SHPhotoBrowserSaveImageSuccessText @" ^_^ 保存成功 ";
// 图片保存失败提示文字
#define SHPhotoBrowserSaveImageFailText @" >_< 保存失败 ";
// 网络图片加载失败的提示文字
#define SHPhotoBrowserLoadNetworkImageFail @">_< 图片加载失败"
#define SHPhotoBrowserLoadingImageText @" >_< 图片加载中,请稍后 ";

// browser背景颜色
#define SHPhotoBrowserBackgrounColor [UIColor colorWithRed:0 green:0 blue:0 alpha:0.95]
// browser 图片间的margin
#define SHPhotoBrowserImageViewMargin 10
// browser中显示图片动画时长
#define SHPhotoBrowserShowImageAnimationDuration 0.1f
// browser中显示图片动画时长
#define SHPhotoBrowserHideImageAnimationDuration 0.1f

// 图片下载进度指示进度显示样式（SHProgressViewModeLoopDiagram 环形，SHProgressViewModePieDiagram 饼型）
#define SHProgressViewProgressMode SHProgressViewModeLoopDiagram
// 图片下载进度指示器背景色
#define SHProgressViewBackgroundColor [UIColor clearColor]
// 图片下载进度指示器圆环/圆饼颜色
#define SHProgressViewStrokeColor [UIColor whiteColor]
// 图片下载进度指示器内部控件间的间距
#define SHProgressViewItemMargin 10
// 圆环形图片下载进度指示器 环线宽度
#define SHProgressViewLoopDiagramLineWidth 8





#define SHPBLog(...) SHFormatLog(__VA_ARGS__)

#if SHPhotoBrowserDebug
#define SHFormatLog(...)\
{\
NSString *string = [NSString stringWithFormat:__VA_ARGS__];\
NSLog(@"\n===========================\n===========================\n=== SHPhotoBrowser' Log ===\n提示信息:%@\n所在方法:%s\n所在行数:%d\n===========================\n===========================",string,__func__,__LINE__);\
}
#else
#define SHFormatLog(...)
#endif



