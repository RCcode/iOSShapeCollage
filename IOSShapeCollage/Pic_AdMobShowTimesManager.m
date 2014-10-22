//
//  Pic_AdMobShowTimesManager.m
//  FreeCollage
//
//  Created by MAXToooNG on 14-9-23.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import "Pic_AdMobShowTimesManager.h"
#import "Reachability.h"

#define kMaxShowTimesKey @"maxShowTimes"
#define kCanShowTimesKey @"canShowTimes"
#define kRequestDateKey @"requestAdMobDate"

@interface Pic_AdMobShowTimesManager ()
@property (nonatomic, strong) AFHTTPRequestOperationManager *manager;
@property (nonatomic, assign) NSInteger maxShowTimes;
@property (nonatomic, assign) NSInteger canShowTimes;
@end

@implementation Pic_AdMobShowTimesManager
- (id)init
{
    if (self = [super init]) {
        self.manager = [AFHTTPRequestOperationManager manager];
        self.manager.responseSerializer = [[AFHTTPResponseSerializer alloc] init];
    }
    return self;
}

- (void)requestAdMobTimesForMoreAppId:(NSInteger)appId andRequestTag:(NSInteger) tag
{
    NSDate *lastDate = [[NSUserDefaults standardUserDefaults] objectForKey:kRequestDateKey];
    NSTimeInterval  timeInterval = [lastDate timeIntervalSinceNow];
    timeInterval = - timeInterval;
    NSDate *time = [NSDate date];
    
    NSLog(@"timeInterval = %f",timeInterval);
    if (lastDate == nil || timeInterval > 24*60*60 )
    {
        [[NSUserDefaults standardUserDefaults] setObject:time forKey:kRequestDateKey];
        NSLog(@"begin request admob setting.......");
        NSString *moreAppId = [NSString stringWithFormat:@"%ld",(long)appId];
        NSDictionary *dic = [[NSDictionary alloc]initWithObjectsAndKeys:moreAppId,@"app_id",nil];
        if (![self checkNetWorking])
            return;
        
        AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        [requestSerializer setTimeoutInterval:30];
        self.manager.requestSerializer = requestSerializer;
        self.manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript" , @"text/plain" , nil];
        AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
        self.manager.responseSerializer = responseSerializer;
        NSString *url = @"http://ads.rcplatformhk.com/AdlayoutBossWeb/platform/getRcAppAdmob.do";
        [self.manager POST:url parameters:dic success:^(AFHTTPRequestOperation *operation, id responseObject) {
            //解析数据
            NSDictionary *dic = (NSDictionary *)responseObject;
            if (![[dic objectForKey:@"admob_num"] isKindOfClass:[NSNull class]]) {
                _maxShowTimes = ((NSNumber *)[dic objectForKey:@"admob_num"]).integerValue;
            }
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_maxShowTimes] forKey:kMaxShowTimesKey];
            _canShowTimes = _maxShowTimes;
            [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:_canShowTimes] forKey:kCanShowTimesKey];
            
            NSLog(@"can = %ld",(long)_canShowTimes);
            NSLog(@"max = %ld",(long)_maxShowTimes);
            [self.delegate didReceivedAdData:dic withTag:tag];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"can = %ld",(long)_canShowTimes);
            NSLog(@"max = %ld",(long)_maxShowTimes);
            _maxShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kMaxShowTimesKey])).integerValue;
            _canShowTimes = ((NSNumber *)([[NSUserDefaults standardUserDefaults] objectForKey:kCanShowTimesKey])).integerValue;
            NSLog(@"error.......%@",error);
            [self.delegate adManagerRequestFaild:tag];
        }];
    }
}

+ (BOOL)canShowAds
{
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kCanShowTimesKey];
    if (times.integerValue > 0) {
        return  YES;
    }
    return NO;
}

+ (void)showSeccess
{
    NSNumber *times = [[NSUserDefaults standardUserDefaults] objectForKey:kCanShowTimesKey];
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInteger:times.integerValue - 1] forKey:kCanShowTimesKey];
    NSLog(@"canShowTimes = %ld",(long)((NSNumber *)[[NSUserDefaults standardUserDefaults] objectForKey:kCanShowTimesKey]).integerValue);
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

@end
