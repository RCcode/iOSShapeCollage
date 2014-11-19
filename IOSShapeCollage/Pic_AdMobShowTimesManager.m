//
//  Pic_AdMobShowTimesManager.m
//  FreeCollage
//
//  Created by MAXToooNG on 14-9-23.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "Pic_AdMobShowTimesManager.h"
#import "Reachability.h"
#import "ME_AppInfo.h"
#import "SCAppDelegate.h"
#import "UIImageView+WebCache.h"
#import "PopUpADView.h"
#import "SDWebImageManager.h"
#import "SDWebImage/SDWebImagePrefetcher.h"


#define kCustomMaxShowTimesKey @"customMaxShowTimes"
#define kAdmobMaxShowTimesKey @"admobMaxShowTimes"
#define kCustomCanShowTimesKey @"customCanShowTimes"
#define kAdmobCanShowTimesKey @"admobCanShowTimes"

#define kRequestDateKey @"requestAdMobDate"
#define krefreshTimeKey @"refreshtimekey"

#define kcutomAdRect [UIScreen mainScreen].bounds

#define kCustomAdAppInfo @"popAppInfo"
#define kCustomAdAppCount @"popAppCount"

UIView *customADView;
ME_AppInfo *tempAppInfo;
NSString *popAppInfoID;
PopUpADView *popCell;

static Pic_AdMobShowTimesManager *picObject = nil;

@interface Pic_AdMobShowTimesManager ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, assign) NSInteger CustomMaxShowTimes;
@property (nonatomic, assign) NSInteger AdmobMaxshowTimes;
@property (nonatomic, assign) NSInteger CustomCanshowTimes;
@property (nonatomic, assign) NSInteger AdmobCanShowTimes;
@end

@implementation Pic_AdMobShowTimesManager

- (id)init
{
    if (self = [super init]) {
        self.manager = [AFHTTPRequestOperationManager manager];
        //        self.manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
        self.manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        self.manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        popCell = [[[NSBundle mainBundle] loadNibNamed:@"PopUpADView" owner:self options:nil] objectAtIndex:0];
        [Pic_AdMobShowTimesManager addobserve];
        
        picObject = self;
    }
    return self;
}

+ (void)addobserve
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cellSelected:) name:@"call" object:nil];
}

