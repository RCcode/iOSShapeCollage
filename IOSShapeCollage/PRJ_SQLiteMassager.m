//
//  PRJ_SQLiteMassager.m
//  IOSNoCrop
//
//  Created by gaoluyangrc on 14-4-24.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

//#import "PRJ_PhotoMarkObject.h"
//#import "PRJ_TypeFaceObject.h"

#import "PRJ_SQLiteMassager.h"
#import "ME_AppInfo.h"

@implementation PRJ_SQLiteMassager

@synthesize _database;

static PRJ_SQLiteMassager *prj_Sqlite_Massager = nil;

+ (PRJ_SQLiteMassager *)shareStance
{
    if (prj_Sqlite_Massager == nil) {
        prj_Sqlite_Massager = [[PRJ_SQLiteMassager alloc]init];
    }
    return prj_Sqlite_Massager;
}

//数据库沙盒路径
- (NSString *)dataFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
    
    switch (_tableType) {
            
        case TypeFaceType:
            return [documentsDirectory stringByAppendingPathComponent:kTypeFaceFileName];

        case PhotoMarkType:
            return [documentsDirectory stringByAppendingPathComponent:kPhotoMarkFileName];
        
        case ColorMatrixType:
            return [documentsDirectory stringByAppendingPathComponent:kColorMatrixFileName];
            
        case AppInfo:
            return [documentsDirectory stringByAppendingPathComponent:kAppsInfoFileName];
            
        default:
            break;
    }
    return nil;
}

//创建，打开数据库
- (BOOL)openDB {
	
	//获取数据库路径
	NSString *path = [self dataFilePath];
	//文件管理器
	NSFileManager *fileManager = [NSFileManager defaultManager];
	//判断数据库是否存在
	BOOL find = [fileManager fileExistsAtPath:path];
	
	//如果数据库存在，则用sqlite3_open直接打开（不要担心，如果数据库不存在sqlite3_open会自动创建）
	if (find) {
        
		//打开数据库，这里的[path UTF8String]是将NSString转换为C字符串，因为SQLite3是采用可移植的C(而不是
		//Objective-C)编写的，它不知道什么是NSString.
		if(sqlite3_open([path UTF8String], &_database) != SQLITE_OK) {
			
			//如果打开数据库失败则关闭数据库
			sqlite3_close(self._database);
			NSLog(@"Error: open database file.");
			return NO;
		}
		
//		//创建一个新表
//        if(_isMoreApp){
//            [self createAppsInfoTable:self._database];
//        }else{
//            [self createTable:self._database];
//        }
		
		
		return YES;
	}
	//如果发现数据库不存在则利用sqlite3_open创建数据库（上面已经提到过），与上面相同，路径要转换为C字符串
	if(sqlite3_open([path UTF8String], &_database) == SQLITE_OK) {
		
		//创建一个新表
        if(_isMoreApp){
            [self createAppsInfoTable:self._database];
        }else{
            [self createTable:self._database];
        }
		return YES;
    }else {
		//如果创建并打开数据库失败则关闭数据库
		sqlite3_close(self._database);
		NSLog(@"Error: open database file.");
		return NO;
    }
	return NO;
}

