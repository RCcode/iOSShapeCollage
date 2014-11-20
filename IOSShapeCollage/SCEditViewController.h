//
//  SCEditViewController.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCMaskTouchView.h"

@class SCCustomScrollView;

@interface SCEditViewController : UIViewController<maskTouchViewDelegate,UIGestureRecognizerDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *maskImageArray;
    NSArray *imageRectArray;
    NSMutableArray *editImageArray;
    
    SCMaskTouchView *maskTouchView;
    
    UIView *modelBarView;
    UIView *actionBarView;
    UIView *actionBar;
    UIView *tipBarView;
    UIView *scaleViewActionBar;
    UIView *filterBarView;
    
    NSArray *filterIconArray;
    NSMutableArray *modelChooseIconArray;
    SCCustomScrollView *filterScrollView;
    
    UIButton *leftItemButton;
    UIButton *rightItemButton;
    UIBarButtonItem *leftItem;
    UIBarButtonItem *rightItem;
    
    NSDictionary *infoDictionary;
    
    UIImageView *modelChangeSelected;
    NSString *modelChangeSelectedName;
    NSInteger selectedTag;
    SCCustomScrollView *modelChooseScroll;
    
    BOOL isShare;
}

@property (nonatomic) NSInteger modelPieces;

- (id)initWithPieces:(NSInteger)pieces andType:(NSString *)type;

- (void)setInfoDictionary:(NSDictionary *)infoDic;
- (void)setEditImageArray:(NSArray *)imageArray;

@end
