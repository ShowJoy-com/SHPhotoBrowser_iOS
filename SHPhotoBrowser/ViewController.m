//
//  ViewController.m
//  PhotoBrowser
//
//  Created by guo on 16/6/20.
//  Copyright © 2016年 YunRuo. All rights reserved.
//

#import "ViewController.h"
#import "SHPhotoBrowser.h"
@interface ViewController ()<SHPhotoBrowserDelegate>

@end

@implementation ViewController

/*
  该项目是基于https://github.com/CoderXLLau/XLPhotoBrowser 修改而来 主要是想找一个比较轻量级的来用 只使用单纯的多图浏览 这里图片加载库因为我们业务的原因换成了 PINRemoteImage
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    UIButton * btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setTitle:@"图片浏览" forState:UIControlStateNormal];
    btn.frame=CGRectMake(100, 100, 100, 100);
    [btn addTarget:self action:@selector(openPhotoViewController) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)openPhotoViewController{
    NSArray * marrImages = [NSArray arrayWithObjects:@"https://cdn1.showjoy.com/images/be/be8852f9d3984865951a8206772ccbbd.jpg",@"https://cdn1.showjoy.com/images/6e/6e66ef820e36418c8b0b6863c8253a75.jpg",@"https://cdn1.showjoy.com/images/5b/5b63d7766cfa4cf1b9a2bc07c7c6a1c2.jpg",@"https://cdn1.showjoy.com/images/8f/8ff2116f1ad141bb96a78a0cb759301b.jpg",[UIImage imageNamed:@"photo1.jpg"], nil];
    [SHPhotoBrowser showPhotoBrowserWithImages:marrImages currentImageIndex:2];
}

#pragma mark SHPhotoBrowserDelegate
/*
 保存第几张图片图片到相册
 */
-(void)photoBrowserCurrentImageIndex:(NSInteger)currentImageIndex{
    
}
/*
 取消图片浏览
 */
-(void)cancelPhotoBrowser{
    
}




@end
