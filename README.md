# iOS轻量图片放大浏览
备注：目前开源的有很多图片放大浏览的库，不过大多功能太复杂，这里只为做一个轻量级的图片浏览库。 该项目是基于https://github.com/CoderXLLau/XLPhotoBrowser 修改而来，这里图片加载库因我们业务的原因换成了 PINRemoteImage，如果需要使用其他的可以自行修改。

#### 如何引入项目

```objective-c
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '7.0'
target 'TargetName' do
pod 'SHPhotoBrowser', '~> 0.0.1'
end
```

#### 具体调用实现

```objective-c
NSArray * marrImages = [NSArray arrayWithObjects:@"https://cdn1.showjoy.com/images/be/be8852f9d3984865951a8206772ccbbd.jpg",@"https://cdn1.showjoy.com/images/6e/6e66ef820e36418c8b0b6863c8253a75.jpg",@"https://cdn1.showjoy.com/images/5b/5b63d7766cfa4cf1b9a2bc07c7c6a1c2.jpg",@"https://cdn1.showjoy.com/images/8f/8ff2116f1ad141bb96a78a0cb759301b.jpg",[UIImage imageNamed:@"photo1.jpg"], nil];
/*
传入存图片的数组 连接和图片都可以
传入打开图片浏览到第几张
*/
[SHPhotoBrowser showPhotoBrowserWithImages:marrImages currentImageIndex:2];

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
```
#### 使用异常时参考这里

1.长按保存图片保存失败

解决方案：

 	确认info.plst文件里是否添加相册访问权限

​	Privacy - Photo Library Usage Description	App需要您的同意,才能访问相册