//
//  AlbumView.m
//  QQalbum
//
//  Created by Dimoo on 16/6/12.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "AlbumView.h"
#import <Photos/Photos.h>
#import "ImageViewFlowLayout.h"
#import "ImageCollectionViewCell.h"
#import "PHAsset+Type.h"
#import "ALAsset+Type.h"
#import "AlbumHelper.h"

@interface AlbumView()<UICollectionViewDelegate,UICollectionViewDataSource,ImageCollectionViewCellDelegate,ImageViewFlowLayoutDelegate,PHPhotoLibraryChangeObserver>
@property (nonatomic, strong) PHAssetCollection         *assetCollection;
@property (nonatomic, strong) PHFetchResult             *fetchResult;
@property (nonatomic, copy) NSMutableArray              *fetchAlResult;
@property (nonatomic, strong) UICollectionView          *collectionView;

@property (nonatomic, strong) NSMutableDictionary       *selectedDictionary;
@property (nonatomic, strong) UIImageView               *moveImageView;
@property (nonatomic, strong) ImageCollectionViewCell   *moveCell;

@property (nonatomic, strong) NSMutableArray            *cellList;
@end

@implementation AlbumView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
        [self initData];
        [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
        [self AlbumData];
    }
    return self;
}

- (void)AlbumData{
    typeof(self) __weak weakSelf = self;
    [AlbumHelper fetchAlbumsContentBlock:^(id content, BOOL success) {
        if (success) {
            if (ISIOS8) {
                weakSelf.fetchResult = content;
            }else{
                weakSelf.fetchAlResult = content;
//                [weakSelf.fetchAlResult addObjectsFromArray:((NSArray*)content)];
            }
            [weakSelf.collectionView reloadData];
        }
    }];
}

- (void)initData{
    self.fetchAlResult = [NSMutableArray arrayWithCapacity:0];
    self.selectedDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
    self.cellList = [NSMutableArray arrayWithCapacity:0];
}

- (void)addViews{
    [self addSubview:self.collectionView];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        ImageViewFlowLayout *layout = [[ImageViewFlowLayout alloc] init];
        layout.sendDelegate = self;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    }
    return _collectionView;
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath{
    return (self.fetchResult.count > 0) ? self.fetchResult[indexPath.item] : nil;
}


/**
 *	@author sender, 16-06-14 14:06:53
 *
 *	TODO:发送多选图片
 *
 *	@since 1.0
 */
- (void)sendSelectImage{
    if (self.selectedDictionary.count != 0) {
        NSDictionary *temp = [self imageIndexSortWithSourceDic:self.selectedDictionary];
        
        NSMutableArray *selectArrary = [NSMutableArray arrayWithCapacity:0];
        for (NSInteger i = 0; i < self.selectedDictionary.count; i++) {
            NSNumber *key = [temp objectForKey:@(i)];
            if (ISIOS8) {
                PHAsset *asset = self.fetchResult[[key integerValue]];
                [selectArrary addObject:asset];
            }else{
                ALAsset *asset = self.fetchAlResult[[key integerValue]];
                [selectArrary addObject:asset];
            }
        }
        
        [self.selectedDictionary removeAllObjects];
        
        if (selectArrary.count>0) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(selectedImages:)]) {
                [self.delegate selectedImages:selectArrary];
            }
        }
        [self.collectionView reloadData];
    }
}


/**
 TODO:照片排序

 @param sourceDic 原数据
 */
- (NSDictionary *)imageIndexSortWithSourceDic:(NSMutableDictionary *)sourceDic{
    NSArray *allValue = [sourceDic allValues];
    NSArray *allKey = [sourceDic allKeys];
    return [NSDictionary dictionaryWithObjects:allKey forKeys:allValue];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    /*
     Change notifications may be made on a background queue. Re-dispatch to the
     main queue before acting on the change as we'll be updating the UI.
     */
    dispatch_async(dispatch_get_main_queue(), ^{
        // Loop through the section fetch results, replacing any fetch results that have been updated.
        [self AlbumData];
    });
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.collectionView.frame = self.bounds;
}

