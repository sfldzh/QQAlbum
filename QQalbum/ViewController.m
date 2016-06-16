//
//  ViewController.m
//  QQalbum
//
//  Created by Dimoo on 16/6/12.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "ViewController.h"
#import "AlbumView.h"

@interface ViewController ()<AlbumViewDelegate>
@property (nonatomic, strong)AlbumView *albumView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.albumView = [[AlbumView alloc] initWithFrame:CGRectMake(0, 150, self.view.bounds.size.width, 200)];
    self.albumView.delegate = self;
    self.albumView.maxItem = 3;
    [self.view addSubview:self.albumView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)sendImages:(id)sender {
    [self.albumView sendSelectImage];
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

- (void)didSelectCount:(NSUInteger)count{
    NSLog(@"已经选择%lu张",(unsigned long)count);
}

@end
