//
//  SCModelViewController.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHImagePickerMutilSelector.h"

@class SCEditViewController;

@interface SCModelViewController : UIViewController<MHImagePickerMutilSelectorDelegate,UINavigationControllerDelegate>
{
    MHImagePickerMutilSelector* imagePickerMutilSelector;
    SCEditViewController *editControll;
    
    BOOL isChoose;
}

@property (nonatomic, strong) NSMutableArray *photoGroupArray;

@end