- (void)refreshCount
{
    _CustomMaxShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
    _CustomCanshowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
    _AdmobMaxshowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey])).integerValue;
    _AdmobCanShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey])).integerValue;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomCanshowTimes] forKey:kCustomCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobCanShowTimes] forKey:kAdmobCanShowTimesKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (void)requestAdMobTimesForMoreAppId:(NSInteger)appId andRequestTag:(NSInteger) tag
{
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kRequestDateKey];
    NSDate *time = [NSDate date];
    
    NSTimeInterval timeInterval = [time timeIntervalSinceDate:lastDate];
    
    NSLog(@"timeInterval = %f",timeInterval);
    if (lastDate == nil || timeInterval > 24*60*60)
    {
        NSLog(@"begin request admob setting.......");
        NSString *moreAppId = [NSString stringWithFormat:@"%ld",(long)appId];
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:moreAppId,@"app_id",nil];
        if (![self checkNetWorking])
        {
            if (lastDate != nil)
            {
                NSNumber *oldCanShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
                NSNumber *oldMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey];
                
                NSInteger newCanShow = _CustomMaxShowTimes-(oldMaxShow.integerValue-oldCanShow.integerValue);
                
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newCanShow] forKey:kCustomCanShowTimesKey];
            }
            
            return;
        }
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [requestSerializer setTimeoutInterval:30];
        self.manager.requestSerializer = requestSerializer;
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript" , @"text/plain" ,@"text/html", nil];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        self.manager.responseSerializer = responseSerializer;
        //        NSString *url = @"http://192.168.0.86:8076/AdlayoutBossWeb/platform/getRcAdvConrol.do";
        NSString *url = @"http://ads.rcplatformhk.com/AdlayoutBossWeb/platform/getRcAdvConrol.do";
        
        //        NSString *url = @"http://115.28.90.23:8066/lottery/registermain";
        
        //        NSDictionary *postDic = @{@"username":@"18618415293",@"password":@"123456",@"shopId":@"871"};
        [self.manager POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject)
         {
             //解析数据
             NSDictionary *dic = (NSDictionary *)responseObject;
             NSLog(@"%@",dic);
             if (![[dic objectForKey:@"advertising"] isKindOfClass:[NSNull class]])
             {
                 NSString *str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"advertising"]];
                 _CustomMaxShowTimes = [[[str componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
                 _AdmobMaxshowTimes = [[[str componentsSeparatedByString:@","]objectAtIndex:1] integerValue];
             }
             if (lastDate != nil)
             {
                 NSNumber *oldCustomCanShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
                 NSNumber *oldCustomMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey];
                 
                 NSNumber *oldAdmobCanShow = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey];
                 NSNumber *oldAdmobMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey];
                 
                 NSInteger newCustomCanShow = _CustomMaxShowTimes-(oldCustomMaxShow.integerValue-oldCustomCanShow.integerValue);
                 NSInteger newAdmobCanShow = _AdmobMaxshowTimes-(oldAdmobMaxShow.integerValue-oldAdmobCanShow.integerValue);
                 
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newCustomCanShow] forKey:kCustomCanShowTimesKey];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newAdmobCanShow] forKey:kAdmobCanShowTimesKey];
             }
             
             
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomMaxShowTimes] forKey:kCustomMaxShowTimesKey];
             [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobMaxshowTimes] forKey:kAdmobMaxShowTimesKey];
             [[NSUserDefaults standardUserDefaults] setObject:time forKey:kRequestDateKey];
             [[NSUserDefaults standardUserDefaults] setObject:time forKey:krefreshTimeKey];
             if (lastDate == nil)
             {
                 _CustomCanshowTimes = _CustomMaxShowTimes;
                 _AdmobCanShowTimes = _AdmobMaxshowTimes;
                 
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomCanshowTimes] forKey:kCustomCanShowTimesKey];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobCanShowTimes] forKey:kAdmobCanShowTimesKey];
             }
             [self.delegate didReceivedAdData:dic withTag:tag];
             [[NSUserDefaults standardUserDefaults] synchronize];
             
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             
             if (lastDate != nil)
             {
                 NSNumber *oldCustomCanShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
                 NSNumber *oldCustomMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey];
                 NSNumber *newCustomMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey];
                 
                 NSNumber *oldAdmobCanShow = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey];
                 NSNumber *oldAdmobMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey];
                 NSNumber *newAdmobMaxShow = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey];
                 
                 NSInteger newCustomCanShow = newCustomMaxShow.integerValue-(oldCustomMaxShow.integerValue-oldCustomCanShow.integerValue);
                 NSInteger newAdmobCanShow = newAdmobMaxShow.integerValue-(oldAdmobMaxShow.integerValue-oldAdmobCanShow.integerValue);
                 
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newCustomCanShow] forKey:kCustomCanShowTimesKey];
                 [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:newAdmobCanShow] forKey:kAdmobCanShowTimesKey];
             }
             
             NSLog(@"error.......%@",error);
             [self.delegate adManagerRequestFaild:tag];
             [[NSUserDefaults standardUserDefaults] synchronize];
         }];
    }
    
}

