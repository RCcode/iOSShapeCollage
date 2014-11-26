//
//  SCAppDelegate.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 ___FULLUSERNAME___. All rights reserved.
//

#import "SCAppDelegate.h"
#import "SCHomeViewController.h"
#import "PRJ_DataRequest.h"
#import "PRJ_SQLiteMassager.h"
#import "ME_AppInfo.h"
#import "SliderViewController.h"
#import "SCAboutViewController.h"
#import "UIDevice+DeviceInfo.h"
#import <Accounts/Accounts.h>
#import <MessageUI/MessageUI.h>
#import "Pic_AdMobShowTimesManager.h"
#import "GADInterstitial.h"
#import "GADRequest.h"
#import "SDWebImage/SDWebImagePrefetcher.h"

@implementation SCAppDelegate

@synthesize intersitial;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.isbecomeActivity = YES;
    //初始化全屏广告管理
    [self initAdmobManager];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];

    //初始化网络管理
    [self netWorkingSeting];
    
    
    [PRJ_SQLiteMassager shareStance].tableType = moreApp;
    self.moreAPPSArray = [[PRJ_SQLiteMassager shareStance] getAllAppInfoData];
    if (self.moreAPPSArray)
    {
        self.moreAPPSArray = changeMoreTurnArray(self.moreAPPSArray);
    }
    //加载moreApp数据
    if([Pic_AdMobShowTimesManager canRequstDataWithKey:kRequestMoreAppDateKey] || self.moreAPPSArray.count == 0)
    {
        [self downLoadAppsInfo];
    }
    
    //注册通知
    [self registNotification];
    //配置统计
    [self umengSetting];
    
    //检测更新
    [self checkVersion];
    
    NSArray *modelsArray = [[NSBundle mainBundle]pathsForResourcesOfType:@"jpg" inDirectory:@"Type"];
    modelsArray = [modelsArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2)
                  {
                      NSString *obj1String = [[[[obj1 lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0];
                      NSString *obj2String = [[[[obj2 lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0];
                      NSInteger obj1Num = [[obj1String substringFromIndex:4] integerValue];
                      NSInteger obj2Num = [[obj2String substringFromIndex:4] integerValue];
                      
                      if (obj1Num > obj2Num)
                      {
                          return NSOrderedDescending;
                      }
                      if (obj1Num < obj2Num) {
                          return NSOrderedAscending;
                      }
                      return NSOrderedSame;
                  }];
    
    [PRJ_Global shareStance].modelArray = modelsArray;
    // Override point for customization after application launch.
    
    SCHomeViewController *homeVc = [[SCHomeViewController alloc]init];
    UINavigationController *modelNav = [[UINavigationController alloc]initWithRootViewController:homeVc];
    modelNav.navigationBar.translucent = NO;
    
    [SliderViewController sharedSliderController].LeftVC = [[SCAboutViewController alloc]init];
    [SliderViewController sharedSliderController].MainVC = homeVc;
    [SliderViewController sharedSliderController].RightVC = nil;
    [SliderViewController sharedSliderController].LeftSContentOffset=270;
    //    [SliderViewController sharedSliderController].RightSContentScale=0.68;
    [SliderViewController sharedSliderController].LeftSJudgeOffset=270;
    
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:[SliderViewController sharedSliderController]];
    [nav setNavigationBarHidden:YES animated:NO];
    [nav.navigationBar setBackgroundImage:[UIImage imageNamed:@"title-bar.png"] forBarMetrics:UIBarMetricsDefault];
    nav.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    nav.navigationBar.backgroundColor = [UIColor clearColor];
    self.window.rootViewController = nav;
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];

    
    //4次启动弹窗评价
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    int lanchCount = [[userDefault objectForKey:LANCHCOUNT] intValue];
    if (lanchCount != -1)
    {
        lanchCount++;
        if((lanchCount >= 4) && lanchCount % 2 == 0)
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:LocalizedString(@"comment_message_default", nil)
                                                           delegate:self
                                                  cancelButtonTitle:LocalizedString(@"rc_feedback", @"")
                                                  otherButtonTitles:LocalizedString(@"rate_now", nil), LocalizedString(@"attention_later", nil), nil];
            alert.tag = 11;
            [alert show];
        }
        
        [userDefault setObject:@(lanchCount) forKey:LANCHCOUNT];
        [userDefault synchronize];
    }
    
    //判断首次安装第一次启动
    if ([userDefault objectForKey:isFirstLaunch] == nil)
    {
        [userDefault setObject:[NSNumber numberWithBool:YES] forKey:isFirstLaunch];
        [userDefault synchronize];
    }
    else
    {
        [userDefault setObject:[NSNumber numberWithBool:NO] forKey:isFirstLaunch];
        [userDefault synchronize];
    }
    
    return YES;
}