//创建数据库
- (BOOL)createTable:(sqlite3 *)db
{
    //这句是大家熟悉的SQL语句
    char *sql;
    switch (_tableType) {
        case TypeFaceType:
            sql = "create table if not exists typeFaceTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, fid int,lang text,md5 text,name text,purl text,size int,url text,var int,fileName text,fontName text)";
            break;
        case PhotoMarkType:
            sql = "create table if not exists photoMarkTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, sid int,url text,md5 text,size int,purl text,ver int,markType text)";
            break;
            
//        case ColorMatrixType:
//            sql = "";
//            break;
            
        default:
            return NO;
    }

	sqlite3_stmt *statement;
	//sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
	NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
	//第一个参数跟前面一样，是个sqlite3 * 类型变量，
	//第二个参数是一个 sql 语句。
	//第三个参数我写的是-1，这个参数含义是前面 sql 语句的长度。如果小于0，sqlite会自动计算它的长度（把sql语句当成以\0结尾的字符串）。
	//第四个参数是sqlite3_stmt 的指针的指针。解析以后的sql语句就放在这个结构里。
	//第五个参数我也不知道是干什么的。为nil就可以了。
	//如果这个函数执行成功（返回值是 SQLITE_OK 且 statement 不为 NULL ），那么下面就可以开始插入二进制数据。
	
	//如果SQL语句解析出错的话程序返回
	if(sqlReturn != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement:create test table");
		return NO;
	}
	
	//执行SQL语句
	int success = sqlite3_step(statement);
	//释放sqlite3_stmt
	sqlite3_finalize(statement);
	
	//执行SQL语句失败
	if ( success != SQLITE_DONE) {
		NSLog(@"Error: failed to dehydrate:create table test");
		return NO;
	}
    
	return YES;
}

- (BOOL)createAppsInfoTable:(sqlite3 *)db
{
//    NSLog(@"createAppsInfoTable");
    
    char *sql = "create table if not exists appsInfoTable(ID INTEGER PRIMARY KEY AUTOINCREMENT, appCate text,appComment int,appId int,appName text,bannerUrl text,downUrl text,iconUrl text,packageName text,price text,openUrl text,isHave int,appDesc text)";
    
	sqlite3_stmt *statement;
	//sqlite3_prepare_v2 接口把一条SQL语句解析到statement结构里去. 使用该接口访问数据库是当前比较好的的一种方法
	NSInteger sqlReturn = sqlite3_prepare_v2(_database, sql, -1, &statement, nil);
    
	if(sqlReturn != SQLITE_OK) {
		NSLog(@"Error: failed to prepare statement:create test table");
		return NO;
	}
	
	//执行SQL语句
	int success = sqlite3_step(statement);
	//释放sqlite3_stmt
	sqlite3_finalize(statement);
	
	//执行SQL语句失败
	if ( success != SQLITE_DONE) {
		NSLog(@"Error: failed to dehydrate:create table test");
		return NO;
	}
    
	return YES;
}

