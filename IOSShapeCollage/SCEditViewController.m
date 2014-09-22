//
//  SCEditViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCEditViewController.h"
#import "SCAppDelegate.h"

#define ACTIONBARINITRECT (CGRectMake(0, self.view.frame.size.height-64, kScreen_Width, self.view.frame.size.height-64-(maskTouchView.frame.origin.y+maskTouchView.frame.size.height)))
#define ALPHACOLOR colorWithHexString(@"#2d2d2d")

@interface SCEditViewController ()

@end

@implementation SCEditViewController

@synthesize backGroundImageView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           filterIconArray = [getImagesArray(@"滤纸图标", @"png") mutableCopy];;
                       });
        
        [self initSubViews];
        // Custom initialization
    }
    return self;
}

- (void)setInfoDictionary:(NSDictionary *)infoDic
{
    maskImageArray = [self getMaskResourceWithNames:[NSArray arrayWithArray:[infoDic objectForKey:@"imageName"]]];
    imageRectArray = [self transitionImageRectToEditRect:[NSArray arrayWithArray:[infoDic objectForKey:@"imageRect"]]];
}

- (void)setEditImageArray:(NSArray *)imageArray
{
    editImageArray = [NSArray arrayWithArray:imageArray];
}

#pragma mark - 转换坐标原图至显示区大小
- (NSArray *)transitionImageRectToEditRect:(NSArray *)ImgRectArray
{
    CGSize editSize = KEditArea(1, 1);
    
    CGFloat scaleW = editSize.width/backGroundImageView.image.size.width;
    CGFloat scaleH = editSize.height/backGroundImageView.image.size.height;
    
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    for (int i = 0; i < [ImgRectArray count]; i++)
    {
        CGRect imgRect = CGRectFromString([ImgRectArray objectAtIndex:i]);
        CGRect tempRect = CGRectMake(imgRect.origin.x*scaleW, imgRect.origin.y*scaleH, imgRect.size.width*scaleW, imgRect.size.height*scaleH);
        [tempArray addObject:NSStringFromCGRect(tempRect)];
    }
    return tempArray;
}
#pragma mark - 获得mask资源图
- (NSArray *)getMaskResourceWithNames:(NSArray *)nameArray
{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    
    NSString *directory = [[[nameArray objectAtIndex:0] componentsSeparatedByString:@"_"] objectAtIndex:0];
    for (NSString *name in nameArray)
    {
        NSString *path = [[NSBundle mainBundle]pathForResource:name ofType:@"png" inDirectory:directory];
        [tempArray addObject:path];
    }
    
    return tempArray;
}

- (void)initSubViews
{
    
    
    CGSize editSize = KEditArea(1, 1);
    backGroundImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, editSize.width, editSize.height)];
    
    maskTouchView = [[SCMaskTouchView alloc]initWithFrame:CGRectMake(0, 0, editSize.width, editSize.height)];
    maskTouchView.delegate = self;
    
    modelBarView = [[UIView alloc]initWithFrame:CGRectZero];
    modelBarView.backgroundColor = [UIColor clearColor];
    
    scaleViewActionBar = [[UIView alloc]initWithFrame:CGRectZero];
    scaleViewActionBar.backgroundColor = [UIColor clearColor];
    
    filterBarView = [[UIView alloc]initWithFrame:CGRectZero];
    filterBarView.backgroundColor = [UIColor clearColor];
    
    
    
    [self.view addSubview:backGroundImageView];
    [self.view addSubview:maskTouchView];
    [self.view addSubview:scaleViewActionBar];
    [self.view addSubview:filterBarView];
    [self.view addSubview:modelBarView];

    
}

- (void)actionBarViewTapAction:(UITapGestureRecognizer *)tap
{
    [actionBarView removeFromSuperview];
}

- (void)hideButtonPressed:(id)sender
{
    [actionBarView removeFromSuperview];
}


