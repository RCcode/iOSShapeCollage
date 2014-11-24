//
//  SCMaskTouchView.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCMaskTouchView.h"
#import "SCMaskView.h"
#import "UIImage+SubImage.h"
#import "SCAppDelegate.h"

@implementation SCMaskTouchView

@synthesize delegate;
@synthesize isFilterImage;
@synthesize isScaleImage;
@synthesize showView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self initSubViews];
        // Initialization code
    }
    return self;
}

////将对象解码(反序列化)
//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//    if (self=[super init])
//    {
//        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
////        [self initSubViews];
//        showView = [aDecoder decodeObjectForKey:@"showView"];
//        
//    }
//    return (self);
//}
//
////将对象编码(即:序列化)
//-(void) encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeCGRect:self.frame forKey:@"frame"];
//    [aCoder encodeObject:showView forKey:@"showView"];
//}

- (void)setupWithMaskImageArray:(NSArray *)maskArray andRectArray:(NSArray *)rectArray andEditImageArray:(NSArray *)editArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       maskImageArray = nil;
                       maskImageArray = [[NSMutableArray alloc]init];
                       for (NSString *path in maskArray)
                       {
                           UIImage *tempImage = [UIImage imageWithContentsOfFile:path];
                           tempImage = [tempImage rescaleImageToSize:self.frame.size];
                           [maskImageArray addObject:tempImage];
                       }
                   });
    
    for (int i = 0; i < [maskArray count]; i ++)
    {
        @autoreleasepool
        {
            SCMaskView *mask = [[SCMaskView alloc]initWithFrame:self.frame];
            mask.editShowView.frame = CGRectFromString([rectArray objectAtIndex:i]);
            mask.editImageView.frame = mask.editShowView.frame;
            [mask setMaskImage:[UIImage imageWithContentsOfFile:[maskArray objectAtIndex:i]]];
            [mask setEditImage:[editArray objectAtIndex:i]];
            mask.tag = i+10;
            [showView addSubview:mask];
        }
        
    }
}

- (void)initSubViews
{
//    CGPoint point = [tap locationInView:self.view];
    
    showView = [[UIImageView alloc]initWithFrame:self.frame];
    showView.backgroundColor = [UIColor clearColor];
    [self addSubview:showView];
    
    _responderView = [[SCMaskView alloc]initWithFrame:self.frame];
    [self addSubview:_responderView];
    
    UITapGestureRecognizer *actionBarViewTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(actionBarViewTapAction:)];
    actionBarViewTap.numberOfTapsRequired = 1;
    actionBarViewTap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:actionBarViewTap];

    
//    _scaleViewActionBar = [[UIView alloc]initWithFrame:CGRectZero];
}

- (void)actionBarViewTapAction:(UITapGestureRecognizer *)tap
{
    if (isScaleImage || isFilterImage || isExchangeImage)
    {
        return;
    }
//    UITouch *touch = [touches anyObject];
    CGPoint point = [tap locationInView:self];
    
    CGColorRef pixelColor = [[self colorAtPixel:point andImage:[maskImageArray objectAtIndex:_responderView.tag-10]] CGColor];
    
    CGFloat alpha = CGColorGetAlpha(pixelColor);
    
    if (CGRectContainsPoint(self.frame, point) && alpha == 1)
    {
        [delegate showTheChooseBarAtPoint:point];
    }
}

- (void)setwillShowBar:(UIView *)willShow andWillHideBar:(UIView *)willHide
{
    willShowBar = willShow;
    willHideBar = willHide;
}

- (void)changeFilterWithType:(NCFilterType)type
{
    _responderView.filterType = type;
    
    if(_videoCamera == nil){
        _videoCamera = [[NCVideoCamera alloc]init];
        _videoCamera.delegate = self;
    }
    if ([[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate date]]) {
        [_videoCamera setImages:@[_responderView.filterBeforeImage] WithFilterType:type];
    }
}

