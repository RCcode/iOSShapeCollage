//
//  SCMaskView.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Filter_GPU/NCImage/NCVideoCamera.h"

@interface SCMaskView : UIView<UIGestureRecognizerDelegate,NSCoding>
{
    CGFloat lastScale;
    CGFloat _lastRotation;
}

@property (nonatomic, strong) UIImageView *editImageView;
@property (nonatomic, strong) UIImage *filterBeforeImage;
@property (nonatomic, strong) UIImage *filterAfterImage;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic) CGAffineTransform initTransform;
@property (nonatomic) CGAffineTransform newTransform;
@property (nonatomic, strong) CALayer *mask;
@property (nonatomic, strong) UIView *editShowView;
@property (nonatomic) CGRect startRect;

@property (nonatomic) NCFilterType filterType;

- (void)setMaskImage:(UIImage *)maskImage;

- (void)setEditImage:(UIImage *)editImage;


@end
