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
@property (nonatomic, copy) NSMutableArray            *fetchAlResult;
@property (nonatomic, strong) UICollectionView          *collectionView;

@property (nonatomic, assign) NSInteger                 lastIndex;
@property (nonatomic, strong) ImageCollectionViewCell   *showCell;
@property (nonatomic, assign) CGRect                    lastcellRect;
@property (nonatomic, copy) NSIndexPath                 *lastIndexPath;
@property (nonatomic, assign) NSInteger                 defullIndex;
@property (nonatomic, assign) CGFloat                   defullPosition;
@property (nonatomic, strong) NSMutableDictionary       *selectedDictionary;
@property (nonatomic, strong) UIImageView               *moveImageView;
@property (nonatomic, strong) ImageCollectionViewCell   *moveCell;
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
        NSMutableArray *selectArrary = [NSMutableArray arrayWithCapacity:0];
        [self resetCellState];
        for (NSNumber*key in self.selectedDictionary.allKeys) {
            if ([[self.selectedDictionary objectForKey:key] boolValue]) {
                if (ISIOS8) {
                    PHAsset *asset = self.fetchResult[[key integerValue]];
                    [selectArrary addObject:asset];
                }else{
                    ALAsset *asset = self.fetchAlResult[[key integerValue]];
//                    UIImage *image = self.fetchAlResult[[key integerValue]];
                    [selectArrary addObject:asset];
                }
                [self.selectedDictionary setObject:@(NO) forKey:key];
            }
        }
        if (selectArrary.count>0) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(selectedImages:)]) {
                [self.delegate selectedImages:selectArrary];
            }
        }
    }
}

/**
 *	@author sender, 16-06-15 23:28:53
 *
 *	TODO: cell状态复位
 *
 *	@since 1.0
 */
- (void)resetCellState{
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForVisibleItems]) {
        NSNumber *content = [self.selectedDictionary objectForKey:@(indexPath.row)];
        if (content && [content boolValue]) {
            ImageCollectionViewCell *showCell = (ImageCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:indexPath];
            showCell.selectButton.selected =NO;
        }
    }
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
    __block ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
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
    
    cell.isSelected = [self.selectedDictionary objectForKey:@(indexPath.row)]?[[self.selectedDictionary objectForKey:@(indexPath.row)] boolValue]:NO;
    typeof(self) __weak weakSelf = self;
    [cell setSelectedBlock:^(NSIndexPath *cellIndexPath, BOOL isSelected, ImageCollectionViewCell *selectCell) {
        [weakSelf.selectedDictionary setObject:@(isSelected) forKey:@(cellIndexPath.row)];
        if (isSelected) {
            CGRect scrollRect = selectCell.frame;
            scrollRect.origin.x += 30;
            [weakSelf.collectionView scrollRectToVisible:scrollRect animated:YES];
        }
    }];
    if (self.lastIndexPath.row<=indexPath.row) {
        if (indexPath.row<self.defullIndex) {
            cell.isFinish = YES;
        }else if (indexPath.row==self.defullIndex){
            ImageCollectionViewCell *lastcell = (ImageCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:indexPath.row-1 inSection:0]];
            [self showCellAnimation:cell lastPosition:CGRectGetMaxX(lastcell.frame) NowPosition:self.frame.size.width];
        }else{
            cell.isFinish = NO;
        }
    }else{
        cell.isFinish = YES;
    }
    self.lastIndexPath = indexPath;
    return cell;
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
    
    self.defullPosition += tempSize.width;
    if (self.defullPosition <= self.frame.size.width) {
        self.defullIndex++;
    }
    return tempSize;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    CGFloat nowPosition = scrollView.contentOffset.x+self.frame.size.width;
    [self getMaxRowByDatas:[self.collectionView indexPathsForVisibleItems] nowPosition:nowPosition];
}

- (void)getMaxRowByDatas:(NSArray *)datas nowPosition:(CGFloat)nowPosition{
    NSInteger maxRow = 0;
    for (NSIndexPath *indexPath in datas) {
        if (maxRow<indexPath.row) {
            maxRow = indexPath.row;
        }
    }
    if (self.lastIndex != maxRow) {
        self.lastIndex = maxRow;
        self.showCell = (ImageCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:maxRow inSection:0]];
        ImageCollectionViewCell *lastcell = (ImageCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.lastIndex-1 inSection:0]];
        self.lastcellRect = [self.collectionView convertRect:lastcell.frame toView:self.collectionView];
    }
    if (self.showCell) {
        [self showCellAnimation:self.showCell lastPosition:CGRectGetMaxX(self.lastcellRect) NowPosition:nowPosition];
    }
}

- (void)showCellAnimation:(ImageCollectionViewCell *)cell lastPosition:(CGFloat)lastPosition NowPosition:(CGFloat)nowPosition{
    cell.buttonPosition = nowPosition - lastPosition;
}

#pragma mark - ImageCollectionViewCellDelegate
-(BOOL)canSelect{
    if (self.selectedDictionary.count != 0) {
        NSMutableArray *selectArrary = [NSMutableArray arrayWithCapacity:0];
        for (NSNumber*key in self.selectedDictionary.allKeys) {
            if ([[self.selectedDictionary objectForKey:key] boolValue]) {
                if (ISIOS8) {
                    PHAsset *asset = self.fetchResult[[key integerValue]];
                    [selectArrary addObject:asset];
                }else{
                    [selectArrary addObject:self.fetchAlResult[[key integerValue]]];
                }
            }
        }
        if (selectArrary.count>=self.maxItem) {
            return NO;
        }
    }
    
    return YES;
}

- (void)didClickSelectButton{
    NSUInteger count = 0;
    for (NSNumber*key in self.selectedDictionary.allKeys) {
        if ([[self.selectedDictionary objectForKey:key] boolValue]) {
            count++;
        }
    }
    if (self.delegate&&[self.delegate respondsToSelector:@selector(didSelectCount:)]) {
        [self.delegate didSelectCount:count];
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
