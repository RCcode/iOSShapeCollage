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

#define kCustomMaxShowTimesKey @"customMaxShowTimes"
#define kAdmobMaxShowTimesKey @"admobMaxShowTimes"
#define kCustomCanShowTimesKey @"customCanShowTimes"
#define kAdmobCanShowTimesKey @"admobCanShowTimes"

#define kRequestDateKey @"requestAdMobDate"
#define kcutomAdRect [UIScreen mainScreen].bounds

#define kCustomAdAppInfo @"popAppInfo"
#define kCustomAdAppCount @"popAppCount"
#define kLastPopupAppId @"lastPopUpAppId"

UIView *customADView;
ME_AppInfo *tempAppInfo;
NSInteger popAppInfoCount;

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
    }
    return self;
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
            _CustomMaxShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
            _CustomCanshowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
            _AdmobMaxshowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey])).integerValue;
            _AdmobCanShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
            
            
            if (lastDate != nil)
            {
                [[NSUserDefaults standardUserDefaults] setObject:time forKey:kRequestDateKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomCanshowTimes] forKey:kCustomCanShowTimesKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobCanShowTimes] forKey:kAdmobCanShowTimesKey];
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
        [self.manager POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject)
        {
            //解析数据
            NSDictionary *dic = (NSDictionary *)responseObject;
            if (![[dic objectForKey:@"advertising"] isKindOfClass:[NSNull class]])
            {
                NSString *str = [NSString stringWithFormat:@"%@",[dic objectForKey:@"advertising"]];
                _CustomMaxShowTimes = [[[str componentsSeparatedByString:@","] objectAtIndex:0] integerValue];
                _AdmobMaxshowTimes = [[[str componentsSeparatedByString:@","]objectAtIndex:1] integerValue];
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomMaxShowTimes] forKey:kCustomMaxShowTimesKey];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobMaxshowTimes] forKey:kAdmobMaxShowTimesKey];
            _CustomCanshowTimes = _CustomMaxShowTimes;
            _AdmobCanShowTimes = _AdmobMaxshowTimes;
            [[NSUserDefaults standardUserDefaults] setObject:time forKey:kRequestDateKey];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomCanshowTimes] forKey:kCustomCanShowTimesKey];
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobCanShowTimes] forKey:kAdmobCanShowTimesKey];
//            NSLog(@"can = %ld",(long)_canShowTimes);
//            NSLog(@"max = %ld",(long)_maxShowTimes);
            [self.delegate didReceivedAdData:dic withTag:tag];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//            NSLog(@"can = %ld",(long)_canShowTimes);
//            NSLog(@"max = %ld",(long)_maxShowTimes);
            _CustomMaxShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
            _CustomCanshowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
            _AdmobMaxshowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kAdmobMaxShowTimesKey])).integerValue;
            _AdmobCanShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomMaxShowTimesKey])).integerValue;
            
            if (lastDate != nil)
            {
                [[NSUserDefaults standardUserDefaults] setObject:time forKey:kRequestDateKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_CustomCanshowTimes] forKey:kCustomCanShowTimesKey];
                [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_AdmobCanShowTimes] forKey:kAdmobCanShowTimesKey];
            }
            
            NSLog(@"error.......%@",error);
            [self.delegate adManagerRequestFaild:tag];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
    }
    
}