#pragma mark - NCVideoCameraDelegate
- (void)videoCameraDidFinishFilter:(UIImage *)image Index:(NSUInteger)index{

    _videoCamera = nil;
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
    
    if([image isKindOfClass:[UIImage class]])
    {
        _responderView.editImageView.image = image;
        _responderView.filterAfterImage = image;
    }
//    hideMBProgressHUD();
}


#pragma mark editImage编辑区显示及结束方法
- (void)sendResponderViewToEdit
{
    isScaleImage = YES;
    [self addSubview:_responderView];
    responderCenter = _responderView.center;
    responderEditImageRect = _responderView.editImageView.frame;
    
    CGPoint editAreaCenter = CGPointMake(_responderView.editShowView.frame.origin.x+_responderView.editShowView.frame.size.width/2, _responderView.editShowView.frame.origin.y+_responderView.editShowView.frame.size.height/2);
    
    CGPoint changePoint = CGPointMake(responderCenter.x-editAreaCenter.x, responderCenter.y-editAreaCenter.y);
    
    currentCenter = CGPointMake(responderCenter.x+changePoint.x, responderCenter.y+changePoint.y);
    
    CGFloat editWidth = _responderView.editShowView.frame.size.width;
    CGFloat editheight = _responderView.editShowView.frame.size.height;
    
    showTransform = showView.transform;
    responderStartTransform = _responderView.transform;
    
    CGFloat scale = 0;
    
    if (editWidth >= editheight)
    {
        scale = 280/editWidth;
    }
    else
    {
        scale = 280/editheight;
    }
    
    
    [UIView animateWithDuration:ANIMATIONDURATION animations:
    ^{
        willHideBar.frame = CGRectMake(willHideBar.frame.origin.x, willHideBar.frame.origin.y+willHideBar.frame.size.height, willHideBar.frame.size.width, willHideBar.frame.size.height);
        _responderView.center = currentCenter;
        responderTransform = _responderView.transform;
        
        showTransform = showView.transform;
        CGAffineTransform currentTransform = CGAffineTransformScale(showView.transform, 0, 0);
        showView.transform = currentTransform;
        
        
    } completion:^(BOOL finished){
        if (finished)
        {
            _responderView.layer.position = responderCenter;
            _responderView.layer.anchorPoint = CGPointMake(editAreaCenter.x/_responderView.bounds.size.width, editAreaCenter.y/_responderView.bounds.size.height);
            
            [UIView animateWithDuration:ANIMATIONDURATION animations:
            ^{
                CGAffineTransform currentTransform = CGAffineTransformScale(_responderView.transform, scale, scale);
                _responderView.transform = currentTransform;
                
                willShowBar.frame = CGRectMake(willShowBar.frame.origin.x, willShowBar.frame.origin.y-willShowBar.frame.size.height, willShowBar.frame.size.width, willShowBar.frame.size.height);
                
            }completion:^(BOOL finished)
             {
                 
             }];
        }
    }];
}

- (void)maskViewEndEdit
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:
     ^{
         CGAffineTransform currentTransform = CGAffineTransformScale(responderTransform, 1, 1);
         _responderView.transform = currentTransform;
         
         willShowBar.frame = CGRectMake(willShowBar.frame.origin.x, willShowBar.frame.origin.y+willShowBar.frame.size.height, willShowBar.frame.size.width, willShowBar.frame.size.height);
         
     }completion:^(BOOL finished)
     {
         [UIView animateWithDuration:ANIMATIONDURATION animations:
          ^{
              
              CGAffineTransform currentTransform = CGAffineTransformScale(showTransform, 1, 1);
              showView.transform = currentTransform;
              _responderView.transform = responderStartTransform;
              _responderView.frame = responderStartRect;
              willHideBar.frame = CGRectMake(willHideBar.frame.origin.x, willHideBar.frame.origin.y-willHideBar.frame.size.height, willHideBar.frame.size.width, willHideBar.frame.size.height);
              
          } completion:^(BOOL finishec)
          {
              _responderView.layer.anchorPoint = CGPointMake(0.5, 0.5);
              _responderView.layer.position = responderCenter;
              [showView addSubview:_responderView];
              _responderView = nil;
              isScaleImage = NO;
              
          }];
     }];

}