+ (BOOL)canShowCustomAds
{
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:krefreshTimeKey];
    NSDate *time = [NSDate date];
    
    NSTimeInterval timeInterval = [time timeIntervalSinceDate:lastDate];
    
    NSLog(@"timeInterval = %f",timeInterval);
    if (lastDate != nil && timeInterval > 24*60*60)
    {
        [picObject refreshCount];
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:krefreshTimeKey];
    }
    
    BOOL isFirst = [[[NSUserDefaults standardUserDefaults] objectForKey:isFirstLaunch] boolValue];
    if (isFirst)
    {
        return NO;
    }
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([app.window.subviews.lastObject isMemberOfClass:[customADView class]])
    {
        return NO;
    }
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
    
    if (times.intValue > 0)
    {
        BOOL canPopUp = NO;
        NSInteger lastPopCount = -1;
        SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
        
        popAppInfoID = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomAdAppCount];
        
        for (int i = 0; i < app.moreAPPSArray.count; i++)
        {
            ME_AppInfo *tempApp = (ME_AppInfo *)[app.moreAPPSArray objectAtIndex:i];
            if ([tempApp.downUrl isEqualToString:popAppInfoID])
            {
                lastPopCount = i;
                break;
            }
            else
            {
                lastPopCount = -1;
            }
        }
        for (int j = 0; j < app.moreAPPSArray.count; j++)
        {
            lastPopCount = lastPopCount+1;
            NSInteger popCount = lastPopCount%app.moreAPPSArray.count;
            ME_AppInfo *appInfo = [app.moreAPPSArray objectAtIndex:popCount];
            
            NSString *string = appInfo.openUrl;
            NSURL *url = nil;
            if (![string isKindOfClass:[NSNull class]] && string != nil ) {
                url = [NSURL URLWithString:string];
            }else{
                url = nil;
            }
            if (appInfo.state == 1001 && ![[UIApplication sharedApplication] canOpenURL:url])
            {
                canPopUp = YES;
                tempAppInfo = appInfo;
                popAppInfoID = tempAppInfo.downUrl;
                break;
            }
        }
        if (canPopUp == NO)
        {
            return NO;
        }
        //
        //
        //        for (int i = 0; i < canPopUpArray.count; i++)
        //        {
        //            lastPopCount = lastPopCount+1;
        //            lastPopCount = lastPopCount%canPopUpArray.count;
        //            ME_AppInfo *appInfo = [canPopUpArray objectAtIndex:lastPopCount];
        //            NSString *string = appInfo.openUrl;
        //            NSURL *url = nil;
        //
        //            if (![string isKindOfClass:[NSNull class]] && string != nil ) {
        //                url = [NSURL URLWithString:string];
        //            }else{
        //                url = nil;
        //            }
        //            if (appInfo.state == 1001 && ![[UIApplication sharedApplication] canOpenURL:url])
        //            {
        //                canPopUp = YES;
        //                tempAppInfo = appInfo;
        //                break;
        //            }
        //        }
        if (canPopUp == YES)
        {
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            BOOL isIconCache = [manager cachedImageExistsForURL:[NSURL URLWithString:tempAppInfo.iconUrl]];
            BOOL isBannerCache = [manager cachedImageExistsForURL:[NSURL URLWithString:tempAppInfo.bannerUrl]];
            if (!(isIconCache && isBannerCache))
            {
                return NO;
            }
            
            customADView = [[UIView alloc]init];
            customADView.frame = CGRectMake(kcutomAdRect.origin.x, kcutomAdRect.size.height, kcutomAdRect.size.width, kcutomAdRect.size.height);
            customADView.backgroundColor = [UIColor clearColor];
            
            UIView *backView = [[UIView alloc]initWithFrame:kcutomAdRect];
            backView.backgroundColor = [UIColor blackColor];
            backView.alpha = 0.7;
            [customADView addSubview:backView];
            
            
            popCell.center = backView.center;
            popCell.appInfo = tempAppInfo;
            popCell.viewName = @"popup";
            [customADView addSubview:popCell];
            
            //            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellSelected:)];
            //            tap.numberOfTapsRequired = 1;
            //            tap.numberOfTouchesRequired = 1;
            //            [popCell addGestureRecognizer:tap];
            
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setBackgroundImage:[UIImage imageNamed:@"gallery_cancel"] forState:UIControlStateNormal];
            backButton.frame = CGRectMake(popCell.frame.origin.x+popCell.frame.size.width-20, popCell.frame.origin.y-10, 30, 30);
            [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [customADView addSubview:backButton];
            
            return YES;
        }
    }
    return NO;
}
+ (BOOL)canShowAdmobAds
{
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey];
    if (times.intValue > 0)
    {
        return YES;
    }
    return NO;
}

