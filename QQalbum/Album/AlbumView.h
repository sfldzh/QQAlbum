//
//  AlbumView.h
//  QQalbum
//
//  Created by Dimoo on 16/6/12.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol AlbumViewDelegate <NSObject>
/**
 *	@author sender, 16-06-14 14:06:11
 *
 *	TODO:选择的图片
 *
 *	@param images	图片数组
 *
 *	@since 1.0
 */
- (void)selectedImages:(NSArray *)images;

- (void)didSelectCount:(NSUInteger)count;

@end


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

@end