//插入数据
//- (BOOL)insertChatList:(NSArray *)photoMarkArray photoMarkType:(NSString *)type
//{
//    //先判断数据库是否打开
//	if ([self openDB]) {
//        
//        char *zErrorMsg;
//        int ret;
//        ret = sqlite3_exec(_database, "begin transaction" , 0 , 0 , &zErrorMsg);
//        
////        NSLog(@"1111111");
//        
//        for (PRJ_PhotoMarkObject *photoMark in photoMarkArray) {
//            //能够使用sqlite3_step()执行编译好的准备语句的指针
//            
//            sqlite3_stmt *statement;
//            
//            //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
//            char *sql = "INSERT INTO photoMarkTable(sid, url ,md5 ,size , purl, ver, markType) VALUES(?,?,?,?,?,?,?)";
//            
//            //准备语句：第三个参数是从zSql中读取的字节数的最大值
//            int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
//            if (success2 != SQLITE_OK) {
//                NSLog(@"Error: failed to insert:photoMarkTable");
//                sqlite3_close(_database);
//                return NO;
//            }
//            
//            //这里的数字1，2，3代表第几个问号，这里将两个值绑定到两个绑定变量
//            sqlite3_bind_int (statement, 1, (int)photoMark.sid);
//            sqlite3_bind_text(statement, 2, [photoMark.url UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_text(statement, 3, [photoMark.md5 UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_int (statement, 4, (int)photoMark.size);
//            sqlite3_bind_text(statement, 5, [photoMark.purl UTF8String], -1, SQLITE_TRANSIENT);
//            sqlite3_bind_int (statement, 6, (int)photoMark.ver);
//            sqlite3_bind_text(statement, 7, [type UTF8String], -1, SQLITE_TRANSIENT);
//            
//            //执行插入语句
//            success2 = sqlite3_step(statement);
//            //释放statement
//            sqlite3_finalize(statement);
//            
//            //如果插入失败
//            if (success2 == SQLITE_ERROR) {
//                NSLog(@"Error: failed to insert into the database with message.");
//                ret = sqlite3_exec(_database , "rollback transaction" , 0 , 0 , & zErrorMsg);
//                //关闭数据库
//                sqlite3_close(_database);
//                return NO;
//            }
//        }
//        
////        NSLog(@"2222222");
//        
//        ret = sqlite3_exec(_database , "commit transaction" , 0 , 0 , & zErrorMsg);
//		sqlite3_close(_database);
//        
//		return YES;
//	}
//	return NO;
//}
//
//- (BOOL)insertTypeFace:(PRJ_TypeFaceObject *)typeFaceObject
//{
//    //先判断数据库是否打开
//	if ([self openDB]) {
//		
//        //能够使用sqlite3_step()执行编译好的准备语句的指针
//		sqlite3_stmt *statement;
//        
//        //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
//        char *sql = "INSERT INTO typeFaceTable(fid, lang ,md5 ,name , purl, size, url, var, fileName,fontName) VALUES(?,?,?,?,?,?,?,?,?,?)";
//        
//        //准备语句：第三个参数是从zSql中读取的字节数的最大值
//		int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
//		if (success2 != SQLITE_OK) {
//			NSLog(@"Error: failed to insert:typeFaceTable");
//			sqlite3_close(_database);
//			return NO;
//		}
//        
//        //这里的数字1，2，3代表第几个问号，这里将两个值绑定到两个绑定变量
//        sqlite3_bind_int (statement, 1, (int)typeFaceObject.fid);
//        sqlite3_bind_text(statement, 2, [typeFaceObject.lang UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 3, [typeFaceObject.md5 UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 4, [typeFaceObject.name UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 5, [typeFaceObject.purl UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_int (statement, 6, (int)typeFaceObject.size);
//        sqlite3_bind_text(statement, 7, [typeFaceObject.url UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_int (statement, 8, (int)typeFaceObject.var);
//        sqlite3_bind_text(statement, 9, [typeFaceObject.fileName UTF8String], -1, SQLITE_TRANSIENT);
//        sqlite3_bind_text(statement, 10, [typeFaceObject.fontName UTF8String], -1, SQLITE_TRANSIENT);
//        
//		//执行插入语句
//		success2 = sqlite3_step(statement);
//		//释放statement
//		sqlite3_finalize(statement);
//		
//		//如果插入失败
//		if (success2 == SQLITE_ERROR) {
//			NSLog(@"Error: failed to insert into the database with message.");
//			//关闭数据库
//			sqlite3_close(_database);
//			return NO;
//		}
//		//关闭数据库
//		sqlite3_close(_database);
//		return YES;
//	}
//	return NO;
//}

