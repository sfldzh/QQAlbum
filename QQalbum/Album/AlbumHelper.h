//
//  Album.h
//  QQalbum
//
//  Created by danica on 16/6/15.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

#define ISIOS8      ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//#define ISIOS8 NO
@interface AlbumHelper : NSObject

+ (BOOL)canAccessAlbums;

+ (void)fetchAlbumsContentBlock:(void(^)(id content, BOOL success))contentBlock;
+ (void)requestImageForAsset:(PHAsset *)asset size:(CGSize)size resizeMode:(PHImageRequestOptionsResizeMode)resizeMode completion:(void (^)(UIImage *))completion;

+ (CGSize)getSizeWithAsset:(id)asset maxHeight:(CGFloat)maxHeight maxWidth:(CGFloat)maxWidth;

@end
