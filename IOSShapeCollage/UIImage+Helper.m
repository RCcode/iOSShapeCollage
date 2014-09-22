//
//  UIImage+Helper.m
//  IOSPhotoCollage
//
//  Created by herui on 6/8/14.
//  Copyright (c) 2014年 rcplatform. All rights reserved.
//

#import "UIImage+Helper.h"

@implementation UIImage (Helper)

+ (UIImage *)imageFromName:(NSString *)imageName{
    
    NSString *path = [[NSBundle mainBundle] pathForResource:imageName ofType:nil];
    
    if(path == nil){
        path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@@2x.png", imageName] ofType:nil];
    }
    if(path == nil){
        path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.png", imageName] ofType:nil];
    }
    if(path == nil){
        path = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@.jpg", imageName] ofType:nil];
    }
    if(path == nil){
        return nil;
    }
//    NSLog(@"imagePath - %@", path);
    return [UIImage imageWithContentsOfFile:path];
}

+ (UIImage *)imageFromView:(UIView *)view toSize:(CGSize)size{
    CGFloat scaleW = size.width / view.bounds.size.width;
    CGFloat scaleH = size.height / view.bounds.size.height;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scaleW, scaleH);
    [view.layer renderInContext:context];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
//    NSLog(@"size - %@", NSStringFromCGSize(size));
//    NSLog(@"image.size - %@", NSStringFromCGSize(image.size));
    
    return image;
}

@end