+ (BOOL)canShowCustomAds
{
    popAppInfoCount = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCustomAdAppCount])).integerValue;
    NSInteger lastPopUpId = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kLastPopupAppId])).integerValue;
    
    if (!popAppInfoCount)
    {
        popAppInfoCount = 0;
    }
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    if ([app.window.subviews.lastObject isMemberOfClass:[customADView class]])
    {
        return NO;
    }
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
    if (times.intValue > 0)
    {
        NSMutableArray *canPopUpArray = [[NSMutableArray alloc]init];
        SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
        for (ME_AppInfo *appInfo in app.moreAPPSArray)
        {
            NSString *string = appInfo.openUrl;
            NSURL *url = nil;
            
            if (![string isKindOfClass:[NSNull class]] && string != nil ) {
                url = [NSURL URLWithString:string];
            }else{
                url = nil;
            }
            if (appInfo.state == 1001 && ![[UIApplication sharedApplication] canOpenURL:url])
            {
                [canPopUpArray addObject:appInfo];
            }
        }
        if (canPopUpArray.count == 0)
        {
            return NO;
        }
        if (canPopUpArray.count > 0)
        {
            tempAppInfo = (ME_AppInfo *)[canPopUpArray objectAtIndex:popAppInfoCount%canPopUpArray.count];
            if (tempAppInfo.appId == lastPopUpId)
            {
                popAppInfoCount = popAppInfoCount+1;
                tempAppInfo = (ME_AppInfo *)[canPopUpArray objectAtIndex:popAppInfoCount%canPopUpArray.count];
            }
      
            customADView = [[UIView alloc]init];
            customADView.frame = CGRectMake(kcutomAdRect.origin.x, kcutomAdRect.size.height, kcutomAdRect.size.width, kcutomAdRect.size.height);
            customADView.backgroundColor = [UIColor clearColor];
            
            UIView *backView = [[UIView alloc]initWithFrame:kcutomAdRect];
            backView.backgroundColor = [UIColor blackColor];
            backView.alpha = 0.7;
            [customADView addSubview:backView];
            
            RC_ShareTableViewCell *cell = [[RC_ShareTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil withCellHeight:iPhone5?368+10:280+10];
            cell.backgroundColor = [UIColor clearColor];
            cell.center = backView.center;
            [cell.app_logo_imageView sd_setImageWithURL:[NSURL URLWithString:tempAppInfo.iconUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
            cell.app_title_label.text = tempAppInfo.appName;
            cell.app_detail_label.text = tempAppInfo.appDesc;
            [cell.app_bander_imageView sd_setImageWithURL:[NSURL URLWithString:tempAppInfo.bannerUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
            [customADView addSubview:cell];
            
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cellSelected:)];
            tap.numberOfTapsRequired = 1;
            tap.numberOfTouchesRequired = 1;
            [cell addGestureRecognizer:tap];
            
            UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [backButton setBackgroundImage:[UIImage imageNamed:@"gallery_cancel"] forState:UIControlStateNormal];
            backButton.frame = CGRectMake(cell.frame.origin.x+cell.frame.size.width-30, cell.frame.origin.y, 30, 30);
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
    [self event:@"popup" label:[NSString stringWithFormat:@"showCustom_%d",tempAppInfo.appId]];
    
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:popAppInfoCount+1] forKey:kCustomAdAppCount];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times.integerValue - 1] forKey:kCustomCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:@(tempAppInfo.appId) forKey:kLastPopupAppId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"canShowTimes = %ld",(long)((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kCustomCanShowTimesKey]).integerValue);

}

+ (void)showAdmobSeccess
{

    [self event:@"popup" label:@"showAdmobCount"];
    
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times.integerValue - 1] forKey:kAdmobCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    NSLog(@"canShowTimes = %ld",(long)((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kAdmobCanShowTimesKey]).integerValue);
}

+ (void)backButtonPressed:(id)sender
{
    [UIView animateWithDuration:0.5 animations:^{
        customADView.frame = CGRectMake(kcutomAdRect.origin.x, kcutomAdRect.size.height, kcutomAdRect.size.width, kcutomAdRect.size.height);
    } completion:^(BOOL finished){
        if (finished)
        {
            [customADView removeFromSuperview];;
        }
    }];
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

+ (void)cellSelected:(UITapGestureRecognizer *)tap
{
    [self event:@"popup" label:[NSString stringWithFormat:@"openApp_%d",tempAppInfo.appId]];
    NSString *downURL = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",tempAppInfo.downUrl];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:downURL]];
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
