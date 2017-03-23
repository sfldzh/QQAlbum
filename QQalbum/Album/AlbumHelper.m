//
//  Album.m
//  QQalbum
//
//  Created by danica on 16/6/15.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "AlbumHelper.h"

@implementation AlbumHelper


/**
 TODO:是否可以访问照片

 @return 是否允许
 */
+ (BOOL)canAccessAlbums {
    BOOL _isAuth = YES;
    if (ISIOS8) {
        PHAuthorizationStatus author = [PHPhotoLibrary authorizationStatus];
        if (author == PHAuthorizationStatusRestricted || author == PHAuthorizationStatusDenied){
            //无权限
            _isAuth = NO;
        }
    } else {
        ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
        if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusNotDetermined) {
            //无权限
            _isAuth = NO;
        }
    }
    return _isAuth;
}

+ (ALAssetsLibrary *)defaultAssetsLibrary{
    static dispatch_once_t pred = 0;
    static ALAssetsLibrary *library = nil;
    dispatch_once(&pred,^{
        library = [[ALAssetsLibrary alloc] init];
    });
    return library;
}

//读取列表
+ (void)fetchAlbumsContentBlock:(void(^)(id content, BOOL success))contentBlock{
    if (ISIOS8) {
        PHFetchOptions *options = [[PHFetchOptions alloc] init];
        options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithOptions:options];
        if (fetchResult.count == 0) {
            if (contentBlock)
                contentBlock(fetchResult,NO);
        }else{
            if (contentBlock)
                contentBlock(fetchResult,YES);
        }
    }else {
        __block NSInteger assetNumber = 0;
        __block NSInteger count = 0;
        __block NSMutableArray *mutableArray =[NSMutableArray arrayWithCapacity:0];
        ALAssetsLibrary *library = [AlbumHelper defaultAssetsLibrary];
        void (^assetEnumerator)( ALAsset *, NSUInteger, BOOL *) = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
            if (result) {
                [mutableArray insertObject:result atIndex:0];
                count++;
            }
            if (count == assetNumber&&contentBlock) {
                count = 0;
                contentBlock(mutableArray,YES);
            }
        };
        void (^ assetGroupEnumerator) ( ALAssetsGroup *, BOOL *)= ^(ALAssetsGroup *group, BOOL *stop) {
            if(group != nil) {
                assetNumber += [group numberOfAssets];
                [group enumerateAssetsUsingBlock:assetEnumerator];
            }
        };
        [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:assetGroupEnumerator failureBlock:^(NSError *error) {NSLog(@"There is an error");}];
    }
}

+ (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion{
    size.width *= 2;
    size.height *= 2;
    if (ISIOS8) {
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
}

+ (CGSize)getSizeWithAsset:(id)asset maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth{
    CGFloat scale;
    if (ISIOS8) {
        CGFloat width  = (CGFloat)((PHAsset *)asset).pixelWidth;
        CGFloat height = (CGFloat)((PHAsset *)asset).pixelHeight;
        scale = width/height;
    }else{
        UIImage *tempImg = asset;
        scale = tempImg.size.width/tempImg.size.height;
    }
    CGFloat sizeWidth = maxHeight*scale>maxWidth?maxWidth:maxHeight*scale;
    return CGSizeMake(sizeWidth, maxHeight);
}

@end
