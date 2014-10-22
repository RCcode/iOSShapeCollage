//
//  Pic_AdMobShowTimesManager.h
//  FreeCollage
//
//  Created by MAXToooNG on 14-9-23.
//  Copyright (c) 2014年 Chen.Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@protocol AdMobShowManagerDelegate <NSObject>
@optional
- (void)didReceivedAdData:(NSDictionary *)dic withTag:(NSInteger)tag;
- (void)adManagerRequestFaild:(NSInteger)tag;
@end
@interface Pic_AdMobShowTimesManager : NSObject
@property (nonatomic, assign) id<AdMobShowManagerDelegate>delegate;
- (id)init;

- (void)requestAdMobTimesForMoreAppId:(NSInteger)appId andRequestTag:(NSInteger)tag;

+ (BOOL)canShowAds;

+ (void)showSeccess;

@end
