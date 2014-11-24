//
//  SCMulImagePickerViewController.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-25.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@import Photos;

@interface SCMulImagePickerViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UINavigationControllerDelegate>
{
    UITableView *photoGroupTable;
    NSMutableArray *photosArray;    
}


@property (nonatomic, strong) NSMutableArray *photoGroupArray;
@property (nonatomic, strong) NSMutableArray *photoResultArray;
@property (strong) PHCachingImageManager *imageManager;
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;



@end
