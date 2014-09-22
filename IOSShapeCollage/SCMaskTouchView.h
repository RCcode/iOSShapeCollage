//
//  SCMaskTouchView.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//


@protocol maskTouchViewDelegate <NSObject>

- (void)showTheChooseBarAtPoint:(CGPoint)point;

@end

#import <UIKit/UIKit.h>
#import "Filter_GPU/NCImage/NCVideoCamera.h"
@class SCMaskView;

@interface SCMaskTouchView : UIView<NCVideoCameraDelegate>
{
    NSMutableArray *maskImageArray;
    UIView *showView;
    
    CGPoint responderCenter;//初始蒙板view的中点
    CGPoint currentCenter;//编辑图居中后蒙板view的中点
    CGAffineTransform showTransform;//
    CGAffineTransform responderTransform;
    CGAffineTransform responderStartTransform;
    CGAffineTransform responderEditStartTransform;
    CGRect responderStartRect;
    
    SCMaskView *tempResponderView;
    
    UIView *actionBar;
    UIView *modelChooseBar;
    
    BOOL isScaleImage;
    BOOL isFilterImage;
    
    NCVideoCamera *_videoCamera;
}

@property (nonatomic, strong) SCMaskView *responderView;
@property (nonatomic, assign) id<maskTouchViewDelegate>delegate;
@property (nonatomic) BOOL isScaleImage;
@property (nonatomic) BOOL isFilterImage;


- (void)sendResponderViewToEdit;
- (void)maskViewOriginEdit;
- (void)maskViewCancelEdit;
- (void)maskViewEndEdit;

- (void)setBarView:(UIView *)barView;
- (void)setModelChooseBarView:(UIView *)chooseBar;

- (void)changeFilterWithType:(NCFilterType)type;

- (void)setupWithMaskImageArray:(NSArray *)imageArray andRectArray:(NSArray *)rectArray andEditImageArray:(NSArray *)editImageArray;


@end
