//
//  PRJ_DataRequest.h
//  IOSNoCrop
//
//  Created by rcplatform on 14-4-18.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"
#import "AFHTTPRequestOperation.h"
//#import "PRJ_TypeFaceObject.h"
#import "PRJ_ProtocolClass.h"

@interface PRJ_DataRequest : NSObject
{
    NSInteger requestTag;
    BOOL _isMoreApp;
}
@property (nonatomic ,weak) id <WebRequestDelegate,DownLoadTypeFaceDelegate> delegate;
@property (nonatomic ,strong) NSDictionary *valuesDictionary;//post的数据
@property (nonatomic ,strong) UIProgressView *progressView;

- (id)initWithDelegate:(id<WebRequestDelegate>)request_Delegate;

//请求图片贴纸图片
- (BOOL)requestPhotoMarksWithPostValues:(NSDictionary *)dictionary withTag:(NSInteger)tag;
//文字贴纸数据
- (void)requestTypeFaceWithPostValues:(NSDictionary *)dictionary;
//注册设备信息
- (void)registerToken:(NSDictionary *)dictionary withTag:(NSInteger)tag;
//版本更新
- (void)updateVersion:(NSString *)url withTag:(NSInteger)tag;
//下载文字贴纸
//- (AFHTTPRequestOperation *)downLoadTypeFaceWithTypeFace:(PRJ_TypeFaceObject *)typeFace indexPath:(NSInteger)row;
- (AFHTTPRequestOperation *)downLoadTypeFaceWithTypeFace:(PRJ_TypeFaceObject *)typeFace indexPath:(NSInteger)row ProgressView:(UIView *)progressView
;
//更多应用
- (void)moreApp:(NSDictionary *)dictionary withTag:(NSInteger)tag;

@end