#pragma mark -
#pragma mark 配置AFN
- (void)netWorkingSeting
{
    self.manager = [AFHTTPRequestOperationManager manager];
    self.manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
}

#pragma mark -
#pragma mark 配置广告条
- (void)adMobSetting
{
    intersitial = [[GADInterstitial alloc] init];
    intersitial.delegate = self;
    //    NSLog(@"%@",AdmobFullScreenKey);
    intersitial.adUnitID = AdmobFullScreenKey;
    [intersitial loadRequest:[GADRequest request]];
}

- (void)initAdmobManager
{
    [self adMobSetting];
    Pic_AdMobShowTimesManager *manager = [[Pic_AdMobShowTimesManager alloc]init];
    [manager requestAdMobTimesForMoreAppId:moreAppID andRequestTag:15];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)ad
{
    NSLog(@"ads is ready");
}
- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    [self adMobSetting];
}
- (void)interstitial:(GADInterstitial *)ad didFailToReceiveAdWithError:(GADRequestError *)error
{
    NSLog(@"ads is not ready");
}

- (void)downLoadAppsInfo
{
    //Bundle Id
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
    NSString *language = [[NSLocale preferredLanguages] firstObject];
    if ([language isEqualToString:@"zh-Hans"])
    {
        language = @"zh";
    }
    else if ([language isEqualToString:@"zh-Hant"])
    {
        language = @"zh_TW";
    }
    
    NSDictionary *dic = @{@"appId":[NSNumber numberWithInt:moreAppID],@"packageName":bundleIdentifier,@"language":language,@"version":currentVersion,@"platform":[NSNumber numberWithInt:0]};
    PRJ_DataRequest *request = [[PRJ_DataRequest alloc] initWithDelegate:self];
    [request moreApp:dic withTag:11];
}

#pragma mark -
#pragma mark umeng
- (void)umengSetting
{
    [MobClick startWithAppkey:umengAPPKey reportPolicy:SEND_ON_EXIT channelId:@"App Store"];
    [MobClick updateOnlineConfig];
    
//    [Flurry startSession:flurryAPPKey];
//    [Flurry setSessionReportsOnCloseEnabled:YES];
}

//#pragma mark flurry 推荐设置添加一个未捕获的异常监听器
//void uncaughtExceptionHandler(NSException *exception)
//{
//    [Flurry logError:@"Uncaught" message:@"Crash!" exception:exception];
//}

#pragma mark 注册通知

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSRange range = NSMakeRange(1,[[deviceToken description] length]-2);
    NSString *deviceTokenStr = [[deviceToken description] substringWithRange:range];
    NSLog(@"deviceTokenStr==%@",deviceTokenStr);
    
    NSString *token = [[NSUserDefaults standardUserDefaults] objectForKey:DEVICE_TOKEN];
    if (token == nil || [token isKindOfClass:[NSNull class]] || ![token isEqualToString:deviceTokenStr]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:deviceTokenStr forKey:DEVICE_TOKEN];
        //注册token
        [self postData:[NSString stringWithFormat:@"%@",deviceTokenStr]];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Fail to Register For Remote Notificaions With Error :error = %@",error.description);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    
    NSLog(@"userInfo = %@",userInfo);
    [self doNotificationActionWithInfo:userInfo];
    
}

