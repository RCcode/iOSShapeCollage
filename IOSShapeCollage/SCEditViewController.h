//
//  SCEditViewController.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCMaskTouchView.h"


@interface SCEditViewController : UIViewController<maskTouchViewDelegate,UIGestureRecognizerDelegate>
{
    NSArray *maskImageArray;
    NSArray *imageRectArray;
    NSArray *editImageArray;
    
    SCMaskTouchView *maskTouchView;
    
    UIView *modelBarView;
    UIView *actionBarView;
    UIView *actionBar;
    UIView *scaleViewActionBar;
    UIView *filterBarView;
    
    NSArray *filterIconArray;
    NSArray *modelChooseIconArray;
}

@property (nonatomic, strong) UIImageView *backGroundImageView;

- (void)setInfoDictionary:(NSDictionary *)infoDic;
- (void)setEditImageArray:(NSArray *)imageArray;

@end
