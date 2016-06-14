//
//  PHAsset+Type.h
//  QQalbum
//
//  Created by Dimoo on 16/6/14.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (Type)
- (BOOL)ctassetsPickerIsPhoto;
- (BOOL)ctassetsPickerIsVideo;
- (BOOL)ctassetsPickerIsHighFrameRateVideo;
- (BOOL)ctassetsPickerIsTimelapseVideo;
- (UIImage *)badgeImage;
@end