- (void)doNotificationActionWithInfo:(NSDictionary *)dic
{
    NSDictionary *dictionary = [dic objectForKey:@"aps"];
    NSString *alert = [dictionary objectForKey:@"alert"];
    NSString *type = [dic objectForKey:@"type"];
    NSString *urlStr = [dic objectForKey:@"url"];
    switch (type.intValue) {
        case 0:
        {
            // Ads
            self.UpdateUrlStr = urlStr;
            
            UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:@""
                                                               message:alert
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"cacel", @"")
                                                     otherButtonTitles:LocalizedString(@"conform", @""), nil];
            alertView.tag = 12;
            [alertView show];
            
        }
            break;
        case 1:
        {
            //Update
            self.UpdateUrlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
            //            self.UpdateUrlStr = urlStr;
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                           message:LocalizedString(@"newVersion", @"")
                                                          delegate:self
                                                 cancelButtonTitle:LocalizedString(@"remindLater", @"")
                                                 otherButtonTitles:LocalizedString(@"updateNow", @""), nil];
            alert.tag = 13;
            [alert show];
        }
            break;
        case 2:
            //Font
            //            [self OpenUrl:[NSURL URLWithString:urlStr]];
            break;
        case 3:
            //Tags
            //            [self OpenUrl:[NSURL URLWithString:urlStr]];
            break;
        case 4:
            //Filter
            //            [self OpenUrl:[NSURL URLWithString:urlStr]];
            break;
        default:
            break;
    }
    
    [self cancelNotification];
    
}


- (void)registNotification
{
    if (iOS8)
    {
        [[UIApplication sharedApplication] registerForRemoteNotifications];
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert) categories:nil]];
    }
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert)];
}

- (void)cancelNotification{
    [[UIApplication sharedApplication] cancelAllLocalNotifications];
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
}

- (void)OpenUrl:(NSString *)urlString{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:urlString]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
    }
}

#pragma mark -
#pragma mark 提交设备信息
- (void)postData:(NSString *)token{
    NSDictionary *infoDic = [self deviceInfomation:token];
    
    PRJ_DataRequest *request = [[PRJ_DataRequest alloc] initWithDelegate:self];
    [request registerToken:infoDic withTag:100];
    
}

#pragma mark -
#pragma mark 获取设备信息
- (NSDictionary *)deviceInfomation:(NSString *)token
{
    //Bundle Id
    NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    //NSString *macAddress = [UIDevice getMacAddressWithUIDevice];
    NSString *systemVersion = [UIDevice currentVersion];
    NSString *model = [UIDevice currentModel];
    NSString *modelVersion = [UIDevice currentModelVersion];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"Z"];
    NSTimeZone *timeZone = [NSTimeZone systemTimeZone];
    [dateFormatter setTimeZone:timeZone];
    NSDate *date = [NSDate date];
    //+0800
    NSString *timeZoneZ = [dateFormatter stringFromDate:date];
    NSRange range = NSMakeRange(0, 3);
    //+08
    NSString *timeZoneInt = [timeZoneZ substringWithRange:range];
    
    //en
    NSArray *languageArray = [NSLocale preferredLanguages];
    NSString *language = [languageArray objectAtIndex:0];
    
    //US
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [[[locale localeIdentifier] componentsSeparatedByString:@"_"] lastObject];
    
    /**
     token           Push用token             String		N
     timeZone	 时区（-12--12）        int            N
     language     语言码                        String		N
     bundleid      bundleid                    String		N
     mac             使用唯一标识符 idfv   String		Y
     pagename	 应用包名                    String		N
     model          手机型号                    String		Y
     model_ver	 手机版本                    String		Y
     sysver          系统版本                    String		Y
     country        国家                           String		Y
     **/
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setValue:token forKeyPath:@"token"];
    [params setValue:timeZoneInt forKeyPath:@"timeZone"];
    [params setValue:language forKey:@"language"];
    [params setValue:bundleIdentifier forKeyPath:@"bundleid"];
    [params setValue:idfv forKeyPath:@"mac"];
    [params setValue:bundleIdentifier forKeyPath:@"pagename"];
    [params setValue:model forKeyPath:@"model"];
    [params setValue:modelVersion forKeyPath:@"model_ver"];
    [params setValue:systemVersion forKeyPath:@"sysver"];
    [params setValue:country forKeyPath:@"country"];
    
    return params;
}

