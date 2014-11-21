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
@synthesize initTransform;
@synthesize editShowView;
@synthesize startRect;

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
////将对象编码(即:序列化)
//-(void) encodeWithCoder:(NSCoder *)aCoder
//{
//    [aCoder encodeCGRect:self.frame forKey:@"frame"];
//    [aCoder encodeObject:editImageView forKey:@"editImageView"];
//    [aCoder encodeObject:_filterBeforeImage forKey:@"filterBefore"];
//    [aCoder encodeObject:_filterAfterImage forKey:@"filterAfter"];
//    [aCoder encodeObject:_maskImage forKey:@"maskImage"];
//    [aCoder encodeObject:mask forKey:@"maskLayer"];
//    [aCoder encodeObject:editShowView forKey:@"editShowView"];
//    [aCoder encodeCGAffineTransform:initTransform forKey:@"initTransform"];
//    [aCoder encodeCGAffineTransform:_newTransform forKey:@"newTransform"];
//    
//}
//
////将对象解码(反序列化)
//-(id) initWithCoder:(NSCoder *)aDecoder
//{
//    if (self=[super init])
//    {
//        self.frame = [aDecoder decodeCGRectForKey:@"frame"];
////        [self setUp];
////        self.editImageView = [aDecoder decodeObjectForKey:@"editImageView"];
////        self.filterBeforeImage = [aDecoder decodeObjectForKey:@"filterBefore"];
////        self.filterAfterImage = [aDecoder decodeObjectForKey:@"filterAfter"];
//        self.maskImage = [aDecoder decodeObjectForKey:@"maskImage"];
//        self.mask = [aDecoder decodeObjectForKey:@"maskLayer"];
////        self.editShowView = [aDecoder decodeObjectForKey:@"editShowView"];
////        self.initTransform = [aDecoder decodeCGAffineTransformForKey:@"initTransform"];
////        self.newTransform = [aDecoder decodeCGAffineTransformForKey:@"newTransform"];
//    }
//    return (self);
//    
//}
- (void)setUp
{
    mask = [CALayer layer];
    mask.frame = self.frame;
    
    self.backgroundColor = [UIColor clearColor];
    self.layer.mask = mask;
    self.layer.masksToBounds = YES;
    
    editShowView = [[UIView alloc]initWithFrame:self.frame];
    editShowView.backgroundColor = [UIColor whiteColor];
    [self addSubview:editShowView];
    
    editImageView = [[UIImageView alloc]initWithFrame:self.frame];
    editImageView.userInteractionEnabled = YES;
    [self addSubview:editImageView];
    
    self.filterType = NC_NORMAL_FILTER;
    
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

- (void)setFilterAfterImage:(UIImage *)filterAfterImage
{
    _filterAfterImage = filterAfterImage;
    editImageView.image = filterAfterImage;
}
- (void)setFilterBeforeImage:(UIImage *)filterBeforeImage
{
    _filterBeforeImage = filterBeforeImage;
}

- (void)setEditImage:(UIImage *)picture
{
    _filterBeforeImage = picture;
    _filterAfterImage = picture;
    float scalePicture = picture.size.width/picture.size.height;

    CGSize tempEditImageViewSize = CGSizeMake(editShowView.frame.size.width, editShowView.frame.size.width/scalePicture);
    if (tempEditImageViewSize.height < editShowView.frame.size.height)
    {
        tempEditImageViewSize = CGSizeMake(editShowView.frame.size.height*scalePicture, editShowView.frame.size.height);
    }
    
    editImageView.frame = CGRectMake(editShowView.frame.origin.x, editShowView.frame.origin.y, tempEditImageViewSize.width, tempEditImageViewSize.height);

    editImageView.image = picture;
    startRect = editImageView.frame;
    _newTransform = editImageView.transform;
    initTransform = editImageView.transform;
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
    NSLog(@"%f---%f",editImageView.center.x,editImageView.center.y);
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

- (void)dealloc
{
    NSLog(@"fhullaiekl");
    editImageView = nil;
    editShowView = nil;
    _filterBeforeImage = nil;
    _filterAfterImage = nil;
    _maskImage = nil;

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
