//
//  SCAppDelegate.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFHTTPRequestOperationManager.h"

@interface SCAppDelegate : UIResponder <UIApplicationDelegate,UIPageViewControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (nonatomic, copy) NSString *UpdateUrlStr;
@property (nonatomic, strong) NSString *trackURL;//apple的iTunes地址

@property (nonatomic ,assign) BOOL isOn;//水印开关
@property (nonatomic ,strong) UIImage *bigImage;//水印图


@end
