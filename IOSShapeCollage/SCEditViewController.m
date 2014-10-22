//
//  SCEditViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCEditViewController.h"
#import "SCAppDelegate.h"
#import "UIImage+SubImage.h"
#import "SCShareViewController.h"
#import "SCCustomScrollView.h"
#import "SCMaskView.h"

#define ACTIONBARINITRECT (CGRectMake(0, self.view.frame.size.height-44, kScreen_Width, self.view.frame.size.height-44-(maskTouchView.frame.origin.y+maskTouchView.frame.size.height)))
#define ALPHACOLOR colorWithHexString(@"#2d2d2d")

#define kToMorePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shareImage.jpg"]


@interface SCEditViewController ()

@property (nonatomic, strong) UIView *filterSelectedView;

@end

@implementation SCEditViewController
@synthesize filterSelectedView = _filterSelectedView;
@synthesize modelPieces;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        // Custom initialization
    }
    return self;
}

- (id)initWithPieces:(NSInteger)pieces andType:(NSString *)type
{
    self = [super init];
    if (self)
    {
        self.modelPieces = pieces;
        modelChangeSelectedName = type;
        modelChooseIconArray = [[NSMutableArray alloc]init];

        for (NSString *tempString in [PRJ_Global shareStance].modelArray)
        {
            NSInteger pieces = [[[[[tempString lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:1] integerValue];
            if (pieces == self.modelPieces)
            {
                [modelChooseIconArray addObject:tempString];
            }
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^
                       {
                           filterIconArray = [getImagesArray(@"滤纸图标", @"png") mutableCopy];
                       });
        
        [self initSubViews];
        // Custom initialization
    }
    return self;
}

- (void)setInfoDictionary:(NSDictionary *)infoDic
{
    infoDictionary = [NSDictionary dictionaryWithDictionary:infoDic];
    NSString *directory = [infoDictionary objectForKey:@"backGroundImage"];
    modelChangeSelectedName = directory;
    maskTouchView.showView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[infoDictionary objectForKey:@"backGroundImage"] ofType:@"jpg" inDirectory:directory]];
    
    maskImageArray = [self getMaskResourceWithNames:[NSArray arrayWithArray:[infoDic objectForKey:@"imageName"]]];
    imageRectArray = [self transitionImageRectToEditRect:[NSArray arrayWithArray:[infoDic objectForKey:@"imageRect"]]];
    
}

- (void)setEditImageArray:(NSArray *)imageArray
{
    editImageArray = [NSArray arrayWithArray:imageArray];
    [maskTouchView setupWithMaskImageArray:maskImageArray andRectArray:imageRectArray andEditImageArray:editImageArray];
}

#pragma mark - 转换坐标原图至显示区大小
- (NSArray *)transitionImageRectToEditRect:(NSArray *)ImgRectArray
{
    CGSize editSize = KEditArea(1, 1);
    
    CGFloat scaleW = editSize.width/maskTouchView.showView.image.size.width;
    CGFloat scaleH = editSize.height/maskTouchView.showView.image.size.height;
    
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
    
    SCMaskTouchView *maskTouch = [[SCMaskTouchView alloc]initWithFrame:CGRectMake(0, 0, editSize.width, editSize.height)];
    maskTouch.delegate = self;
    
    maskTouchView = maskTouch;
    
    modelBarView = [[UIView alloc]initWithFrame:CGRectZero];
    modelBarView.backgroundColor = [UIColor clearColor];
    
    scaleViewActionBar = [[UIView alloc]initWithFrame:CGRectZero];
    scaleViewActionBar.backgroundColor = [UIColor clearColor];
    
    filterBarView = [[UIView alloc]initWithFrame:CGRectZero];
    filterBarView.backgroundColor = [UIColor clearColor];
    
    tipBarView = [[UIView alloc]initWithFrame:CGRectZero];
    tipBarView.backgroundColor = [UIColor clearColor];
    
    [self.view addSubview:maskTouchView];
    [self.view addSubview:scaleViewActionBar];
    [self.view addSubview:filterBarView];
    [self.view addSubview:modelBarView];
    [self.view addSubview:tipBarView];

    
}

- (void)actionBarViewTapAction:(UITapGestureRecognizer *)tap
{
    [actionBarView removeFromSuperview];
}

- (void)hideButtonPressed:(id)sender
{
    [actionBarView removeFromSuperview];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = colorWithHexString(@"#202020");
    self.title = @"CollageShape";
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: colorWithHexString(@"#28d8c9"),NSFontAttributeName:[UIFont fontWithName:FONTNAMESTRING size:17]};
    
    leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftItemButton setFrame:CGRectMake(0, 0, 30, 30)];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [leftItemButton setBackgroundImage:[UIImage imageNamed:@"edit_back.png"] forState:UIControlStateNormal];
    [leftItemButton addTarget:self action:@selector(leftItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    leftItemButton.imageView.contentMode = UIViewContentModeCenter;
    
    rightItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItemButton.frame = CGRectMake(kScreen_Width-44, 0, 30, 30);
    [rightItemButton setBackgroundImage:[UIImage imageNamed:@"edit_share.png"] forState:UIControlStateNormal];
    [rightItemButton addTarget:self action:@selector(rightItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;
    
    leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftItemButton];
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,leftItem, nil];
    
    rightItem = [[UIBarButtonItem alloc]initWithCustomView:rightItemButton];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem, nil];
    
    modelBarView.frame = CGRectMake(0, maskTouchView.frame.origin.y+maskTouchView.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-44-maskTouchView.frame.origin.y-maskTouchView.frame.size.height);
    UIView *modelBarViewAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, modelBarView.frame.size.width, modelBarView.frame.size.height)];
    modelBarViewAlpha.backgroundColor = ALPHACOLOR;
    modelBarViewAlpha.alpha = 0.9;
    [modelBarView addSubview:modelBarViewAlpha];
    
    modelChooseScroll = [[SCCustomScrollView alloc]initWithFrame:CGRectMake(0, 0, modelBarView.frame.size.width, modelBarView.frame.size.height)];
    [modelBarView addSubview:modelChooseScroll];
    
    modelChangeSelected = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 90, 90)];
    modelChangeSelected.image = [UIImage imageNamed:@"Edit_chosen-frame"];
    [modelChooseScroll addSubview:modelChangeSelected];
    
    @autoreleasepool {
        for (int i = 0; i < [modelChooseIconArray count]; i++)
        {
            UIButton *modelChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            modelChooseButton.frame = CGRectMake(5+15*i+80*i, 0, 80, 80);
            [modelChooseButton addTarget:self action:@selector(modelChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            modelChooseButton.tag = i+10;
            modelChooseButton.center = CGPointMake(modelChooseButton.center.x, modelChooseScroll.frame.size.height/2);
            [modelChooseButton setBackgroundImage:[UIImage imageWithContentsOfFile:[modelChooseIconArray objectAtIndex:i]] forState:UIControlStateNormal];
            if ([modelChangeSelectedName isEqualToString:[[[[[modelChooseIconArray objectAtIndex:i] lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0]])
            {
                modelChooseButton.frame = CGRectMake(modelChooseButton.frame.origin.x-5, modelChooseButton.frame.origin.y-5, 86, 86);
                modelChangeSelected.center = modelChooseButton.center;
                selectedTag = modelChooseButton.tag;
            }
            [modelChooseScroll addSubview:modelChooseButton];
            modelChooseScroll.contentSize = CGSizeMake(modelChooseButton.frame.size.width+modelChooseButton.frame.origin.x, modelChooseScroll.frame.size.height);
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
    
    filterScrollView = [[SCCustomScrollView alloc]initWithFrame:CGRectMake(0, 0, filterBarView.frame.size.width, filterBarView.frame.size.height-36)];
    filterScrollView.backgroundColor = [UIColor clearColor];
    [filterBarView addSubview:filterScrollView];
    
    self.filterSelectedView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 64, 64)];
    self.filterSelectedView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"edit_filter_chosen-frame"]];
    [filterScrollView addSubview:self.filterSelectedView];
    
    @autoreleasepool {
        for (int i = 0; i < [filterIconArray count] ; i++)
        {
            UIButton *filterChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            filterChooseButton.frame = CGRectMake(10+60*i+10*i, 0, 60, 60);
            filterChooseButton.center = CGPointMake(filterChooseButton.center.x, filterScrollView.frame.size.height/2);
            if (i == 0)
            {
                self.filterSelectedView.center = filterChooseButton.center;
            }
            filterChooseButton.tag = i+10;
            [filterChooseButton addTarget:self action:@selector(filterChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [filterChooseButton setBackgroundImage:[UIImage imageWithContentsOfFile:[filterIconArray objectAtIndex:i]] forState:UIControlStateNormal];
            [filterScrollView addSubview:filterChooseButton];
            filterScrollView.contentSize = CGSizeMake(filterChooseButton.frame.size.width+filterChooseButton.frame.origin.x, filterScrollView.frame.size.height);
        }
    }
    
    UIButton *hideFilterBarViewButton = [UIButton buttonWithType:UIButtonTypeCustom];
    hideFilterBarViewButton.frame = CGRectMake(0, filterBarView.frame.size.height-36, filterBarView.frame.size.width, 36);
    [hideFilterBarViewButton setBackgroundImage:[UIImage imageNamed:@"edit_filter_back"] forState:UIControlStateNormal];
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
    
    tipBarView.frame = CGRectMake(0, self.view.frame.size.height-44, kScreen_Width, 44);
    UIView *tipViewBarAlpha = [[UIView alloc]initWithFrame:CGRectMake(0, 0, tipBarView.frame.size.width, tipBarView.frame.size.height)];
    tipViewBarAlpha.backgroundColor = ALPHACOLOR;
    tipViewBarAlpha.alpha = 0.9;
    [tipBarView addSubview:tipViewBarAlpha];
    
    UILabel *tipLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, tipBarView.frame.size.width, tipBarView.frame.size.height)];
//    tipLabel.text = LocalizedString(@"", @"");
    tipLabel.text = LocalizedString(@"switch_hint_string", nil);
    tipLabel.textColor = [UIColor whiteColor];
    tipLabel.font = [UIFont fontWithName:FONTNAMESTRING size:14];
    tipLabel.backgroundColor = [UIColor clearColor];
    tipLabel.textAlignment = NSTextAlignmentCenter;
    [tipBarView addSubview:tipLabel];
    
    // Do any additional setup after loading the view.
}

#pragma mark - 更换模板
- (void)modelChooseButtonPressed:(id)sender
{
    UIButton *tempselecedButton = (UIButton *)[modelChooseScroll viewWithTag:selectedTag];
    tempselecedButton.frame = CGRectMake(tempselecedButton.frame.origin.x+5, tempselecedButton.frame.origin.y+5, 80, 80);
    
    CGRect maskTouchViewRect = maskTouchView.frame;
    [maskTouchView removeFromSuperview];
    
    UIButton *tempButton = (UIButton *)sender;
    tempButton.frame = CGRectMake(tempButton.frame.origin.x-5, tempButton.frame.origin.y-5, 86, 86);
    modelChangeSelected.center = tempButton.center;
    selectedTag = tempButton.tag;
    
    NSString *tempString = [modelChooseIconArray objectAtIndex:tempButton.tag-10];
    
    NSString *directory = [[[[tempString lastPathComponent]stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0];
    modelChangeSelectedName = directory;
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_profile",directory] ofType:@"plist" inDirectory:directory]];
    
    [self event:@"edit" label:[NSString stringWithFormat:@"home_template_%@",directory]];
    
    SCMaskTouchView *maskTouch = [[SCMaskTouchView alloc]initWithFrame:maskTouchViewRect];
    maskTouch.delegate = self;
    [self.view insertSubview:maskTouch atIndex:0];
    maskTouchView = maskTouch;

    maskTouchView.showView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[infoDic objectForKey:@"backGroundImage"] ofType:@"jpg" inDirectory:directory]];
    
    maskImageArray = [self getMaskResourceWithNames:[NSArray arrayWithArray:[infoDic objectForKey:@"imageName"]]];
    imageRectArray = [self transitionImageRectToEditRect:[NSArray arrayWithArray:[infoDic objectForKey:@"imageRect"]]];
    
    
    [maskTouchView setupWithMaskImageArray:maskImageArray andRectArray:imageRectArray andEditImageArray:editImageArray];
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
            [self event:@"edit" label:@"edit_gallery"];
            UIImagePickerController *sigleImagePicker = [[UIImagePickerController alloc]init];
            sigleImagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            sigleImagePicker.delegate = self;
            [self presentViewController:sigleImagePicker animated:YES completion:nil];
        }
            break;
        case 1:
        {
            //滤镜
            [self event:@"edit" label:@"edit_filter"];
            maskTouchView.isFilterImage = YES;
            SCMaskView *tempMaskView = (SCMaskView *)maskTouchView.responderView;
            UIButton *tempButton = (UIButton *)[filterScrollView viewWithTag:tempMaskView.filterType+10];
            self.filterSelectedView.center = tempButton.center;
            
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
            [self event:@"edit" label:@"edit_revolved"];
            self.title = @"Rotation";
            self.navigationItem.hidesBackButton = YES;
            self.navigationItem.leftBarButtonItem = nil;
            self.navigationItem.rightBarButtonItem = nil;
            
            [maskTouchView setwillShowBar:scaleViewActionBar andWillHideBar:modelBarView];
            [maskTouchView sendResponderViewToEdit];
        }
            break;
        case 3:
        {
            //交换位置
            [self event:@"edit" label:@"edit_replace"];
            [self exchangeMethodAction];
        }
            break;
            
            
        default:
            break;
    }
}

