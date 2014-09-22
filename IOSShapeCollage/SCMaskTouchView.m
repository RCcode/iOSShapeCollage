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

@implementation SCMaskTouchView

@synthesize delegate;
@synthesize isFilterImage;
@synthesize isScaleImage;

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

- (void)setupWithMaskImageArray:(NSArray *)maskArray andRectArray:(NSArray *)rectArray andEditImageArray:(NSArray *)editArray
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
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
        SCMaskView *mask = [[SCMaskView alloc]initWithFrame:self.frame];
        mask.editShowView.frame = CGRectFromString([rectArray objectAtIndex:i]);
        mask.editImageView.frame = mask.editShowView.frame;
        [mask setMaskImage:[UIImage imageWithContentsOfFile:[maskArray objectAtIndex:i]]];
        [mask setEditImage:[editArray objectAtIndex:i]];
        mask.tag = i+10;
        [showView addSubview:mask];
    }
}

- (void)initSubViews
{
//    CGPoint point = [tap locationInView:self.view];
    
    showView = [[UIView alloc]initWithFrame:self.frame];
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
    if (isScaleImage || isFilterImage)
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

- (void)setBarView:(UIView *)barView
{
    actionBar = barView;
}
- (void)setModelChooseBarView:(UIView *)chooseBar
{
    modelChooseBar = chooseBar;
}

- (void)changeFilterWithType:(NCFilterType)type
{
    if(_videoCamera == nil){
        _videoCamera = [NCVideoCamera videoCamera];
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
}


- (void)sendResponderViewToEdit
{
    isScaleImage = YES;
    [self addSubview:_responderView];
    responderCenter = _responderView.center;
    
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
        modelChooseBar.frame = CGRectMake(modelChooseBar.frame.origin.x, modelChooseBar.frame.origin.y+modelChooseBar.frame.size.height, modelChooseBar.frame.size.width, modelChooseBar.frame.size.height);
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
                
                actionBar.frame = CGRectMake(actionBar.frame.origin.x, actionBar.frame.origin.y-actionBar.frame.size.height, actionBar.frame.size.width, actionBar.frame.size.height);
                
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
         
         actionBar.frame = CGRectMake(actionBar.frame.origin.x, actionBar.frame.origin.y+actionBar.frame.size.height, actionBar.frame.size.width, actionBar.frame.size.height);
         
     }completion:^(BOOL finished)
     {
         [UIView animateWithDuration:ANIMATIONDURATION animations:
          ^{
              
              CGAffineTransform currentTransform = CGAffineTransformScale(showTransform, 1, 1);
              showView.transform = currentTransform;
              _responderView.transform = responderStartTransform;
              _responderView.frame = responderStartRect;
              modelChooseBar.frame = CGRectMake(modelChooseBar.frame.origin.x, modelChooseBar.frame.origin.y-modelChooseBar.frame.size.height, modelChooseBar.frame.size.width, modelChooseBar.frame.size.height);
              
          } completion:^(BOOL finishec)
          {
              _responderView.layer.anchorPoint = CGPointMake(0.5, 0.5);
              _responderView.layer.position = responderCenter;
              //              tempResponderView.hidden = NO;
              //              _responderView.hidden = YES;
              [showView addSubview:_responderView];
              _responderView = nil;
              isScaleImage = NO;
              
          }];
     }];

}

- (void)maskViewOriginEdit
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:^{
        _responderView.newTransform = responderEditStartTransform;
    }];
}
- (void)maskViewCancelEdit
{
    [UIView animateWithDuration:ANIMATIONDURATION animations:
     ^{
         CGAffineTransform currentTransform = CGAffineTransformScale(responderTransform, 1, 1);
         _responderView.transform = currentTransform;

         actionBar.frame = CGRectMake(actionBar.frame.origin.x, actionBar.frame.origin.y+actionBar.frame.size.height, actionBar.frame.size.width, actionBar.frame.size.height);
         
     }completion:^(BOOL finished)
     {
         [UIView animateWithDuration:ANIMATIONDURATION animations:
          ^{
              
              CGAffineTransform currentTransform = CGAffineTransformScale(showTransform, 1, 1);
              showView.transform = currentTransform;
              _responderView.transform = responderStartTransform;
              _responderView.frame = responderStartRect;
              _responderView.newTransform = responderEditStartTransform;
              modelChooseBar.frame = CGRectMake(modelChooseBar.frame.origin.x, modelChooseBar.frame.origin.y-modelChooseBar.frame.size.height, modelChooseBar.frame.size.width, modelChooseBar.frame.size.height);
              
          } completion:^(BOOL finishec)
          {
              _responderView.layer.anchorPoint = CGPointMake(0.5, 0.5);
              _responderView.layer.position = responderCenter;
              //              tempResponderView.hidden = NO;
              //              _responderView.hidden = YES;
              [showView addSubview:_responderView];
              _responderView = nil;
              isScaleImage = NO;
              
          }];
     }];
}
//
- (void)setResponderView:(SCMaskView *)responderView
{
//    tempResponderView = responderView;
//    _responderView.frame = responderView.frame;
//    responderStartRect = responderView.frame;
//    _responderView.maskImage = responderView.maskImage;
//    
//    _responderView.editImageView.frame = responderView.editImageView.frame;
//    _responderView.editShowView.frame = responderView.editShowView.frame;
//    
//    _responderView.newTransform = responderView.newTransform;
//    _responderView.maskImage = responderView.maskImage;
//    [_responderView setEditImage:responderView.editImageView.image];
//    
//    _responderView.transform = responderView.transform;
//    _responderView.hidden = YES;
//    _responderView.tag = responderView.tag;
    
    _responderView = responderView;
    responderStartRect = responderView.frame;
    responderEditStartTransform = responderView.newTransform;
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    NSLog(@"%@",event);
    NSLog(@"hittest");
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
            self.responderView = tempView;
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