#pragma mark -
#pragma mark 版本检测
- (void)checkVersion
{
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
    PRJ_DataRequest *request = [[PRJ_DataRequest alloc] initWithDelegate:self];
    [request updateVersion:urlStr withTag:10];
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)didReceivedData:(NSDictionary *)dic withTag:(NSInteger)tag
{
    switch (tag) {
        case 10:
        {
            //解析数据
            NSArray *results = [dic objectForKey:@"results"];
            if ([results count] == 0) {
                return ;
            }
            
            NSDictionary *dictionary = [results objectAtIndex:0];
            NSString *version = [dictionary objectForKey:@"version"];
            NSString *trackViewUrl = [dictionary objectForKey:@"trackViewUrl"];//地址trackViewUrl
            //            self.trackURL = trackViewUrl;
            //NSString *trackName = [dictionary objectForKey:@"trackName"];//trackName
            
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
            
            if ([currentVersion compare:version options:NSNumericSearch] == NSOrderedAscending)
            {
                //                self.UpdateUrlStr = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appleID];
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@""
                                                               message:LocalizedString(@"newVersion", @"")
                                                              delegate:self
                                                     cancelButtonTitle:LocalizedString(@"remindLater", @"")
                                                     otherButtonTitles:LocalizedString(@"updateNow", @""), nil];
                alert.tag = 14;
                [alert show];
            }
        }
            break;
        case 11:
        {
            NSLog(@"dic.......%@",dic);
            NSArray *infoArray = [dic objectForKey:@"list"];
            NSMutableArray *sqlArray = [[NSMutableArray alloc]init];
            for (NSMutableDictionary *infoDic in infoArray)
            {
                ME_AppInfo *appInfo = [[ME_AppInfo alloc]initWithDictionary:infoDic];
                [sqlArray addObject:appInfo];
            }
            //判断是否有新应用
            [PRJ_SQLiteMassager shareStance].tableType = moreApp;
            NSMutableArray *dataArray = [[PRJ_SQLiteMassager shareStance] getAllAppInfoData];
            
            for (ME_AppInfo *app in sqlArray)
            {
                BOOL isHave = NO;
                for (ME_AppInfo *appInfo in dataArray)
                {
                    if (app.appId == appInfo.appId)
                    {
                        isHave = YES;
                    }
                }
                if (!isHave)
                {
                    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MoreAPP"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"addMoreImage" object:nil];
                    break;
                }
            }
            [PRJ_SQLiteMassager shareStance].tableType = moreApp;
            [[PRJ_SQLiteMassager shareStance] deleteAllAppInfoData];
            [[PRJ_SQLiteMassager shareStance] insertAppInfo:sqlArray];
            
            self.moreAPPSArray = changeMoreTurnArray(sqlArray);
            [PRJ_Global shareStance].appsArray = changeMoreTurnArray(sqlArray);
            [Pic_AdMobShowTimesManager PrefetcherURLs:self.moreAPPSArray];
            [Pic_AdMobShowTimesManager updateStateWithKey:kRequestMoreAppDateKey];
        }
            break;
        case 12:
        {
//            NSArray *dataArray = [dic objectForKey:@"list"];
//            self.photoMarksArray = dataArray;
            
        }
            break;
        default:
            break;
    }
