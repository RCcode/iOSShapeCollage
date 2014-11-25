//
//  SCHomeViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-10-28.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCHomeViewController.h"
#import "ME_MoreAppViewController.h"
#import "SliderViewController.h"
#import "SCModelViewController.h"
#import "SCAppDelegate.h"
#import "Pic_AdMobShowTimesManager.h"

@interface SCHomeViewController ()

@end

@implementation SCHomeViewController


- (void)showAds
{
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

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self showAds];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveNewApp) name:@"addMoreImage" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(noNewApp) name:@"removeMoreImage" object:nil];
    
    [self showAds];
    
    UIImageView *backImageView = [[UIImageView alloc]initWithFrame:self.view.frame];
    if (iPhone5)
    {
        backImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default-568h"]];
    }
    else
    {
        backImageView.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"Default"]];
    }
    [self.view addSubview:backImageView];
    
    UIView *buttonView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreen_Height, kScreen_Width, 209)];
    buttonView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:buttonView];
    
    UIButton *modelChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    modelChooseButton.frame = CGRectMake(0, 70, 169, 49);
    modelChooseButton.center = CGPointMake(self.view.center.x, modelChooseButton.center.y);
    [modelChooseButton addTarget:self action:@selector(modelChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [modelChooseButton setBackgroundImage:[UIImage imageNamed:@"home_template"] forState:UIControlStateNormal];
    [buttonView addSubview:modelChooseButton];
    
    moreAppButton = [UIButton buttonWithType:UIButtonTypeCustom];
    moreAppButton.frame = CGRectMake(0, 139, 169, 49);
    moreAppButton.center = CGPointMake(self.view.center.x, moreAppButton.center.y);
    [moreAppButton addTarget:self action:@selector(moreAppButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [moreAppButton setBackgroundImage:[UIImage imageNamed:@"home_spread"] forState:UIControlStateNormal];
    [buttonView addSubview:moreAppButton];
    
    UIButton *leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftItemButton setFrame:CGRectMake(10, 7, 30, 30)];
    leftItemButton.alpha = 0;
    [leftItemButton setBackgroundImage:[UIImage imageNamed:@"home_slide"] forState:UIControlStateNormal];
    [leftItemButton addTarget:self action:@selector(leftItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:leftItemButton];
    
    [UIView animateWithDuration:0.2
                     animations:^{
                         leftItemButton.alpha = 1;
                     }completion:nil];
    
    [UIView animateWithDuration:0.5 delay:0.5 options:UIViewAnimationOptionCurveEaseOut animations:^{buttonView.frame = CGRectMake(0, buttonView.frame.origin.y-buttonView.frame.size.height, buttonView.frame.size.width, buttonView.frame.size.height);} completion:nil];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MoreAPP"] isEqualToString:@"1"])
    {
        [self haveNewApp];
    }
    
    // Do any additional setup after loading the view.
}

- (void)haveNewApp
{
    [moreAppButton setBackgroundImage:[UIImage imageNamed:@"home_spread_update.png"] forState:UIControlStateNormal];
}

- (void)noNewApp
{
    [moreAppButton setBackgroundImage:[UIImage imageNamed:@"home_spread.png"] forState:UIControlStateNormal];
}

#pragma mark - 导航按扭方法
- (void)leftItemButtonPressed:(id)sender
{
    [self event:@"home" label:@"home_menu"];
    [[SliderViewController sharedSliderController]showLeftViewController];
}

- (void)modelChooseButtonPressed:(UIButton *)sender
{
    SCModelViewController *modelVC = [[SCModelViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:modelVC];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav.navigationBar setBarTintColor:colorWithHexString(@"#2d2d2d")];
    nav.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: colorWithHexString(@"#28d8c9"),NSFontAttributeName:[UIFont fontWithName:FONTNAMESTRING size:17]};
    nav.navigationBar.translucent = NO;
    [[SliderViewController sharedSliderController] presentViewController:nav animated:YES completion:nil];
}

- (void)moreAppButtonPressed:(UIButton *)sender
{
    [self event:@"home" label:@"home_more"];
    ME_MoreAppViewController *moreApp = [[ME_MoreAppViewController alloc]init];
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:moreApp];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title-bar.png"] forBarMetrics:UIBarMetricsDefault];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nav.navigationBar.backgroundColor = [UIColor clearColor];
    [[SliderViewController sharedSliderController] presentViewController:nav animated:YES completion:nil];
}

#pragma mark 事件统计
- (void)event:(NSString *)eventID label:(NSString *)label;
{
    //友盟
    [MobClick event:eventID label:label];
//    
//    //Flurry
//    [Flurry logEvent:eventID];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
