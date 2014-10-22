//
//  TTFileManager.h
//  FileManager
//
//  Created by 陈怡涵－Cheer on 13-8-29.
//  Copyright (c) 2013年 peterlee. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRJ_FileManager : NSObject
{
    NSFileManager *fileManage;
}

+ (PRJ_FileManager *)shareFileManager;
- (BOOL)DeleteAllDataFile;
- (BOOL)deleteImage:(NSString*)aPath toFileAtName:(NSString*)name;
- (BOOL)saveImage:(UIImage *)image toFileAtPath:(NSString*)path toFileAtName:(NSString*)name; 
- (UIImage *)getImage:(NSString *)path;
- (BOOL)saveData:(id)data toSandBoxPath:(NSString *)path;
- (id)readDataFromPath:(NSString *)path;
- (BOOL)deleteDataFromPath:(NSString *)path;

@end