#pragma mark - ImageViewFlowLayoutDelegate
- (void)cellWillMove:(NSIndexPath *)indexPath{
    self.moveCell = (ImageCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
    self.moveCell.selectButton.hidden = YES;
    if (!self.moveCell.isPhoto) {
        self.moveCell.flagImage.hidden = YES;
    }
    self.moveImageView = self.moveCell.imageView;
    [self.moveImageView removeFromSuperview];
    CGRect cellRect = [self.collectionView convertRect:self.moveCell.frame toView:self.superview];
    self.moveImageView.frame = cellRect;
    
    [[[UIApplication sharedApplication] keyWindow] addSubview:self.moveImageView];
}

- (void)cellDidChange:(CGFloat)offsetY{
    self.moveImageView.frame = CGRectMake(self.moveImageView.frame.origin.x, self.frame.origin.y+offsetY, self.moveImageView.frame.size.width, self.moveImageView.frame.size.height);
}
- (void)canSendImage:(BOOL)can{
    self.moveCell.promptLabel.hidden = !can;
}

- (void)cancelMoveCell:(UIPanGestureRecognizer *)gesture{
    gesture.enabled = NO;
    [UIView animateWithDuration:0.15 animations:^{
        self.moveImageView.frame = CGRectMake(self.moveImageView.frame.origin.x, self.frame.origin.y, self.moveImageView.frame.size.width, self.moveImageView.frame.size.height);
    } completion:^(BOOL finished) {
        [self.moveImageView removeFromSuperview];
        self.moveImageView.frame = CGRectMake(0, 0, self.moveImageView.frame.size.width, self.moveImageView.frame.size.height);
        [self.moveCell insertSubview:self.moveImageView atIndex:0];
        self.moveCell.selectButton.hidden = NO;
        if (!self.moveCell.isPhoto) {
            self.moveCell.flagImage.hidden = NO;
        }
        gesture.enabled = YES;
    }];
}

- (void)sendImage:(NSIndexPath *)indexPath panGestureRecognizer:(UIPanGestureRecognizer *)gesture{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(selectedImages:)]) {
        if (ISIOS8) {
            [self.delegate selectedImages:@[self.fetchResult[indexPath.row]]];
        }else{
            [self.delegate selectedImages:@[self.fetchAlResult[indexPath.row]]];
        }
    }
    self.moveImageView.alpha = 0.0;
    self.moveCell.promptLabel.hidden = YES;
    [self.moveImageView removeFromSuperview];
    self.moveImageView.frame = CGRectMake(0, 0, self.moveImageView.frame.size.width, self.moveImageView.frame.size.height);
    [self.moveCell insertSubview:self.moveImageView atIndex:0];
    gesture.enabled = NO;
    [UIView animateWithDuration:0.15 animations:^{
        self.moveImageView.alpha = 1.0;
    } completion:^(BOOL finished) {
        self.moveCell.selectButton.hidden = NO;
        if (!self.moveCell.isPhoto) {
            self.moveCell.flagImage.hidden = NO;
        }
        gesture.enabled = YES;
    }];
}


/**
 TODO:设置cell的选择序号
 */
- (void)setCellSelectIndex{
    for (ImageCollectionViewCell *cell in self.cellList) {
        NSNumber *indexNumber = [self.selectedDictionary objectForKey:@(cell.indexPath.row)];
        cell.selectIndex = indexNumber?[indexNumber integerValue]:0;
    }
}


/**
 TODO:设置cell的位置

 @param cell cell
 */
- (void)cellPosition:(ImageCollectionViewCell *)cell{
    CGRect currenRect = [self.collectionView convertRect:cell.frame toView:self];
    if (currenRect.origin.x>self.frame.size.width) {//在右边未显示
        cell.isFinish = NO;
    }else{
        if (CGRectIntersectsRect(currenRect, self.frame)) {//在屏幕上
            if ((currenRect.origin.x+currenRect.size.width)<self.frame.size.width) {
                cell.isFinish = YES;
            }else{//有一部分被遮掩要计算(右边)
                cell.buttonPosition = self.frame.size.width-currenRect.origin.x ;
            }
        }else{//在左边未显示
            cell.isFinish = YES;
        }
    }
}


