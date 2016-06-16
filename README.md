# RippleButton

###项目介绍
* 该框架为一个类似QQ多选照片（支持视频）的框架
* 1.支持多选照片(多选照片数量及最大多选数可设置)
* 2.支持滑动单选照片
* 3.[常用Api] (#常用Api)
* 4.[使用方法] (#使用方法)

###<a id="常用Api"></a>常用Api
```objc
NS_ASSUME_NONNULL_BEGIN

@interface AlbumView : UIView

@property (nonatomic, assign)id<AlbumViewDelegate>delegate;
//选择图片最大数
@property (nonatomic, assign) NSUInteger maxItem;

/**
*	@author sender, 16-06-14 14:06:53
*
*	TODO:发送多选图片
*
*	@since 1.0
*/
- (void)sendSelectImage;

NS_ASSUME_NONNULL_END

@end
```

###<a id="使用方法"></a>使用方法

```objc
#import "AlbumView.h"

- (void)viewDidLoad {
[super viewDidLoad];
// Do any additional setup after loading the view, typically from a nib.

self.albumView = [[AlbumView alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, 200)];
self.albumView.delegate = self;
self.albumView.maxItem = 3;
[self.view addSubview:self.albumView];
}

/**
*	@author sender, 16-06-14 14:06:11
*
*	TODO:选择的图片
*
*	@param images	图片数组
*
*	@since 1.0
*/
- (void)selectedImages:(NSArray *)images{
    NSLog(@"%@",images);
}

/**
*	@author sender, 16-06-14 14:06:11
*
*	TODO:已经选择的图片数量
*
*	@param count	图片数量
*
*	@since 1.0
*/
- (void)didSelectCount:(NSUInteger)count{
    NSLog(@"已经选择%lu张",(unsigned long)count);
}

```

![image](https://github.com/sfldzh/QQAlbum/blob/master/album.gif?raw=true)
