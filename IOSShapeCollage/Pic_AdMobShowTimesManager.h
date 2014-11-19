//
//  Pic_AdMobShowTimesManager.h
//  FreeCollage
//
//  Created by MAXToooNG on 14-9-23.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "RC_ShareTableViewCell.h"


#define kRequestMoreAppDateKey @"kRequestMoreAppDateKey"


@protocol AdMobShowManagerDelegate <NSObject>
@optional
- (void)didReceivedAdData:(NSDictionary *)dic withTag:(NSInteger)tag;
- (void)adManagerRequestFaild:(NSInteger)tag;
@end
@interface Pic_AdMobShowTimesManager : NSObject
@property (nonatomic, assign) id<AdMobShowManagerDelegate>delegate;

- (id)init;

- (void)requestAdMobTimesForMoreAppId:(NSInteger)appId andRequestTag:(NSInteger)tag;

+ (void)presentViewCompletion:(void (^)(void))completion;

+ (BOOL)canShowCustomAds;
+ (BOOL)canShowAdmobAds;

+ (void)showCustomSeccess;
+ (void)showAdmobSeccess;

+ (void)setTitleColor:(UIColor *)color;
+ (void)setBackGroundColor:(UIColor *)color;

+ (void)PrefetcherURLs:(NSArray *)array;

/** 判断是否可以发请求 */
+ (BOOL)canRequstDataWithKey:(NSString *)key;

/** 对应请求成功后，必须调此方法更新状态 */
+ (void)updateStateWithKey:(NSString *)key;

@end