- (void)maskViewOriginEdit
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:^{
        CGAffineTransform currentTransform = CGAffineTransformScale(responderTransform, 1, 1);
        _responderView.transform = currentTransform;
        
        _responderView.newTransform = _responderView.initTransform;
        _responderView.editImageView.center = _responderView.startCenter;
    }];
}
- (void)maskViewCancelEdit
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:
     ^{
//         _responderView.newTransform = _responderView.editImageView.transform;
//         _responderView.editImageView.frame = _responderView.startRect;
         
         _responderView.newTransform = responderEditStartTransform;
         _responderView.editImageView.center = startCenter;
         
         CGAffineTransform currentTransform = CGAffineTransformScale(responderTransform, 1, 1);
         _responderView.transform = currentTransform;

         willShowBar.frame = CGRectMake(willShowBar.frame.origin.x, willShowBar.frame.origin.y+willShowBar.frame.size.height, willShowBar.frame.size.width, willShowBar.frame.size.height);
         
     }completion:^(BOOL finished)
     {
         [UIView animateWithDuration:ANIMATIONDURATION animations:
          ^{

            CGAffineTransform currentTransform = CGAffineTransformScale(showTransform, 1, 1);
              showView.transform = currentTransform;
              
              _responderView.frame = responderStartRect;
              _responderView.transform = responderStartTransform;
              
              willHideBar.frame = CGRectMake(willHideBar.frame.origin.x, willHideBar.frame.origin.y-willHideBar.frame.size.height, willHideBar.frame.size.width, willHideBar.frame.size.height);
              
          } completion:^(BOOL finishec)
          {
              _responderView.layer.anchorPoint = CGPointMake(0.5, 0.5);
              _responderView.layer.position = responderCenter;
              [showView addSubview:_responderView];
              _responderView = nil;
              isScaleImage = NO;
              
          }];
     }];
}
#pragma mark - 图片互换方法
- (void)exchangeEditImagebegan
{
    UIView *shapeView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, _responderView.frame.size.width, _responderView.frame.size.height)];
    shapeView.alpha = 0.6;
    shapeView.backgroundColor = [UIColor blackColor];
    [_responderView addSubview:shapeView];
    isExchangeImage = YES;
    
    [UIView animateWithDuration:ANIMATIONDURATION animations:^
     {
         willHideBar.frame = CGRectMake(willHideBar.frame.origin.x, willHideBar.frame.origin.y+willHideBar.frame.size.height, willHideBar.frame.size.width, willHideBar.frame.size.height);
     }completion:^(BOOL finished){
         [UIView animateWithDuration:ANIMATIONDURATION animations:^
          {
              willShowBar.frame = CGRectMake(willShowBar.frame.origin.x, willShowBar.frame.origin.y-willShowBar.frame.size.height, willShowBar.frame.size.width, willShowBar.frame.size.height);
          }];
    }];
}

- (void)exchangeEditImageEnd
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:^
     {
         willShowBar.frame = CGRectMake(willShowBar.frame.origin.x, willShowBar.frame.origin.y+willShowBar.frame.size.height, willShowBar.frame.size.width, willShowBar.frame.size.height);
     }completion:^(BOOL finished){
         [UIView animateWithDuration:ANIMATIONDURATION animations:^
          {
              willHideBar.frame = CGRectMake(willHideBar.frame.origin.x, willHideBar.frame.origin.y-willHideBar.frame.size.height, willHideBar.frame.size.width, willHideBar.frame.size.height);
              isExchangeImage = NO;
          }];
     }];
}
#pragma mark -  替换图片方法
- (void)changeEditImage:(UIImage *)img
{
    _responderView.newTransform = _responderView.initTransform;
    [_responderView setEditImage:img];
}

