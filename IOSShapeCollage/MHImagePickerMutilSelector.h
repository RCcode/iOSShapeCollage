//
//  MHMutilImagePickerViewController.h
//  doujiazi
//
//  Created by Shine.Yuan on 12-8-7.
//  Copyright (c) 2012年 mooho.inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCImageCollectionViewController.h"

@protocol MHImagePickerMutilSelectorDelegate <NSObject>

@optional
-(void)imagePickerMutilSelectorDidGetImages:(NSArray*)imageArray;

@end

@interface MHImagePickerMutilSelector : UIViewController<UITableViewDataSource,UITableViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UINavigationBarDelegate,scImageCollectionViewDelegate>
{
    UIView* selectedPan;
    UILabel* textlabel;
    UIImagePickerController*    imagePicker;
    NSMutableArray* pics;
    UITableView*    tbv;
    id<MHImagePickerMutilSelectorDelegate>  delegate;
    
    BOOL isGroup;
    
    UIButton *btn_done;
    
    UITableView *photoGroupTable;
}

@property (nonatomic,retain)UIImagePickerController*    imagePicker;
@property (nonatomic,retain)id<MHImagePickerMutilSelectorDelegate>   delegate;
@property (nonatomic) NSInteger maxImageCount;

@property (nonatomic, retain) UIViewController *tempController;

+(id)standardSelector;

@end
