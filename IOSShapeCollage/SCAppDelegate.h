//
//  SCAppDelegate.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"
#import "GADInterstitialDelegate.h"

@class GADRequest;

@interface SCAppDelegate : UIResponder <UIApplicationDelegate,UIPageViewControllerDelegate,GADInterstitialDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic, copy) NSString *UpdateUrlStr;
@property (nonatomic, strong) NSString *trackURL;//apple的iTunes地址

@property (nonatomic ,assign) BOOL isOn;//水印开关
@property (nonatomic ,strong) UIImage *bigImage;//水印图

@property (nonatomic ,strong) NSMutableArray *appsArray;
@property (nonatomic ,strong) NSMutableArray *moreAPPSArray;
@property (nonatomic, assign) BOOL isbecomeActivity;
@property (nonatomic, strong) GADInterstitial *intersitial;

@end
