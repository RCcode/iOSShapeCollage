//
//  PRJ_Global.h
//  IOSNoCrop
//
//  Created by rcplatform on 14-4-18.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MHImagePickerMutilSelector.h"

//全局共用 banner高度
int kBannerViewH;

@interface PRJ_Global : NSObject

@property (nonatomic ,strong) UIImage *originalImage; //原始图片
@property (nonatomic ,strong) UIImage *compressionImage; //压缩后的图片
@property (nonatomic ,strong) UIImage *photoMarkImage; //图片标签原图

@property (nonatomic ,strong) NSArray *photoMarksArray;

//用户最终编辑完成的图片（用于分享、本地保存）
@property (nonatomic, strong) UIImage *theBestImage;

//广告条
@property (nonatomic, strong) UIView *bannerView;

@property (nonatomic, assign) BOOL isCreate;

@property (nonatomic, strong) NSMutableArray *appsArray;


@property (nonatomic, copy) NSString *templateName;

@property (nonatomic, assign) BOOL showBackMsg;

//当前模板中小块个数
@property (nonatomic, assign) int boxCount;
//压缩比例 根据小块个数定
@property (nonatomic, assign) float compScale;

@property (nonatomic, strong) MHImagePickerMutilSelector *MHImagePickerdelegate;

@property (nonatomic, strong) NSArray *modelArray;
@property (nonatomic, strong) NSMutableArray *editImageArray;

+ (PRJ_Global *)shareStance;
- (MHImagePickerMutilSelector *)getSCCollectionViewDelegate;
/**
 *  全局公用统计分析方法
 */
+ (void)event:(NSString *)event label:(NSString *)label;

@end
