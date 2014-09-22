//
//  SCMaskView.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCMaskView : UIView<UIGestureRecognizerDelegate>
{
    CGFloat lastScale;
    CGFloat _lastRotation;
    CGRect startRect;
    
}

@property (nonatomic, strong) UIImageView *editImageView;
@property (nonatomic, strong) UIImage *filterBeforeImage;
@property (nonatomic, strong) UIImage *filterAfterImage;
@property (nonatomic, strong) UIImage *maskImage;
@property (nonatomic) CGAffineTransform newTransform;
@property (nonatomic, strong) CALayer *mask;
@property (nonatomic, strong) UIView *editShowView;

- (void)setMaskImage:(UIImage *)maskImage;

- (void)setEditImage:(UIImage *)editImage;


@end
