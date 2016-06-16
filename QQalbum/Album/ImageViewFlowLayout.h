//
//  ImageViewFlowLayout.h
//  QQalbum
//
//  Created by Dimoo on 16/6/13.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ImageViewFlowLayoutDelegate<NSObject>

- (void)cellWillMove:(NSIndexPath *)indexPath;

- (void)cellDidChange:(CGFloat)offsetY;

- (void)canSendImage:(BOOL)can;

- (void)cancelMoveCell:(UIPanGestureRecognizer *)gesture;

- (void)sendImage:(NSIndexPath *)indexPath panGestureRecognizer:(UIPanGestureRecognizer *)gesture;
@end

@interface ImageViewFlowLayout : UICollectionViewFlowLayout
@property(nonatomic,assign)id<ImageViewFlowLayoutDelegate>sendDelegate;

@end
