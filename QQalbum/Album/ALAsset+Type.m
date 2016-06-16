//
//  ALAsset+Type.m
//  QQalbum
//
//  Created by Dimoo on 16/6/16.
//  Copyright © 2016年 Dimoo. All rights reserved.
//

#import "ALAsset+Type.h"

@implementation ALAsset (Type)

- (BOOL)ctassetsPickerIsPhoto{
    return ([[self valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]);
}

- (BOOL)ctassetsPickerIsVideo{
    return ([[self valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]);
}

- (UIImage *)badgeImage{
    NSString *imageName;
   if (self.ctassetsPickerIsVideo)
        imageName = @"BadgeVideoSmall";
    
    if (imageName)
        return [UIImage imageNamed:imageName];
    else
        return nil;
}

@end
