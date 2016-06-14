//
//  ImageCollectionViewCell.h
//  QQalbum
//
//  Created by Dimoo on 16/6/12.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImageCollectionViewCellDelegate<NSObject>
/**
 *	@author 施峰磊, 16-06-14 15:06:56
 *
 *	TODO:是否可以选择
 *
 *	@return 是否
 *
 *	@since 1.0
 */
- (BOOL)canSelect;
@end

@interface ImageCollectionViewCell : UICollectionViewCell

@property (nonatomic, assign) id<ImageCollectionViewCellDelegate>delegate;

@property (nonatomic, strong) UIImageView   *imageView;
@property (nonatomic, strong) UIButton      *selectButton;
@property (nonatomic, strong) UIImage       *contentImage;
@property (nonatomic, assign) CGFloat       buttonPosition;
@property (nonatomic, assign) BOOL          isFinish;
@property (nonatomic, assign) BOOL          isSelected;
@property (nonatomic, strong) NSIndexPath   *indexPath;
@property (nonatomic, strong) void(^selectedBlock)(NSIndexPath *indexPath,BOOL isSelected);
@end
