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

#define ISIOS8      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
@interface AlbumView()<UICollectionViewDelegate,UICollectionViewDataSource,ImageCollectionViewCellDelegate>
@property (nonatomic, strong) PHAssetCollection         *assetCollection;
@property (nonatomic, strong) PHFetchResult             *fetchResult;
@property (nonatomic, strong) UICollectionView          *collectionView;

@property (nonatomic, assign) NSInteger                 lastIndex;
@property (nonatomic, strong) ImageCollectionViewCell   *showCell;
@property (nonatomic, assign) CGRect                    lastcellRect;
@property (nonatomic, copy) NSIndexPath                 *lastIndexPath;
@property (nonatomic, assign) NSInteger                 defullIndex;
@property (nonatomic, assign) CGFloat                   defullPosition;
@property (nonatomic, strong) NSMutableDictionary       *selectedDictionary;
@end

@implementation AlbumView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addViews];
        [self initData];
        [self initAlbumData];
    }
    return self;
}

- (void)initAlbumData{
    PHAssetCollectionType type = PHAssetCollectionTypeSmartAlbum;
    PHAssetCollectionSubtype subtype = PHAssetCollectionSubtypeSmartAlbumUserLibrary;
    
    PHFetchOptions *fetchOptions = [PHFetchOptions new];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"estimatedAssetCount" ascending:NO]];
    
    PHFetchResult *fetchResult = [PHAssetCollection fetchAssetCollectionsWithType:type subtype:subtype options:fetchOptions];
    
    for (PHAssetCollection *assetCollection in fetchResult){
        self.assetCollection = assetCollection;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        PHFetchResult *fetchResult =
        [PHAsset fetchAssetsInAssetCollection:self.assetCollection
                                      options:nil];
        // 回到主线程显示图片
        dispatch_async(dispatch_get_main_queue(), ^{
            self.fetchResult = fetchResult;
            [self.collectionView reloadData];
        });
    });
}

- (void)initData{
    self.selectedDictionary = [NSMutableDictionary dictionaryWithCapacity:0];
}

- (void)addViews{
    [self addSubview:self.collectionView];
}

- (UICollectionView *)collectionView{
    if (!_collectionView) {
        ImageViewFlowLayout *layout = [[ImageViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.minimumInteritemSpacing = 3;
        layout.sectionInset = UIEdgeInsetsMake(0, 5, 0, 5);
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
        [_collectionView registerClass:[ImageCollectionViewCell class] forCellWithReuseIdentifier:@"ImageCollectionViewCell"];
    }
    return _collectionView;
}

- (PHAsset *)assetAtIndexPath:(NSIndexPath *)indexPath{
    return (self.fetchResult.count > 0) ? self.fetchResult[indexPath.item] : nil;
}

- (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion{
    size.width *= 2;
    size.height *= 2;
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    /**
     resizeMode：对请求的图像怎样缩放。有三种选择：None，默认加载方式；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     */
    option.resizeMode = resizeMode;//控制照片尺寸
    //option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;//控制照片质量
    //option.synchronous = YES;
    option.networkAccessAllowed = YES;
    //param：targetSize 即你想要的图片尺寸，若想要原尺寸则可输入PHImageManagerMaximumSize
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFit options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        completion(image);
    }];
}


/**
 *	@author 施峰磊, 16-06-14 14:06:53
 *
 *	TODO:发送多选图片
 *
 *	@since 1.0
 */
- (void)sendSelectImage{
    if (self.selectedDictionary.count != 0) {
        NSMutableArray *selectArrary = [NSMutableArray arrayWithCapacity:0];
        for (NSNumber*key in self.selectedDictionary.allKeys) {
            if ([[self.selectedDictionary objectForKey:key] boolValue]) {
                PHAsset *asset = self.fetchResult[[key integerValue]];
                [selectArrary addObject:asset];
            }
        }
        if (selectArrary.count>0) {
            if (self.delegate&&[self.delegate respondsToSelector:@selector(selectedImages:)]) {
                [self.delegate selectedImages:selectArrary];
            }
        }
    }
}

#pragma mark - 获取图片及图片尺寸的相关方法
- (CGSize)getSizeWithAsset:(PHAsset *)asset{
    CGFloat width  = (CGFloat)asset.pixelWidth;
    CGFloat height = (CGFloat)asset.pixelHeight;
    CGFloat scale = width/height;
    CGFloat maxWidth = 160;
    CGFloat sizeWidth = self.collectionView.frame.size.height*scale>maxWidth?maxWidth:self.collectionView.frame.size.height*scale;
    return CGSizeMake(sizeWidth, self.collectionView.frame.size.height);
}

#pragma mark - UICollectionDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.fetchResult.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    __block ImageCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ImageCollectionViewCell" forIndexPath:indexPath];
    PHAsset *asset = [self assetAtIndexPath:indexPath];
    cell.indexPath = indexPath;
    cell.delegate = self;
    cell.isSelected = [self.selectedDictionary objectForKey:@(indexPath.row)]?[[self.selectedDictionary objectForKey:@(indexPath.row)] boolValue]:NO;
    typeof(self) __weak weakSelf = self;
    [cell setSelectedBlock:^(NSIndexPath *cellIndexPath, BOOL isSelected) {
        [weakSelf.selectedDictionary setObject:@(isSelected) forKey:@(cellIndexPath.row)];
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
    
    [self requestImageForAsset:asset size:[self getSizeWithAsset:asset] resizeMode:PHImageRequestOptionsResizeModeNone completion:^(UIImage *image) {
        cell.contentImage = image;
    }];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    PHAsset *asset = [self assetAtIndexPath:indexPath];
    CGSize tempSize = [self getSizeWithAsset:asset];
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
                PHAsset *asset = self.fetchResult[[key integerValue]];
                [selectArrary addObject:asset];
            }
        }
        if (selectArrary.count>=self.maxItem) {
            return NO;
        }
    }
    return YES;
}



/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end