//
//  UIImage+Helper.h
//  IOSPhotoCollage
//
//  Created by herui on 6/8/14.
//  Copyright (c) 2014年 rcplatform. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Helper)

//根据指定名加载image对象
+ (UIImage *)imageFromName:(NSString *)imageName;

//根据view生成UIImage对象
+ (UIImage *)imageFromView:(UIView *)view toSize:(CGSize)size;

@end