- (BOOL)insertAppInfo:(NSMutableArray *)appsInfo
{
    _tableType = AppInfo;
    _isMoreApp = YES;
    //先判断数据库是否打开
	if ([self openDB]) {
        _isMoreApp = NO;
        char *zErrorMsg;
        int ret;
        ret = sqlite3_exec(_database, "begin transaction" , 0 , 0 , &zErrorMsg);
        
        for (ME_AppInfo *appInfo in appsInfo) {
            //能够使用sqlite3_step()执行编译好的准备语句的指针
            
            sqlite3_stmt *statement;
            
            //这个 sql 语句特别之处在于 values 里面有个? 号。在sqlite3_prepare函数里，?号表示一个未定的值，它的值等下才插入。
            char *sql = "INSERT INTO appsInfoTable(appCate, appComment ,appId ,appName , bannerUrl, downUrl, iconUrl, packageName, price, openUrl, isHave ,appDesc) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)";
            
            //准备语句：第三个参数是从zSql中读取的字节数的最大值
            int success2 = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
            if (success2 != SQLITE_OK)
            {
                sqlite3_close(_database);
                return NO;
            }
            
            //这里的数字1，2，3代表第几个问号，这里将两个值绑定到两个绑定变量
            sqlite3_bind_text(statement, 1, [appInfo.appCate UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int (statement, 2, appInfo.appComment);
            sqlite3_bind_int (statement, 3, appInfo.appId);
            sqlite3_bind_text(statement, 4, [appInfo.appName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 5, [appInfo.bannerUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 6, [appInfo.downUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 7, [appInfo.iconUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 8, [appInfo.packageName UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 9, [appInfo.price UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_text(statement, 10, [appInfo.openUrl UTF8String], -1, SQLITE_TRANSIENT);
            sqlite3_bind_int (statement, 11, appInfo.isHave);
            sqlite3_bind_text(statement, 12, [appInfo.appDesc UTF8String], -1, SQLITE_TRANSIENT);
            
            //执行插入语句
            success2 = sqlite3_step(statement);
            //释放statement
            sqlite3_finalize(statement);
            
            //如果插入失败
            if (success2 == SQLITE_ERROR) {
                NSLog(@"Error: failed to insert into the database with message.");
                ret = sqlite3_exec(_database , "rollback transaction" , 0 , 0 , & zErrorMsg);
                //关闭数据库
                sqlite3_close(_database);
                return NO;
            }
        }
        
        ret = sqlite3_exec(_database , "commit transaction" , 0 , 0 , & zErrorMsg);
		sqlite3_close(_database);
        
		return YES;
	}
	return NO;
    
}

//获取全部数据
//- (NSMutableArray*)getAllData
//{
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
//	//判断数据库是否打开
//	if ([self openDB]) {
//		
//		sqlite3_stmt *statement = nil;
//        //sql语句  sid, url, md5, size, purl ,ver
//        
//        char *sql = "SELECT sid, url, md5, size, purl ,ver FROM photoMarkTable";
//        
//		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
//			NSLog(@"Error: failed to prepare statement with message:get testValue.");
//			return NO;
//		}else {
//			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
//            
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                PRJ_PhotoMarkObject* sqlChat = [[PRJ_PhotoMarkObject alloc] init] ;
//                
//                sqlChat.sid  = sqlite3_column_int(statement,0);
//                
//                char* url  = (char*)sqlite3_column_text(statement, 1);
//                sqlChat.url = [NSString stringWithUTF8String:url];
//                
//                char* md5  = (char*)sqlite3_column_text(statement, 2);
//                sqlChat.md5 = [NSString stringWithUTF8String:md5];
//                
//                sqlChat.size  = sqlite3_column_int(statement,3);
//                
//                char* purl  = (char*)sqlite3_column_text(statement, 4);
//                sqlChat.purl = [NSString stringWithUTF8String:purl];
//                
//                sqlChat.ver  = sqlite3_column_int(statement,5);
//                
//                [array addObject:sqlChat];
//            }
//			
//		}
//		sqlite3_finalize(statement);
//		sqlite3_close(_database);
//	}
//	
//	return array;
//}


- (NSMutableArray *)getAllAppsInfoData
{
    _tableType = AppInfo;
    _isMoreApp = YES;
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
	if ([self openDB])
    {
		_isMoreApp = NO;
        int i = 0;
            sqlite3_stmt *statement = nil;
            
            char *sql = "SELECT appCate ,appComment ,appId ,appName ,bannerUrl ,downUrl ,iconUrl, packageName, price, openUrl, isHave ,appDesc FROM appsInfoTable";
            
            if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK)
            {
                return NO;
            }
            else
            {
                //查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
                sqlite3_bind_int(statement, 1, i);
                
                while (sqlite3_step(statement) == SQLITE_ROW)
                {
                    ME_AppInfo* appInfo = [[ME_AppInfo alloc] init] ;
                    
                    char* appCate  = (char*)sqlite3_column_text(statement, 0);
                    appInfo.appCate = [NSString stringWithUTF8String:appCate];
                    
                    appInfo.appComment  = sqlite3_column_int(statement,1);
                    
                    appInfo.appId  = sqlite3_column_int(statement,2);
                    
                    char* appName  = (char*)sqlite3_column_text(statement, 3);
                    appInfo.appName = [NSString stringWithUTF8String:appName];
                    
                    char* bannerUrl  = (char*)sqlite3_column_text(statement, 4);
                    appInfo.bannerUrl = [NSString stringWithUTF8String:bannerUrl];
                    
                    char* downUrl  = (char*)sqlite3_column_text(statement, 5);
                    appInfo.downUrl = [NSString stringWithUTF8String:downUrl];
                    
                    char* iconUrl  = (char*)sqlite3_column_text(statement, 6);
                    appInfo.iconUrl = [NSString stringWithUTF8String:iconUrl];
                    
                    char* packageName  = (char*)sqlite3_column_text(statement, 7);
                    appInfo.packageName = [NSString stringWithUTF8String:packageName];
                    
                    char* price  = (char*)sqlite3_column_text(statement, 8);
                    appInfo.price = [NSString stringWithUTF8String:price];
                    
                    char* openUrl  = (char*)sqlite3_column_text(statement, 9);
                    appInfo.openUrl = [NSString stringWithUTF8String:openUrl];
                    
                    appInfo.isHave  = sqlite3_column_int(statement,10);
                    
                    char* appDesc  = (char*)sqlite3_column_text(statement, 11);
                    appInfo.appDesc = [NSString stringWithUTF8String:appDesc];
                    
                    [array addObject:appInfo];
                }
                sqlite3_finalize(statement);
            }
        sqlite3_close(_database);
    }
	
	return array;
}

//- (NSMutableArray *)getAllTypeFaces
//{
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
//	//判断数据库是否打开
//	if ([self openDB]) {
//		
//		sqlite3_stmt *statement = nil;
//        //sql语句  sid, url, md5, size, purl ,ver
//        
//        char *sql = "SELECT fid, lang, md5, name, purl ,size ,url ,var ,fileName ,fontName FROM typeFaceTable";
//        
//		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
//			NSLog(@"Error: failed to prepare statement with message:get testValue.");
//			return NO;
//		}else {
//			//查询结果集中一条一条的遍历所有的记录，这里的数字对应的是列值。
//            
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                PRJ_TypeFaceObject* sqlChat = [[PRJ_TypeFaceObject alloc] init] ;
//                
//                sqlChat.fid  = sqlite3_column_int(statement,0);
//                
//                char* lang  = (char*)sqlite3_column_text(statement, 1);
//                sqlChat.lang = [NSString stringWithUTF8String:lang];
//                
//                char* md5  = (char*)sqlite3_column_text(statement, 2);
//                sqlChat.md5 = [NSString stringWithUTF8String:md5];
//                
//                char* name  = (char*)sqlite3_column_text(statement, 3);
//                sqlChat.name = [NSString stringWithUTF8String:name];
//                
//                char* purl  = (char*)sqlite3_column_text(statement, 4);
//                sqlChat.purl = [NSString stringWithUTF8String:purl];
//                
//                sqlChat.size  = sqlite3_column_int(statement,5);
//                
//                char* url  = (char*)sqlite3_column_text(statement, 6);
//                sqlChat.url = [NSString stringWithUTF8String:url];
//                
//                sqlChat.var  = sqlite3_column_int(statement,7);
//                
//                char* fileName  = (char*)sqlite3_column_text(statement, 8);
//                sqlChat.fileName = [NSString stringWithUTF8String:fileName];
//                
//                char* fontName  = (char*)sqlite3_column_text(statement, 9);
//                sqlChat.fontName = [NSString stringWithUTF8String:fontName];
//                
//                [array addObject:sqlChat];
//            }
//			
//		}
//		sqlite3_finalize(statement);
//		sqlite3_close(_database);
//	}
//	
//	return array;
//}

- (BOOL)deleteAllDataForMarkType:(NSString *)markType
{
    if ([self openDB])
    {
        sqlite3_stmt *statement;
        char *sql = "delete from photoMarkTable where markType != ?";
        
        //将SQL语句放入sqlite3_stmt中
		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
			NSLog(@"Error: failed to delete:photoMarkTable");
			sqlite3_close(_database);
			return NO;
		}
        
        sqlite3_bind_text(statement, 1, [@"Nearly" UTF8String], -1, SQLITE_TRANSIENT);
        success = sqlite3_step(statement);
		sqlite3_finalize(statement);
        
		if (success == SQLITE_ERROR) {
			NSLog(@"Error: failed to delete the database with message.");
			sqlite3_close(_database);
			return NO;
		}
		sqlite3_close(_database);
		return YES;
    }
    
    return NO;
}

//删除数据
//- (BOOL)deleteChatList:(PRJ_PhotoMarkObject *)photoMark
//{
//    if ([self openDB]) {
//		
//		sqlite3_stmt *statement;
//        
//        char *sql = "delete from photoMarkTable  where sid = ? and markType = ?";
//        
//		//将SQL语句放入sqlite3_stmt中
//		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
//		if (success != SQLITE_OK) {
//			NSLog(@"Error: failed to delete:photoMarkTable");
//			sqlite3_close(_database);
//			return NO;
//		}
//		
//		//这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
//		//当掌握了原理后就不害怕复杂了
//        
//        sqlite3_bind_int(statement, 1, (int)photoMark.sid);
//        sqlite3_bind_text(statement, 2, [@"Nearly" UTF8String], -1, SQLITE_TRANSIENT);
//		
//		//执行SQL语句。这里是更新数据库
//		success = sqlite3_step(statement);
//		//释放statement
//		sqlite3_finalize(statement);
//		
//		//如果执行失败
//		if (success == SQLITE_ERROR) {
//			NSLog(@"Error: failed to delete the database with message.");
//			//关闭数据库
//			sqlite3_close(_database);
//			return NO;
//		}
//		//执行成功后依然要关闭数据库
//		sqlite3_close(_database);
//		return YES;
//	}
//	return NO;
//}
//
//- (BOOL)deleteTypeFace:(PRJ_TypeFaceObject *)typeFaceObject
//{
//    if ([self openDB]) {
//		
//		sqlite3_stmt *statement;
//        
//        char *sql = "delete from typeFaceTable  where fid = ?";
//        
//		//将SQL语句放入sqlite3_stmt中
//		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
//		if (success != SQLITE_OK) {
//			NSLog(@"Error: failed to delete:typeFaceTable");
//			sqlite3_close(_database);
//			return NO;
//		}
//		
//		//这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
//		//当掌握了原理后就不害怕复杂了
//        
//        sqlite3_bind_int(statement, 1, (int)typeFaceObject.fid);
//		
//		//执行SQL语句。这里是更新数据库
//		success = sqlite3_step(statement);
//		//释放statement
//		sqlite3_finalize(statement);
//		
//		//如果执行失败
//		if (success == SQLITE_ERROR) {
//			NSLog(@"Error: failed to delete the database with message.");
//			//关闭数据库
//			sqlite3_close(_database);
//			return NO;
//		}
//		//执行成功后依然要关闭数据库
//		sqlite3_close(_database);
//		return YES;
//	}
//	return NO;
//}
//
////查询数据
//- (NSMutableArray *)searchTestList:(NSString *)type
//{
//    NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
//	//判断数据库是否打开
//	if ([self openDB]) {
//        
//		sqlite3_stmt *statement = nil;
//		//sql语句
//        
//        char *sql;
//        if ([type isEqualToString:@"Nearly"])
//        {
//            sql = "SELECT sid, url, md5, size, purl ,ver FROM photoMarkTable WHERE markType = ? order by ID desc";
//        }
//        else
//        {
//            sql = "SELECT sid, url, md5, size, purl ,ver FROM photoMarkTable WHERE markType = ? order by sid desc";
//        }
//        
//		if (sqlite3_prepare_v2(_database, sql, -1, &statement, NULL) != SQLITE_OK) {
//			NSLog(@"Error: failed to prepare statement with message:search testValue.");
//			return NO;
//		}else {
//            sqlite3_bind_text(statement, 1, [type UTF8String], -1, SQLITE_TRANSIENT);
//            while (sqlite3_step(statement) == SQLITE_ROW) {
//                PRJ_PhotoMarkObject* photoMark = [[PRJ_PhotoMarkObject alloc] init];
//                
//                photoMark.sid = sqlite3_column_int(statement,0);
//                
//                char* url  = (char*)sqlite3_column_text(statement, 1);
//                photoMark.url = [NSString stringWithUTF8String:url];
//                
//                char* md5  = (char*)sqlite3_column_text(statement, 2);
//                photoMark.md5 = [NSString stringWithUTF8String:md5];
//                
//                photoMark.size = sqlite3_column_int(statement,3);
//                
//                char* purl = (char*)sqlite3_column_text(statement, 4);
//                photoMark.purl = [NSString stringWithUTF8String:purl];
//                
//                photoMark.ver = sqlite3_column_int(statement,5);
//                
//                [array addObject:photoMark];
//            }
//            
//		}
//		sqlite3_finalize(statement);
//		sqlite3_close(_database);
//	}
//	
//	return array;
//
//}

- (BOOL)deleteAllAppInfoData
{
    if ([self openDB])
    {
        sqlite3_stmt *statement;
        char *sql = "delete from appsInfoTable";
        
        //将SQL语句放入sqlite3_stmt中
        int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
        if (success != SQLITE_OK) {
            sqlite3_close(_database);
            return NO;
        }
        
        success = sqlite3_step(statement);
        sqlite3_finalize(statement);
        
        if (success == SQLITE_ERROR) {
            sqlite3_close(_database);
            return NO;
        }
        sqlite3_close(_database);
        return YES;
    }
    
    return NO;
}

//查询最大ID
- (NSInteger)selectMaxId
{
    NSInteger Maxid=0;
	NSString *strSQL =@"SELECT max(pid) FROM photoMarkTable";
	sqlite3_stmt *stmt;
	
	if (sqlite3_prepare_v2(_database, [strSQL UTF8String], -1, &stmt, nil)==SQLITE_OK) {
		if (sqlite3_step(stmt)==SQLITE_ROW) {
			Maxid=sqlite3_column_int(stmt, 0);
		}
	}
	sqlite3_finalize(stmt);
	return Maxid;
}

- (BOOL)updagteAppInfo:(int)appId withIsHaveDownLoad:(int)haveDownload
{
    _tableType = AppInfo;
    _isMoreApp = YES;
    if ([self openDB]) {
		_isMoreApp = NO;
        
 		//我想下面几行已经不需要我讲解了，嘎嘎
		sqlite3_stmt *statement;
		//组织SQL语句
		char *sql = "UPDATE appsInfoTable SET isHave = ? WHERE appId = ?;";
		
		//将SQL语句放入sqlite3_stmt中
		int success = sqlite3_prepare_v2(_database, sql, -1, &statement, NULL);
		if (success != SQLITE_OK) {
			sqlite3_close(_database);
			return NO;
		}
		
		//这里的数字1，2，3代表第几个问号。这里只有1个问号，这是一个相对比较简单的数据库操作，真正的项目中会远远比这个复杂
		//当掌握了原理后就不害怕复杂了
        
        sqlite3_bind_int(statement, 1, haveDownload);
		sqlite3_bind_int(statement, 2, appId);
		
		//执行SQL语句。这里是更新数据库
		success = sqlite3_step(statement);
		//释放statement
		sqlite3_finalize(statement);
		
		//如果执行失败
		if (success == SQLITE_ERROR) {
			NSLog(@"Error: failed to update the database with message.");
			//关闭数据库
			sqlite3_close(_database);
			return NO;
		}
		//执行成功后依然要关闭数据库
		sqlite3_close(_database);
		return YES;
	}
	return NO;
}



@end