+ (void)showCustomSeccess
{
    [self event:@"C_POPUP" label:[NSString stringWithFormat:@"imp_popup_%@",tempAppInfo.appName]];
    
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:popAppInfoID forKey:kCustomAdAppCount];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times.integerValue - 1] forKey:kCustomCanShowTimesKey];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"canShowTimes = %ld",(long)((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey]).integerValue);
    
}

+ (void)showAdmobSeccess
{
    
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times.integerValue - 1] forKey:kAdmobCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"canShowTimes = %ld",(long)((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey]).integerValue);
}

+ (void)backButtonPressed:(id)sender
{
    customADView.frame = CGRectMake(kcutomAdRect.origin.x, kcutomAdRect.size.height, kcutomAdRect.size.width, kcutomAdRect.size.height);
    [customADView removeFromSuperview];
}

+ (void)presentViewCompletion:(void (^)(void))completion
{
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    [app.window addSubview:customADView];
    
    [UIView animateWithDuration:0.5 animations:^{
        customADView.frame = kcutomAdRect;
    } completion:^(BOOL finished){
        if (finished)
        {
            completion();
        }
    }];
}

+ (BOOL)canRequstDataWithKey:(NSString *)key{
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSTimeInterval  timeInterval = [lastDate timeIntervalSinceNow];
    timeInterval = -timeInterval;
    return (lastDate == nil || timeInterval > 24 * 60 * 60);
}

+ (void)updateStateWithKey:(NSString *)key{
    NSDate *time = [NSDate date];
    [[NSUserDefaults standardUserDefaults] setObject:time forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)cellSelected:(id)sender
{
    if ([sender isKindOfClass:[NSNotification class]])
    {
        NSNotification *tempNotification = (NSNotification *)sender;
        PopUpADView *tempPop = (PopUpADView *)[tempNotification object];
        if ([tempPop.viewName isEqualToString:@"popup"])
        {
            [self event:@"C_POPUP" label:[NSString stringWithFormat:@"c_popup_%@",tempPop.appInfo.appName]];
            NSString *downURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",tempPop.appInfo.downUrl];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downURL]];
        }
        else if ([tempPop.viewName isEqualToString:@"share"])
        {
            [self event:@"C_SHARE" label:[NSString stringWithFormat:@"c_share_%@",tempPop.appInfo.appName]];
            NSString *downURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",tempPop.appInfo.downUrl];
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:tempPop.appInfo.openUrl]])
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:tempPop.appInfo.openUrl]];
            }
            else
            {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downURL]];
            }
        }
    }
    
}
+ (void)PrefetcherURLs:(NSArray *)array
{
    NSMutableArray *imageCacheArray = [[NSMutableArray alloc]init];
    for (ME_AppInfo *tempAPP in array)
    {
        NSLog(@"%@",tempAPP.appName);
        
        NSURL *iconUrl = [NSURL URLWithString:tempAPP.iconUrl];
        NSURL *bannerUrl = [NSURL URLWithString:tempAPP.bannerUrl];
        [imageCacheArray addObject:iconUrl];
        [imageCacheArray addObject:bannerUrl];
    }
    
    [[SDWebImagePrefetcher sharedImagePrefetcher] cancelPrefetching];
    [[SDWebImagePrefetcher sharedImagePrefetcher]prefetchURLs:imageCacheArray];
}

+ (void)setTitleColor:(UIColor *)color
{
    [popCell setTitleColor:color];
}
+ (void)setBackGroundColor:(UIColor *)color
{
    [popCell setBackViewColor:color];
}

#pragma mark -
#pragma mark 检测网络状态
- (BOOL)checkNetWorking
{
    
    BOOL connected = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ? YES : NO;
    
    if (!connected) {

    }
    
    return connected;
}

#pragma mark 事件统计
+ (void)event:(NSString *)eventID label:(NSString *)label;
{
    //友盟
    [MobClick event:eventID label:label];
    
    //Flurry
    [Flurry logEvent:eventID];
}

@end
