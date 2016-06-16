//
//  ALAsset+Type.h
//  QQalbum
//
//  Created by Dimoo on 16/6/16.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import <AssetsLibrary/AssetsLibrary.h>
#import <UIKit/UIKit.h>

@interface ALAsset (Type)
- (BOOL)ctassetsPickerIsPhoto;
- (BOOL)ctassetsPickerIsVideo;
- (UIImage *)badgeImage;
@end
