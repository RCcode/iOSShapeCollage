//
//  SCMaskView.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCMaskView.h"
#import "UIImage+SubImage.h"
@implementation SCMaskView

@synthesize editImageView;
@synthesize maskImage = _maskImage;
@synthesize mask;
@synthesize newTransform = _newTransform;
@synthesize editShowView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        [self setUp];
        // Initialization code
    }
    return self;
}

- (void)setUp
{
    mask = [CALayer layer];
    mask.frame = self.frame;
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.mask = mask;
    self.layer.masksToBounds = YES;
    
    editShowView = [[UIView alloc]initWithFrame:self.frame];
    editShowView.backgroundColor = [UIColor clearColor];
    [self addSubview:editShowView];
    
    editImageView = [[UIImageView alloc]initWithFrame:self.frame];
    editImageView.userInteractionEnabled = YES;
    [self addSubview:editImageView];
    
    
    
    //缩放手势
    UIPinchGestureRecognizer *pinchRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scale:)];
    pinchRecognizer.delegate = self;
    [self addGestureRecognizer:pinchRecognizer];

    //旋转手势
    UIRotationGestureRecognizer *rotationRecognizer = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotate:)];
    rotationRecognizer.delegate = self;
    [self addGestureRecognizer:rotationRecognizer];


}

- (void)setMaskImage:(UIImage *)maskImage
{
    _maskImage = maskImage;
    mask.contents = (id)maskImage.CGImage;
}

- (void)setEditImage:(UIImage *)picture
{
    _filterBeforeImage = picture;
    float scalePicture = picture.size.width/picture.size.height;

    CGSize tempEditImageViewSize = CGSizeMake(editShowView.frame.size.width, editShowView.frame.size.width/scalePicture);
    if (tempEditImageViewSize.height < editShowView.frame.size.height)
    {
        tempEditImageViewSize = CGSizeMake(editShowView.frame.size.height*scalePicture, editShowView.frame.size.height);
    }
    
    editImageView.frame = CGRectMake(editImageView.frame.origin.x, editImageView.frame.origin.y, tempEditImageViewSize.width, tempEditImageViewSize.height);

    editImageView.image = picture;
    startRect = editImageView.frame;
    _newTransform = editImageView.transform;
}

- (void)setNewTransform:(CGAffineTransform)newTransform
{
    _newTransform = newTransform;
    editImageView.transform = newTransform;
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint point2 = [touch locationInView:self];
    CGPoint point1 = [touch previousLocationInView:self];
    
    editImageView.center = CGPointMake(editImageView.center.x + (point2.x-point1.x), editImageView.center.y + (point2.y-point1.y));
//
}


#pragma mark -
#pragma mark 缩放编辑图片
-(void)scale:(UIPinchGestureRecognizer*)sender
{
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    //当手指离开屏幕时,将lastscale设置为1.0
    if([sender state] == UIGestureRecognizerStateEnded )
    {
        lastScale = 1.0;
        return;
    }
    
    CGAffineTransform currentTransform = editImageView.transform;
    CGAffineTransform changeTransform = CGAffineTransformScale(currentTransform, scale, scale);
    editImageView.transform = changeTransform;
    
    _newTransform = changeTransform;
    
//    CGRect tempRect ;
//    if (scale > 1)
//    {
//        tempRect = CGRectMake(editImageView.frame.origin.x-editImageView.frame.size.width*(scale-1)/2, editImageView.frame.origin.y-editImageView.frame.size.height*(scale-1), editImageView.frame.size.width*scale, editImageView.frame.size.height*scale);
//    }
//    else
//    {
//        tempRect = CGRectMake(editImageView.frame.origin.x+editImageView.frame.size.width*(1-scale)/2, editImageView.frame.origin.y+editImageView.frame.size.height*(1-scale), editImageView.frame.size.width*scale, editImageView.frame.size.height*scale);
//    }
    
    
//    if (tempRect.origin.x >= 0)
//    {
//        tempRect = CGRectMake(0, tempRect.origin.y, tempRect.size.width, tempRect.size.height);
//    }
//    if (tempRect.origin.y >= 0)
//    {
//        tempRect = CGRectMake(tempRect.origin.x, 0, tempRect.size.width, tempRect.size.height);
//    }
//    if (self.frame.size.width >= tempRect.size.width + tempRect.origin.x)
//    {
//        tempRect = CGRectMake(self.frame.size.width-tempRect.size.width, tempRect.origin.y, tempRect.size.width, tempRect.size.height);
//    }
//    if (self.frame.size.height >= tempRect.size.height + tempRect.origin.y)
//    {
//        tempRect = CGRectMake(tempRect.origin.x, self.frame.size.height-tempRect.size.height, tempRect.size.width, tempRect.size.height);
//    }
    
    lastScale = [sender scale];
    
//    if (tempRect.size.width <= self.frame.size.width || tempRect.size.height <= self.frame.size.height)
//    {
//        tempRect = startRect;
//        lastScale = 1;
//    }
//    editImageView.frame = tempRect;
    
    
}


#pragma mark 旋转编译图片
- (void)rotate:(UIRotationGestureRecognizer *)sender
{

    if([sender state] == UIGestureRecognizerStateEnded)
    {
        _lastRotation = 0.0;
        return;
    }

    CGFloat rotation = 0.0 - (_lastRotation - [sender rotation]);
    CGAffineTransform currentTransform = editImageView.transform;
    CGAffineTransform changeTransform = CGAffineTransformRotate(currentTransform,rotation);

    [editImageView setTransform:changeTransform];
    _newTransform = changeTransform;
    _lastRotation = [sender rotation];
}

#pragma mark - UIGestureRecogernizeDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
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