#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSInteger count;
    if (ISIOS8) {
        count = self.fetchResult.count;
    }else{
        count = self.fetchAlResult.count;
    }
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
     ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    UIImage *typeImage;
    if (ISIOS8) {
        PHAsset *asset = [self assetAtIndexPath:indexPath];
        typeImage = [asset badgeImage];
        [AlbumHelper requestImageForAsset:asset size:[AlbumHelper getSizeWithAsset:asset maxHeight:self.frame.size.height maxWidth:self.frame.size.width - 20] resizeMode:PHImageRequestOptionsResizeModeFast completion:^(UIImage *image) {
            cell.contentImage = image;
        }];
    }else{
        ALAsset *asset = self.fetchAlResult[indexPath.row];
        typeImage = [asset badgeImage];
        cell.contentImage = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
    }
    
    if (typeImage) {
        cell.flagImage.hidden = NO;
        cell.flagImage.image = typeImage;
    }else{
        cell.flagImage.hidden = YES;
    }
    
    
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.isPhoto = cell.flagImage.hidden;
    NSNumber *indexNumber = [self.selectedDictionary objectForKey:@(indexPath.row)];
    cell.selectIndex = indexNumber?[indexNumber integerValue]:0;
    typeof(self) __weak weakSelf = self;
    [cell setSelectedBlock:^(NSIndexPath *cellIndexPath, BOOL isSelected, ImageCollectionViewCell *selectCell) {
        NSDictionary *temp = weakSelf.selectedDictionary;
        if (isSelected) {
            [weakSelf.selectedDictionary setObject:@(temp.count+1) forKey:@(cellIndexPath.row)];
            CGRect scrollRect = selectCell.frame;
            scrollRect.origin.x += 30;
            [weakSelf.collectionView scrollRectToVisible:scrollRect animated:YES];
        }else{
            NSNumber *currentNumber = [weakSelf.selectedDictionary objectForKey:@(cellIndexPath.row)];
            for (NSNumber *key in [temp allKeys]) {
                NSNumber *tempIndex = [temp objectForKey:key];
                if ([currentNumber integerValue]<[tempIndex integerValue]) {
                    [weakSelf.selectedDictionary setObject:@([tempIndex integerValue]-1) forKey:key];
                }
            }
            [weakSelf.selectedDictionary removeObjectForKey:@(cellIndexPath.row)];
        }
        [weakSelf setCellSelectIndex];
    }];
    
    [self cellPosition:cell];
    
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.cellList addObject:cell];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.cellList removeObject:cell];
}


- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGSize tempSize;
    CGFloat maxWidth = self.frame.size.width - 20;
    if (ISIOS8) {
        PHAsset *asset = [self assetAtIndexPath:indexPath];
        tempSize = [AlbumHelper getSizeWithAsset:asset maxHeight:self.frame.size.height maxWidth:maxWidth];
    }else{
        ALAsset *asset = self.fetchAlResult[indexPath.row];
        tempSize = [AlbumHelper getSizeWithAsset:[UIImage imageWithCGImage:asset.aspectRatioThumbnail] maxHeight:self.frame.size.height maxWidth:maxWidth];
    }
    return tempSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    for (ImageCollectionViewCell *cell in self.cellList) {
        [self cellPosition:cell];
    }
}

#pragma mark - ImageCollectionViewCellDelegate
-(BOOL)canSelect{
    if (self.selectedDictionary.count != 0) {
        if (self.selectedDictionary.count>=self.maxItem) {
            return NO;
        }
    }
    return YES;
}

- (void)didClickSelectButton{
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didSelectCount:)]) {
        [self.delegate didSelectCount:self.selectedDictionary.count];
    }
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
