//
//  PRJ_SQLiteMassager.h
//  IOSNoCrop
//
//  Created by gaoluyangrc on 14-4-24.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class PRJ_PhotoMarkObject;
@class PRJ_TypeFaceObject;

#define kPhotoMarkFileName  @"NearlyPhotoMarks.sql"
#define kTypeFaceFileName @"TypeFace.sql"
#define kColorMatrixFileName @"ColorMatrix.sql"
#define kAppsInfoFileName @"AppsInfo.sql"

enum SqliteType
{
    PhotoMarkType = 1,
    TypeFaceType = 2,
    ColorMatrixType,
    moreApp,
};

@interface PRJ_SQLiteMassager : NSObject
{
    sqlite3 *_database;
    BOOL _isMoreApp;
}

@property (nonatomic ,assign) sqlite3 *_database;
@property (nonatomic ,assign) enum SqliteType tableType;

+ (PRJ_SQLiteMassager *)shareStance;

//会话列表
- (NSString *)dataFilePath;
//创建数据库
- (BOOL)createTable:(sqlite3 *)db;
//插入数据
- (BOOL)insertChatList:(NSArray *)photoMarkArray photoMarkType:(NSString *)type;
//- (BOOL)insertTypeFace:(FONT_fontTypeObject *)typeFaceObject;
//获取全部数据
- (NSMutableArray*)getAllData;
- (NSMutableArray *)getAllTypeFaces;
//删除数据：
//- (BOOL)deleteChatList:(FONT_photoMarkObject *)photoMark;
//- (BOOL)deleteTypeFace:(FONT_fontTypeObject *)typeFaceObject;
//查询数据库，searchID为要查询数据的ID，返回数据为查询到的数据
- (NSMutableArray *)searchTestList:(NSString *)type;
//查询最大ID
- (NSInteger)selectMaxId;
- (BOOL)deleteAllDataForMarkType:(NSString *)markType;
//moreApp
- (BOOL)insertAppInfo:(NSMutableArray *)appsInfo;
- (BOOL)updagteAppInfo:(int)appId withIsHaveDownLoad:(int)haveDownload;
- (NSMutableArray *)getAllAppInfoData;
- (BOOL)deleteAllAppInfoData;

- (BOOL)deleteAllTypeFace;

@end
