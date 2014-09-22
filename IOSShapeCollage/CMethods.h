//
//  CMethods.h
//  TaxiTest
//
//  Created by Xiaohui Guo  on 13-3-13.
//  Copyright (c) 2013年 FJKJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <stdio.h>
#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"


@interface CMethods : NSObject
{
    
}

//window 高度
CGFloat windowHeight();

//statusBar隐藏与否的高
CGFloat heightWithStatusBar();

//view 高度
CGFloat viewHeight(UIViewController *viewController);

//wsq-获取图片
NSArray* getImagesArray(NSString *folderName, NSString *type);
UIImage* getImageFromDirectory(NSString *imageName, NSString *folderName);

//图片路径
UIImage* pngImagePath(NSString *name);
UIImage* jpgImagePath(NSString *name);

//数字转化为字符串
NSString* stringForInteger(int value);

//设置默认语言
NSString *LocalizedString(NSString *translation_key, id none);

//系统语言环境
NSString* currentLanguage();

//BOOL IPhone5();

BOOL IOS7_Or_Higher();

//void cancleAllRequests();

void enumerateFonts();

//返回随机不重复树
NSMutableArray* randrom(int count,int totalCount);

//十六进制颜色值
UIColor* colorWithHexString(NSString *stringToConvert);

//把字典转化为json串
NSData* toJSONData(id theData);

MBProgressHUD * showMBProgressHUD(NSString *content,BOOL showView);
void hideMBProgressHUD();

//转换时间戳
NSString *exchangeTime(NSString *time);
//设略版本号
NSString *appVersion();

//根据内容和字体获得标签大小
CGRect getTextLabelRectWithContentAndFont(NSString *content,UIFont *font);

CGSize sizeWithContentAndFont(NSString *content,CGSize size,float fontSize);

NSString *doDevicePlatform();

@end