#pragma mark - 滤镜bar按扭方法
- (void)filterChooseButtonPressed:(id)sender
{
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    UIButton *tempButton = (UIButton *)sender;
    self.filterSelectedView.center = tempButton.center;
    [maskTouchView changeFilterWithType:(NCFilterType)tempButton.tag-10];
    
    [self event:@"edit" label:[NSString stringWithFormat:@"edit_filter_%d",tempButton.tag-10]];
    
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
    self.title = @"ShapeCollage";
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = -5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,leftItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem, nil];
}
- (void)scaleViewOriginButton:(id)sender
{
    [maskTouchView maskViewOriginEdit];
}
- (void)scaleViewSureButton:(id)sender
{
    [maskTouchView maskViewEndEdit];
    self.title = @"ShapeCollage";
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    negativeSpacer.width = - 5;
    self.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,leftItem, nil];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,rightItem, nil];
}
#pragma mark - 交换位置按扭方法
- (void)exchangeMethodAction
{
    [maskTouchView setwillShowBar:tipBarView andWillHideBar:modelBarView];
    [maskTouchView exchangeEditImagebegan];
}

#pragma mark - 导航按扭方法
- (void)leftItemButtonPressed:(id)sender
{
    [self event:@"edit" label:@"edit_back"];
    [self.navigationController popViewControllerAnimated:YES];
//    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightItemButtonPressed:(id)sender
{
    SCShareViewController *shareCV = [[SCShareViewController alloc]init];
    [shareCV getImageFromView:maskTouchView];
    [self.navigationController pushViewController:shareCV animated:YES];
    
}

#pragma mark - imagePickerDelegate
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
{
    [maskTouchView changeEditImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
}

#pragma mark 事件统计
- (void)event:(NSString *)eventID label:(NSString *)label;
{
    //友盟
    [MobClick event:eventID label:label];
    
    //Flurry
    [Flurry logEvent:eventID];
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
