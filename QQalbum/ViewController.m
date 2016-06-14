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

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    AlbumView *albumView = [[AlbumView alloc] initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 200)];
    albumView.delegate = self;
    albumView.maxItem = 3;
    [self.view addSubview:albumView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *	@author 施峰磊, 16-06-14 14:06:11
 *
 *	TODO:选择的图片
 *
 *	@param images	图片数组
 *
 *	@since 1.0
 */
- (void)selectedImages:(NSArray *)images{

}

@end