- (void)viewDidAppear:(BOOL)animated
{
    [maskTouchView setupWithMaskImageArray:maskImageArray andRectArray:imageRectArray andEditImageArray:editImageArray];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    modelBarView.frame = CGRectMake(0, maskTouchView.frame.origin.y+maskTouchView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-maskTouchView.frame.origin.y-maskTouchView.frame.size.height);
    UIView *modelBarViewAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, modelBarView.frame.size.width, modelBarView.frame.size.height)];
    modelBarViewAlpha.backgroundColor = ALPHACOLOR;
    modelBarViewAlpha.alpha = 0.9;
    [modelBarView addSubview:modelBarViewAlpha];
    
    @autoreleasepool {
        for (int i = 0; i < [modelChooseIconArray count]; i++)
        {
            UIButton *modelChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            modelChooseButton.frame = CGRectMake(5+15*i+80*i, 0, 80, 80);
            [modelChooseButton addTarget:self action:@selector(modelChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [modelBarView addSubview:modelChooseButton];
        }
    }
    
    scaleViewActionBar.frame = ACTIONBARINITRECT;
    UIView *scaleViewActionBarAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scaleViewActionBar.frame.size.width, scaleViewActionBar.frame.size.height)];
    scaleViewActionBarAlpha.backgroundColor = ALPHACOLOR;
    scaleViewActionBarAlpha.alpha = 0.9;
    [scaleViewActionBar addSubview:scaleViewActionBarAlpha];
    
    UIButton *scaleViewBackButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    scaleViewBackButton.frame = CGRectMake(70, 0, 30, 30);
    scaleViewBackButton.center = CGPointMake(scaleViewBackButton.center.x, scaleViewActionBar.frame.size.height/2);
    [scaleViewBackButton setBackgroundImage:[UIImage imageNamed:@"rotation_cancel"] forState:UIControlStateNormal];
    [scaleViewBackButton addTarget:self action:@selector(scaleViewBackButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [scaleViewActionBar addSubview:scaleViewBackButton];
    
    UIButton *scaleViewOriginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scaleViewOriginButton.frame = CGRectMake(0, 0, 60, 60);
    scaleViewOriginButton.center = CGPointMake(scaleViewActionBar.center.x, scaleViewActionBar.frame.size.height/2);
    [scaleViewOriginButton setBackgroundImage:[UIImage imageNamed:@"rotation_back-to-origin"] forState:UIControlStateNormal];
    [scaleViewOriginButton addTarget:self action:@selector(scaleViewOriginButton:) forControlEvents:UIControlEventTouchUpInside];
    [scaleViewActionBar addSubview:scaleViewOriginButton];
    
    UIButton *scaleViewSureButton = [UIButton buttonWithType:UIButtonTypeCustom];
    scaleViewSureButton.frame = CGRectMake(kScreen_Width-100, 0, 30, 30);
    scaleViewSureButton.center = CGPointMake(scaleViewSureButton.center.x, scaleViewActionBar.frame.size.height/2);
    [scaleViewSureButton setBackgroundImage:[UIImage imageNamed:@"rotation_Ok"] forState:UIControlStateNormal];
    [scaleViewSureButton addTarget:self action:@selector(scaleViewSureButton:) forControlEvents:UIControlEventTouchUpInside];
    [scaleViewActionBar addSubview:scaleViewSureButton];
    
    filterBarView.frame = ACTIONBARINITRECT;
    UIView *filterBarViewAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, scaleViewActionBar.frame.size.width, scaleViewActionBar.frame.size.height)];
    filterBarViewAlpha.backgroundColor = ALPHACOLOR;
    filterBarViewAlpha.alpha = 0.9;
    [filterBarView addSubview:filterBarViewAlpha];
    
    @autoreleasepool {
        for (int i = 0; i < [filterIconArray count] ; i++)
        {
            UIButton *filterChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            filterChooseButton.frame = CGRectMake(60*i, 0, 60, 60);
            filterChooseButton.center = CGPointMake(filterChooseButton.center.x, filterBarView.frame.size.height/2);
            filterChooseButton.tag = i+10;
            [filterChooseButton addTarget:self action:@selector(filterChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [filterChooseButton setBackgroundImage:[UIImage imageWithContentsOfFile:[filterIconArray objectAtIndex:i]] forState:UIControlStateNormal];
            [filterBarView addSubview:filterChooseButton];
        }
    }
    
    UIButton *hideFilterBarViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideFilterBarViewButton.frame = CGRectMake(0, filterBarView.frame.size.height-30, filterBarView.frame.size.width, 30);
    [hideFilterBarViewButton addTarget:self action:@selector(hideFilterBarViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [filterBarView addSubview:hideFilterBarViewButton];
    
    actionBarView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    actionBarView.backgroundColor = [UIColor clearColor];
    
    UIButton *hideButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideButton.frame = actionBarView.frame;
    [hideButton addTarget:self action:@selector(hideButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [actionBarView addSubview:hideButton];
    
    actionBar = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 40)];
    actionBar.layer.cornerRadius = 12;
    actionBar.layer.masksToBounds = YES;
    actionBar.backgroundColor = [UIColor clearColor];
    
    UIView *actionBarAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, actionBar.frame.size.width, actionBar.frame.size.height)];
    actionBarAlpha.backgroundColor = ALPHACOLOR;
    actionBarAlpha.alpha = 0.9;
    [actionBar addSubview:actionBarAlpha];
    
    NSArray *actionButtonImageArray = [NSArray arrayWithObjects:@"edit_pop_gallery",@"edit_pop_filter",@"edit_pop_rotation",@"edit_pop_exchange", nil];
    for (int i = 0; i < [actionButtonImageArray count]; i++)
    {
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        actionButton.frame = CGRectMake(50*i, 0, 50, 40);
        actionButton.tag = i+10;
        [actionButton setBackgroundImage:[UIImage imageNamed:[actionButtonImageArray objectAtIndex:i]] forState:UIControlStateNormal];
        [actionButton addTarget:self action:@selector(actionButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [actionBar addSubview:actionButton];
    }
    
    [hideButton addSubview:actionBar];    
    
    // Do any additional setup after loading the view.
}

#pragma mark - 更换模板
- (void)modelChooseButtonPressed:(id)sender
{
    
}

#pragma mark - maskViewDelegate
- (void)showTheChooseBarAtPoint:(CGPoint)point
{
//    [actionBarView removeFromSuperview];
    [self.view addSubview:actionBarView];
    
    actionBar.center = point;
    if (actionBar.frame.origin.x+actionBar.frame.size.width >= self.view.frame.size.width)
    {
        actionBar.center = CGPointMake(point.x-(actionBar.frame.origin.x+actionBar.frame.size.width - self.view.frame.size.width)-8, point.y);
    }
    if (actionBar.frame.origin.x < 0)
    {
        actionBar.center = CGPointMake(point.x-actionBar.frame.origin.x+8, point.y);
    }
    if (actionBar.frame.origin.y < maskTouchView.frame.origin.y)
    {
        actionBar.center = CGPointMake(point.x, point.y+maskTouchView.frame.origin.y-actionBar.frame.origin.y);
    }
}

- (void)actionButtonPressed:(id)sender
{
    UIButton *tempButton = (UIButton *)sender;
    NSInteger tag = tempButton.tag-10;
    
    [actionBarView removeFromSuperview];
    
    switch (tag) {
        case 0:
        {
            //相册
        }
            break;
        case 1:
        {
            //滤镜
            maskTouchView.isFilterImage = YES;
            [UIView animateWithDuration:ANIMATIONDURATION animations:^{
                modelBarView.frame = CGRectMake(modelBarView.frame.origin.x, modelBarView.frame.origin.y+modelBarView.frame.size.height, modelBarView.frame.size.width, modelBarView.frame.size.height);
            } completion:^(BOOL finished){
                if (finished)
                {
                    [UIView animateWithDuration:ANIMATIONDURATION animations:^{
                        filterBarView.frame = CGRectMake(filterBarView.frame.origin.x, filterBarView.frame.origin.y-filterBarView.frame.size.height, filterBarView.frame.size.width, filterBarView.frame.size.height);
                    }];
                }
            }];
        }
            break;
            
        case 2:
        {
            //编辑
            [maskTouchView setBarView:scaleViewActionBar];
            [maskTouchView setModelChooseBarView:modelBarView];
            [maskTouchView sendResponderViewToEdit];
        }
            break;
        case 3:
        {
            //交换位置
        }
            break;
            
            
        default:
            break;
    }
}

#pragma mark - 滤镜bar按扭方法
- (void)filterChooseButtonPressed:(id)sender
{
    UIButton *tempButton = (UIButton *)sender;
    [maskTouchView changeFilterWithType:(NCFilterType)tempButton.tag-10];
}
- (void)hideFilterBarViewButtonPressed:(id)sender
{
    maskTouchView.isFilterImage = NO;
    [UIView animateWithDuration:ANIMATIONDURATION animations:^{
        filterBarView.frame = CGRectMake(filterBarView.frame.origin.x, filterBarView.frame.origin.y+filterBarView.frame.size.height, filterBarView.frame.size.width, filterBarView.frame.size.height);
    } completion:^(BOOL finished){
        if (finished)
        {
            [UIView animateWithDuration:ANIMATIONDURATION animations:^{
                modelBarView.frame = CGRectMake(modelBarView.frame.origin.x, modelBarView.frame.origin.y-modelBarView.frame.size.height, modelBarView.frame.size.width, modelBarView.frame.size.height);
            }];
        }
    }];
}

#pragma mark - 图片编辑页bar按扭方法
- (void)scaleViewBackButtonPressed:(id)sender
{
    [maskTouchView maskViewCancelEdit];
}
- (void)scaleViewOriginButton:(id)sender
{
    [maskTouchView maskViewOriginEdit];
}
- (void)scaleViewSureButton:(id)sender
{
    [maskTouchView maskViewEndEdit];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