//    hideMBProgressHUD();
}
- (void)requestFailed:(NSInteger)tag
{
    
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (alertView.tag == 11)
    {
        if(buttonIndex == 2){//稍后
            return;
        }
        
        if(buttonIndex == 1)
        {//马上评
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[NSString stringWithFormat:@"%d",-1] forKey:LANCHCOUNT];
            [userDefault synchronize];
        }
        if (buttonIndex == 0)
        {
            //返馈
            // app名称 版本
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            
            //设备型号 系统版本
            NSString *deviceName = doDevicePlatform();
            NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
            NSString *deviceSystemVer = [[UIDevice currentDevice] systemVersion];
            
            //设备分辨率
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat resolutionW = [UIScreen mainScreen].bounds.size.width * scale;
            CGFloat resolutionH = [UIScreen mainScreen].bounds.size.height * scale;
            NSString *resolution = [NSString stringWithFormat:@"%.f * %.f", resolutionW, resolutionH];
            
            //本地语言
            NSString *language = [[NSLocale preferredLanguages] firstObject];
            
            //            NSString *diveceInfo = @"app版本号 手机型号 手机系统版本 分辨率 语言";
            NSString *diveceInfo = [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@, %@", app_Name, app_Version, deviceName, deviceSystemName, deviceSystemVer,  resolution, language];
            
            //直接发邮件
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            if(!picker) return;
            picker.mailComposeDelegate =self;
            NSString *subject = [NSString stringWithFormat:@"%@ %@ (iOS)",LocalizedString(@"app_name", nil), LocalizedString(@"feedback", nil)];
            [picker setSubject:subject];
            [picker setToRecipients:@[kFeedbackEmail]];
            [picker setMessageBody:diveceInfo isHTML:NO];
            [self.window.rootViewController presentViewController:picker animated:YES completion:nil];
            
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[NSString stringWithFormat:@"%d",-1] forKey:LANCHCOUNT];
            [userDefault synchronize];

        }
    }
    else if (alertView.tag == 12)
    {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:self.UpdateUrlStr]];
        }
    }
    else if (alertView.tag == 13 || alertView.tag == 14)
    {
        if (buttonIndex == 1) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
        }
    }
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [Pic_AdMobShowTimesManager PrefetcherURLs:changeMoreTurnArray(self.moreAPPSArray)];
    
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
    [[SDWebImagePrefetcher sharedImagePrefetcher] cancelPrefetching];
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:isFirstLaunch];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self.moreAPPSArray removeAllObjects];
    [PRJ_SQLiteMassager shareStance].tableType = moreApp;
    //    self.appsArray = [[FONT_SQLiteMassager shareStance] getAllAppInfoData];
    self.moreAPPSArray = [[NSMutableArray alloc]initWithArray:[[PRJ_SQLiteMassager shareStance] getAllAppInfoData]];
    if (self.moreAPPSArray)
    {
        self.moreAPPSArray = changeMoreTurnArray(self.moreAPPSArray);
    }
    
    self.isbecomeActivity = YES;
    UINavigationController *rootNav = (UINavigationController *)self.window.rootViewController;
    UIViewController *presentVC = [self.window.rootViewController presentedViewController];
    if (self.isbecomeActivity && [rootNav.topViewController isKindOfClass:[SliderViewController class]] && presentVC == nil)
    {
        
        if ([Pic_AdMobShowTimesManager canShowCustomAds])
        {
            [Pic_AdMobShowTimesManager presentViewCompletion:^
             {
                 [Pic_AdMobShowTimesManager showCustomSeccess];
                 self.isbecomeActivity = NO;
             }];
        }
    }
    
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[NSUserDefaults standardUserDefaults]setObject:[NSNumber numberWithBool:NO] forKey:isFirstLaunch];
    [[NSUserDefaults standardUserDefaults] synchronize];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
