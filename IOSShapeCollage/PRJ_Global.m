//
//  PRJ_Global.m
//  IOSNoCrop
//
//  Created by rcplatform on 14-4-18.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "PRJ_Global.h"
#import "UIImage+SubImage.h"
#import "MobClick.h"

//#import "GAI.h"
//#import "GAIDictionaryBuilder.h"

@implementation PRJ_Global

@synthesize originalImage = _originalImage;
@synthesize compressionImage = _compressionImage;
@synthesize MHImagePickerdelegate;


+ (void)load{
    if(kScreen_Height >= 568){
        kBannerViewH = 50;
    }else{
        kBannerViewH = 0;
    }
}

static PRJ_Global *_glo = nil;

+ (PRJ_Global *)shareStance
{
    if (_glo == nil) {
        _glo = [[PRJ_Global alloc]init];
    }
    return _glo;
}

- (void)setOriginalImage:(UIImage *)originalImage{

    //设置原始图片的同时，获取压缩后的图片
    float multiple = 0.0 ,newHeight = 0.0 ,newWidth = 0.0;
    if (originalImage.size.height >= originalImage.size.width) {
        multiple = originalImage.size.height/1080;
        newHeight = 1080;
        newWidth = originalImage.size.width/multiple;
    }else{
        multiple = originalImage.size.width/1080;
        newWidth = 1080;
        newHeight = originalImage.size.height/multiple;
    }
    
    UIImage *scaleImage = [[UIImage alloc]initWithData:[UIImage createThumbImage:originalImage size:CGSizeMake(newWidth, newHeight) percent:0.8]];
    
    _originalImage = [scaleImage rescaleImageToSize:scaleImage.size];
    _compressionImage = [scaleImage rescaleImageToSize:scaleImage.size];
}

- (void)setBoxCount:(int)boxCount{
    _boxCount = boxCount;
    
    // 2 3  ==> 1.5
    // 4 5 ==> 1.4
    // 6 7 ==> 1.3
    // 8 9 == > 1.2
    
    _compScale = 1.5;

    NSString *device = doDevicePlatform();
    if([device rangeOfString:@"iPod"].length ||
       [device rangeOfString:@"iPhone3"].length ||
       [device rangeOfString:@"iPhone4"].length ||
       [device rangeOfString:@"iPhone 4"].length){
        
        switch (_boxCount) {
                
            case 4:
            case 5:
                _compScale = 1.4;
                break;
            case 6:
            case 7:
                _compScale = 1.3;
                break;
            case 8:
            case 9:
                _compScale = 1.2;
                break;
                
            default:
                _compScale = 1.5;
                break;
        }
    }
}

- (MHImagePickerMutilSelector *)getSCCollectionViewDelegate
{
    return MHImagePickerdelegate;
}

#pragma mark 事件统计
+ (void)event:(NSString *)eventID label:(NSString *)label;
{
    //友盟
    [MobClick event:eventID label:label];

}


@end
