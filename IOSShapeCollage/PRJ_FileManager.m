//
//  TTFileManager.m
//  FileManager
//
//  Created by 陈怡涵－Cheer on 13-8-29.
//  Copyright (c) 2013年 peterlee. All rights reserved.
//

#import "PRJ_FileManager.h"

@implementation PRJ_FileManager

static PRJ_FileManager *ttManager = nil;

+ (PRJ_FileManager *)shareFileManager
{
    if (ttManager == nil) {
        ttManager = [[PRJ_FileManager alloc] init];
    }
    return ttManager;
}

- (id)init
{
    self = [super init];
    fileManage=[[NSFileManager alloc] init];
    return self;
}

//获取文件路径
- (NSString *)getSandBoxPath:(NSString *)path
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSString* newPath=nil;
    if (path != nil) {
        newPath= [documentsDirectory stringByAppendingPathComponent:path];
    }else{
        newPath=documentsDirectory;
    }
    if (![fileManage fileExistsAtPath:newPath]) {
		[fileManage createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:nil];
	}
    return newPath;
}

//读取图片
- (UIImage *)getImage:(NSString *)path
{
    path = [[self getSandBoxPath:@"ImageFile"] stringByAppendingPathComponent:path];
    if ([fileManage isReadableFileAtPath:path])
    {
        NSData * imageData =[fileManage contentsAtPath:path];
        UIImage* image = [UIImage imageWithData: imageData];
        return image;
    }
    return nil;
}

//存储图片
- (BOOL)saveImage:(UIImage *)image toFileAtPath:(NSString*)path toFileAtName:(NSString*)name
{
    path=[[self getSandBoxPath:path] stringByAppendingPathComponent:name];
    if (image == nil || path == nil || [path isEqualToString:@""]) {
        return NO;
    }else{
        NSData *imageData = nil;
		NSString *ext = [path pathExtension];
		if ([ext isEqualToString:@"png"])
		{
			imageData = UIImagePNGRepresentation(image);
		}
		else
		{
			imageData = UIImageJPEGRepresentation(image,0);
		}
		if ((imageData == nil) || ([imageData length] <= 0))
			return NO;
		[imageData writeToFile:path atomically:YES];
		return YES;
    }
}

//删除图片
- (BOOL)deleteImage:(NSString*)aPath toFileAtName:(NSString*)name
{
    aPath=[[self getSandBoxPath:aPath] stringByAppendingPathComponent:name];
    if ([fileManage fileExistsAtPath:aPath]) {
        NSError* error;
		[fileManage removeItemAtPath:aPath error:&error];
		if (error!=nil) {
			return NO;
		}
		else {
			return YES;
		}
    }
    return NO;
}

//存储各种类型（NSArray，NSDictionary....）
- (BOOL)saveData:(id)data toSandBoxPath:(NSString *)path
{
    if (data == nil || path == nil) {
        return NO;
    }else{
        //序列化
        NSData *dd = [NSKeyedArchiver archivedDataWithRootObject:data];//将s1序列化后,保存到NSData中
        NSString *dataPath = [[self getSandBoxPath:@"UserData"] stringByAppendingPathComponent:path];
        NSError* error;
        if ([fileManage fileExistsAtPath:dataPath]) {
            [fileManage removeItemAtPath:dataPath error:&error];
        }
        [dd writeToFile:dataPath atomically:YES];
        return YES;
    }
}

//读取指定路径的数据
- (id)readDataFromPath:(NSString *)path
{
    NSString *dataPath = [[self getSandBoxPath:@"UserData"] stringByAppendingPathComponent:path];
    NSData *data = [NSData dataWithContentsOfFile:dataPath];
    id dd = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    return dd;
}

//删除指定路径的数据
- (BOOL)deleteDataFromPath:(NSString *)path
{
    NSString *dataPath = [[self getSandBoxPath:@"UserData"] stringByAppendingPathComponent:path];
    if ([fileManage isDeletableFileAtPath:dataPath]) {
        NSError* error;
		[fileManage removeItemAtPath:dataPath error:&error];
        if (error!=nil) {
			return NO;
		}
		else {
			return YES;
		}
    }
    return NO;
}

//删除所有
- (BOOL)DeleteAllDataFile
{
	NSString* dataPath=[self getSandBoxPath:nil];
	if ([fileManage isDeletableFileAtPath:dataPath]) {
		NSError* error;
		[fileManage removeItemAtPath:dataPath error:&error];
		if (error!=nil) {
			return NO;
		}
		else {
			return YES;
		}
	}
	else
	{
		return NO;
	}
}

@end
