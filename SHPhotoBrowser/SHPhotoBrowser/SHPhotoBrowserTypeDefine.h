//
//  SHPhotoBrowserTypeDefine.h
//  SHPhotoBrowserDemo
//
//  Created by SH on 2017/5/22.
//  Copyright © 2017年 LiuShannoon. All rights reserved.
//

/**
 *  图片浏览器的样式
 */
typedef NS_ENUM(NSUInteger, SHPhotoBrowserStyle){
    /**
     *  长按图片弹出功能组件,底部一个PageControl
     */
    SHPhotoBrowserStylePageControl = 1,
    /**
     * 长按图片弹出功能组件,顶部一个索引UILabel
     */
    SHPhotoBrowserStyleIndeSHabel = 2,
    /**
     * 没有功能组件,顶部一个索引UILabel,底部一个保存图片按钮
     */
    SHPhotoBrowserStyleSimple = 3
};

/**
 *  pageControl的位置
 */
typedef NS_ENUM(NSUInteger, SHPhotoBrowserPageControlAliment){
    /**
     * pageControl在右边
     */
    SHPhotoBrowserPageControlAlimentRight = 1,
    /**
     *  pageControl 中间
     */
    SHPhotoBrowserPageControlAlimentCenter = 2
};

/**
 *  pageControl的样式
 */
typedef NS_ENUM(NSUInteger, SHPhotoBrowserPageControlStyle){
    /**
     * 系统自带经典样式
     */
    SHPhotoBrowserPageControlStyleClassic = 1,
    /**
     *  动画效果pagecontrol
     */
    SHPhotoBrowserPageControlStyleAnimated = 2,
    /**
     *  不显示pagecontrol
     */
    SHPhotoBrowserPageControlStyleNone = 3
    
};
