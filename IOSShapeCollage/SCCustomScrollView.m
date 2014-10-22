//
//  SCCustomScrollView.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-28.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCCustomScrollView.h"

@implementation SCCustomScrollView



- (BOOL)touchesShouldBegin:(NSSet *)touches withEvent:(UIEvent *)event inContentView:(UIView *)view
{
    UITouch *touch = [touches anyObject];
    
    if(touch.phase == UITouchPhaseMoved)
    {
        return NO;
    }
    else
    {
        return [super touchesShouldBegin:touches withEvent:event inContentView:view];
    }
}


@end
