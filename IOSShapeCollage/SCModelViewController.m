//
//  SCModelViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCModelViewController.h"
#import "MHImagePickerMutilSelector.h"
#import "SCEditViewController.h"
#import "SCMulImagePickerViewController.h"
#import "SCCustomScrollView.h"
#import "ME_MoreAppViewController.h"
#import "SliderViewController.h"
#import "SCAppDelegate.h"
#import "Pic_AdMobShowTimesManager.h"

@import Photos;

@interface SCModelViewController ()

@end

@implementation SCModelViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
                // Custom initialization
    }
    return self;
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    [[SliderViewController sharedSliderController].navigationController setNavigationBarHidden:YES];
    
}

- (void)getPhotos
{
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    if (self.photoGroupArray == nil) {
        _photoGroupArray = [[NSMutableArray alloc] init];
    } else {
        [self.photoGroupArray removeAllObjects];
    }
    
    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
    };
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        [group setAssetsFilter:onlyPhotosFilter];
        if ([group numberOfAssets] > 0)
        {
            [self.photoGroupArray addObject:group];
            NSLog(@"%@",self.photoGroupArray);
        }
        
    };
    
    // enumerate only photos
    NSUInteger groupTypes = ALAssetsGroupAll/*ALAssetsGroupLibrary|ALAssetsGroupAlbum|ALAssetsGroupSavedPhotos*/;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (app.isbecomeActivity)
    {
        if ([Pic_AdMobShowTimesManager canShowCustomAds])
        {
            [Pic_AdMobShowTimesManager presentViewCompletion:^
             {
                 [Pic_AdMobShowTimesManager showCustomSeccess];
                 app.isbecomeActivity = NO;
             }];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self getPhotos];
    
    self.view.backgroundColor = colorWithHexString(@"#202020");
    
    UIView *navView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    navView.backgroundColor = colorWithHexString(@"#2d2d2d");
    [self.view addSubview:navView];
    
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:navView.frame];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.font = [UIFont fontWithName:FONTNAMESTRING size:17];
    titleLabel.text = @"CollageShape";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColor = colorWithHexString(@"#28d8c9");
    [navView addSubview:titleLabel];
    
    UIButton *leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftItemButton setFrame:CGRectMake(10, 7, 30, 30)];
    [leftItemButton setBackgroundImage:[UIImage imageNamed:@"pattern_slide"] forState:UIControlStateNormal];
    [leftItemButton addTarget:self action:@selector(leftItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:leftItemButton];
    
    UIButton *rightItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightItemButton.frame = CGRectMake(kScreen_Width-30-10, 7, 30, 30);
    [rightItemButton setBackgroundImage:[UIImage imageNamed:@"pattern_moreapps"] forState:UIControlStateNormal];
    [rightItemButton addTarget:self action:@selector(rightItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [navView addSubview:rightItemButton];
    
    SCCustomScrollView *scrollView = [[SCCustomScrollView alloc]initWithFrame:CGRectMake(0, 44, self.view.frame.size.width, self.view.frame.size.height-44)];
    scrollView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:scrollView];
    
    for (int i = 0; i < [[PRJ_Global shareStance].modelArray count]; i ++)
    {
        @autoreleasepool
        {
            UIButton *modelChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            int location_x = i%2;
            int location_y = i/2;
            
            modelChooseButton.frame = CGRectMake(7.5+150*location_x+5*location_x, 7.5+150*location_y+5*location_y, 150, 150);
            [modelChooseButton addTarget:self action:@selector(modelChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            modelChooseButton.tag = i+10;
//            [modelChooseButton setTitle:[NSString stringWithFormat:@"模板%d",i+1] forState:UIControlStateNormal];
//            [modelChooseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [modelChooseButton setBackgroundImage:[UIImage imageWithContentsOfFile:[[PRJ_Global shareStance].modelArray objectAtIndex:i]] forState:UIControlStateNormal];
            [scrollView addSubview:modelChooseButton];
            scrollView.contentSize = CGSizeMake(scrollView.frame.size.width, modelChooseButton.frame.size.height+modelChooseButton.frame.origin.y);
        }
        
    }

    // Do any additional setup after loading the view.
}

#pragma mark - 导航按扭方法
- (void)leftItemButtonPressed:(id)sender
{
    [self event:@"home" label:@"home_menu"];
    [[SliderViewController sharedSliderController]showLeftViewController];
}
- (void)rightItemButtonPressed:(id)sender
{
    [self event:@"home" label:@"home_more"];
//    ME_MoreAppViewController *moreApp = [[ME_MoreAppViewController alloc]initWithNibName:@"ME_MoreAppViewController" bundle:nil];
    ME_MoreAppViewController *moreApp = [[ME_MoreAppViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:moreApp];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title-bar.png"] forBarMetrics:UIBarMetricsDefault];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nav.navigationBar.backgroundColor = [UIColor clearColor];
    [[SliderViewController sharedSliderController] presentViewController:nav animated:YES completion:nil];
}

- (void)modelChooseButtonPressed:(id)sender
{
    UIButton *tempButton = (UIButton *)sender;
    NSString *directory = [[[[[[PRJ_Global shareStance].modelArray objectAtIndex:tempButton.tag-10] lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0];
    
    NSInteger pieces = [[[[[[[PRJ_Global shareStance].modelArray objectAtIndex:tempButton.tag-10] lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:1] integerValue];
    
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_profile",directory] ofType:@"plist" inDirectory:directory]];
    
    [self event:@"home" label:[NSString stringWithFormat:@"home_template_%@",directory]];
    
    editControll = [[SCEditViewController alloc]initWithPieces:pieces andType:directory];
    [editControll setInfoDictionary:infoDic];
    
    imagePickerMutilSelector=[[MHImagePickerMutilSelector alloc]init];//自动释放
    imagePickerMutilSelector.maxImageCount = [[infoDic objectForKey:@"imageName"]count];
    imagePickerMutilSelector.delegate = self;
    
    [PRJ_Global shareStance].MHImagePickerdelegate = imagePickerMutilSelector;
    
//    UIImagePickerController* picker=[[UIImagePickerController alloc] init];
//    picker.navigationController.delegate=imagePickerMutilSelector;
//    picker.delegate = imagePickerMutilSelector;//将UIImagePi cker的代理指向
//    [picker setAllowsEditing:NO];
//    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
//    picker.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
//    imagePickerMutilSelector.imagePicker=picker;//使imagePickerMutilSelector得知其控制的UIImagePicker实例，为释放时需要。
//    //将UIImagePicker的导航代理指向到imagePickerMutilSelector
//    [self presentViewController:picker animated:YES completion:nil];
    
    
    
    SCMulImagePickerViewController *mulImagePiker = [[SCMulImagePickerViewController alloc]init];
    UINavigationController *presentNav = [[UINavigationController alloc]initWithRootViewController:mulImagePiker];
    presentNav.delegate = imagePickerMutilSelector;
    mulImagePiker.photoGroupArray = self.photoGroupArray;
    [[SliderViewController sharedSliderController] presentViewController:presentNav animated:YES completion:nil];
    
}

-(void)imagePickerMutilSelectorDidGetImages:(NSArray *)imageArray
{
    [editControll setEditImageArray:imageArray];

    [[SliderViewController sharedSliderController].navigationController pushViewController:editControll animated:YES];
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

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
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