- (void)setResponderView:(SCMaskView *)responderView
{
    _responderView = responderView;
    responderStartRect = responderView.frame;
    responderEditStartTransform = responderView.newTransform;
    startCenter = responderView.editImageView.center;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"hittest");
    if (!ishit_test)
    {
        ishit_test = YES;
        return nil;
    }
    ishit_test = NO;
    if (isScaleImage)
    {
        return _responderView;
    }
    for (int i = 0; i < [maskImageArray count]; i++)
    {
        SCMaskView *tempView = (SCMaskView *)[self viewWithTag:i+10];
        
        CGColorRef pixelColor = [[self colorAtPixel:point andImage:[maskImageArray objectAtIndex:i]] CGColor];
        
        CGFloat alpha = CGColorGetAlpha(pixelColor);
        
        if (alpha == 1)
        {
            if (isExchangeImage)
            {
                UIImage *tempImage = _responderView.editImageView.image;
                _responderView.newTransform = _responderView.initTransform;
                tempView.newTransform = tempView.initTransform;
                [_responderView.subviews.lastObject removeFromSuperview];
                [_responderView setEditImage:tempView.editImageView.image];
                [tempView setEditImage:tempImage];
                [self exchangeEditImageEnd];
                return nil;
            }
            self.responderView = tempView;
            if (isFilterImage)
            {
                UIView *blackTipView = [[UIView alloc]initWithFrame:self.responderView.frame];
                blackTipView.backgroundColor = [UIColor blackColor];
                blackTipView.alpha = 0.7;
                [_responderView addSubview:blackTipView];
                
                [UIView animateWithDuration:0.1 animations:^{blackTipView.alpha = 0;} completion:^(BOOL finished) {
                    if (finished)
                    {
                        [blackTipView removeFromSuperview];
                    }
                }];
            }
            return tempView;
        }
        else
        {
            continue;
        }
    }
    return nil;
}

- (UIColor *)colorAtPixel:(CGPoint)point andImage:(UIImage *)image
{
    // Cancel if point is outside image coordinates
    if (!CGRectContainsPoint(CGRectMake(0.0f, 0.0f, image.size.width, image.size.height), point)) {
        return nil;
    }
    
    // Create a 1x1 pixel byte array and bitmap context to draw the pixel into.
    // Reference: http://stackoverflow.com/questions/1042830/retrieving-a-pixel-alpha-value-for-a-uiimage
    NSInteger pointX = trunc(point.x);
    NSInteger pointY = trunc(point.y);
    CGImageRef cgImage = image.CGImage;
    NSUInteger width = image.size.width;
    NSUInteger height = image.size.height;
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    int bytesPerPixel = 4;
    int bytesPerRow = bytesPerPixel * 1;
    NSUInteger bitsPerComponent = 8;
    unsigned char pixelData[4] = { 0, 0, 0, 0 };
    CGContextRef context = CGBitmapContextCreate(pixelData,
                                                 1,
                                                 1,
                                                 bitsPerComponent,
                                                 bytesPerRow,
                                                 colorSpace,
                                                 kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    CGColorSpaceRelease(colorSpace);
    CGContextSetBlendMode(context, kCGBlendModeCopy);
    
    // Draw the pixel we are interested in onto the bitmap context
    CGContextTranslateCTM(context, -pointX, pointY-(CGFloat)height);
    CGContextDrawImage(context, CGRectMake(0.0f, 0.0f, (CGFloat)width, (CGFloat)height), cgImage);
    CGContextRelease(context);
    
    // Convert color values [0..255] to floats [0.0..1.0]
    CGFloat red   = (CGFloat)pixelData[0] / 255.0f;
    CGFloat green = (CGFloat)pixelData[1] / 255.0f;
    CGFloat blue  = (CGFloat)pixelData[2] / 255.0f;
    CGFloat alpha = (CGFloat)pixelData[3] / 255.0f;
    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

- (void)dealloc
{
    NSLog(@".....");
    maskImageArray = nil;
    showView = nil;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
        [MBProgressHUD hideAllHUDsForView:app.window animated:YES];
    });
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
