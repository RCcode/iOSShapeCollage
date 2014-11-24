//
//  PRJ_DataRequest.m
//  IOSNoCrop
//
//  Created by rcplatform on 14-4-18.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "PRJ_DataRequest.h"
#import "SCAppDelegate.h"
#import "PRJ_SQLiteMassager.h"
#import "CMethods.h"
#import "Reachability.h"

//#define kMoreAppBaseURL @"http://192.168.0.86:9998/pbweb/app/"
#define kMoreAppBaseURL @"http://moreapp.rcplatformhk.net/pbweb/app/"

@implementation PRJ_DataRequest

- (id)initWithDelegate:(id<WebRequestDelegate,DownLoadTypeFaceDelegate>)request_Delegate
{
    self = [super init];
    
    self.delegate = request_Delegate;
    
    return self;
}

#pragma mark -
#pragma mark 公共请求 （Post）
- (void)requestServiceWithPost:(NSString *)url_Str jsonRequestSerializer:(AFJSONRequestSerializer *)requestSerializer isRegisterToken:(BOOL)token
{

    NSString *url = nil;
    if ([url_Str isEqualToString:@"getStickerInfos.do"])
    {
        url = [NSString stringWithFormat:@"%@%@",HTTP_BASEURL,url_Str];
        
    }
    else
    {
        url = [NSString stringWithFormat:@"%@",url_Str];
    }
    
    
    SCAppDelegate *appDelegate = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [MBProgressHUD showHUDAddedTo:appDelegate.window animated:YES];
    
    appDelegate.manager.requestSerializer = requestSerializer;
    
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    appDelegate.manager.responseSerializer = responseSerializer;
    
    //    NSData *jsonData = [self.valuesDictionary JSONData];
    [appDelegate.manager POST:token? kPushURL:url parameters:self.valuesDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        //解析数据
        NSDictionary *dic = responseObject;
        NSLog(@"%@",[dic objectForKey:@"message"]);
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
        if (_delegate != nil)
        {
            [_delegate didReceivedData:dic withTag:requestTag];
        }
        
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        hideMBProgressHUD();
        NSLog(@"error.......%@",error);
        [MBProgressHUD hideAllHUDsForView:appDelegate.window animated:YES];
//        [self.delegate requestFailed:requestTag];
    }];
}

#pragma mark -
#pragma mark 公共请求 （Get）
- (void)requestServiceWithGet:(NSString *)url_Str
{
    SCAppDelegate *appDelegate = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    appDelegate.manager.requestSerializer = requestSerializer;
    AFJSONResponseSerializer *responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    appDelegate.manager.responseSerializer = responseSerializer;
    
    [appDelegate.manager GET:url_Str parameters:nil
                     success:^(AFHTTPRequestOperation *operation, id responseObject) {
                         //解析数据
                         NSDictionary *dic = (NSDictionary *)responseObject;
                         [self.delegate didReceivedData:dic withTag:requestTag];
    }
                     failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                         [self.delegate requestFailed:requestTag];
    }];
    
}

#pragma mark -
#pragma mark 检测网络状态
- (BOOL)checkNetWorking
{
    
    BOOL connected = [[Reachability reachabilityForInternetConnection] currentReachabilityStatus] != NotReachable ? YES : NO;
    
    if (!connected) {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:LocalizedString(@"tips", @"")
//                                                       message:LocalizedString(@"connection_exception", @"")
//                                                      delegate:nil
//                                             cancelButtonTitle:@"OK"
//                                             otherButtonTitles:nil];
//        [alert show];
    }
    
    return connected;
}

#pragma mark -
#pragma mark 请求图片贴纸图片
- (BOOL)requestPhotoMarksWithPostValues:(NSDictionary *)dictionary withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return NO;
    requestTag = tag;
    self.valuesDictionary = dictionary;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setTimeoutInterval:30];
    [self requestServiceWithPost:@"getStickerInfos.do" jsonRequestSerializer:requestSerializer isRegisterToken:NO];
    
    return YES;
}

#pragma mark -
#pragma mark 请求字体贴纸数据
- (void)requestTypeFaceWithPostValues:(NSDictionary *)dictionary
{
    if (![self checkNetWorking]){
        showMBProgressHUD(LocalizedString(@"no_network_toast_string", nil), NO);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            hideMBProgressHUD();
        });
        return;
    }
    
    showMBProgressHUD(nil, YES);
    self.valuesDictionary = dictionary;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setTimeoutInterval:15];
    [self requestServiceWithPost:@"getFonts.do" jsonRequestSerializer:requestSerializer isRegisterToken:NO];
}

#pragma mark -
#pragma mark 注册设备
- (void)registerToken:(NSDictionary *)dictionary withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return;
    requestTag = tag;
    self.valuesDictionary = dictionary;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setTimeoutInterval:30];
    [self requestServiceWithPost:nil jsonRequestSerializer:requestSerializer  isRegisterToken:YES];
}

#pragma mark -
#pragma mark 版本更新
- (void)updateVersion:(NSString *)url withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return;
    requestTag = tag;
    [self requestServiceWithGet:url];
}

#pragma mark -
#pragma mark 更多应用
- (void)moreApp:(NSDictionary *)dictionary withTag:(NSInteger)tag
{
    if (![self checkNetWorking])
        return;
    requestTag = tag;
    self.valuesDictionary = dictionary;
    AFJSONRequestSerializer *requestSerializer = [AFJSONRequestSerializer serializer];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [requestSerializer setTimeoutInterval:30];
    
//    [self requestServiceWithPost:@"http://moreapp.rcplatformhk.net/pbweb/app/getIOSAppList.do" jsonRequestSerializer:requestSerializer  isRegisterToken:NO];
    [self requestServiceWithPost:@"http://moreapp.rcplatformhk.net/pbweb/app/getIOSAppListNew.do" jsonRequestSerializer:requestSerializer  isRegisterToken:NO];
}

//#pragma mark -
//#pragma mark 下载字体
//- (AFHTTPRequestOperation *)downLoadTypeFaceWithTypeFace:(PRJ_TypeFaceObject *)typeFace indexPath:(NSInteger)row
//{
//    if (![self checkNetWorking])
//        return nil;
//    
//    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [docs[0] stringByAppendingPathComponent:@"TypeFaces"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//	}
//    NSString *filePath = [path stringByAppendingPathComponent:typeFace.fileName];
//    
//    NSString *str = [typeFace.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:str];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    AFHTTPRequestOperation *operationManager = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//
//    operationManager.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
//    [operationManager setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        
//        
//        //进度 0-1
//        float mulite = (float)totalBytesRead/totalBytesExpectedToRead;
//        NSLog(@"mulite - %.2f", mulite);
//        
//        if(mulite != 1){
//            //下载中
//            [self startRotateView:self.progressView];
//            
//        }else{
//            //下载完成
//            [self stopRotateView:self.progressView];
//        }
//    }];
//    
//    [operationManager setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"downLoad success!");
////        self.progressView.transform = CGAffineTransformIdentity;
////        self.progressView.hidden = YES;
////        self.progressView = nil;
//        [PRJ_SQLiteMassager shareStance].tableType = TypeFaceType;
//        [[PRJ_SQLiteMassager shareStance] insertTypeFace:typeFace];
//        [_delegate haveDownLoadTypeFaceIndex:row];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure....:%@",error);
//        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
//    }];
//    
//    return operationManager;
//}

//- (AFHTTPRequestOperation *)downLoadTypeFaceWithTypeFace:(PRJ_TypeFaceObject *)typeFace indexPath:(NSInteger)row ProgressView:(UIView *)progressView
//{
//    NSTimer *timer = [self startRotateView:progressView];
//    UIImageView *imageView = (UIImageView *)progressView;
//    imageView.image = pngImagePath(@"ic_main_loading");
//    
//    if (![self checkNetWorking])
//    return nil;
//    
//    NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    NSString *path = [docs[0] stringByAppendingPathComponent:@"TypeFaces"];
//    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
//		[[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
//	}
//    NSString *filePath = [path stringByAppendingPathComponent:typeFace.fileName];
//    
//    NSString *str = [typeFace.url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    NSURL *url = [NSURL URLWithString:str];
//    NSURLRequest *request = [NSURLRequest requestWithURL:url];
//    AFHTTPRequestOperation *operationManager = [[AFHTTPRequestOperation alloc] initWithRequest:request];
//    
//    
//    
//    operationManager.outputStream = [NSOutputStream outputStreamToFileAtPath:filePath append:NO];
//    [operationManager setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//
//        //进度 0-1
//        float mulite = (float)totalBytesRead/totalBytesExpectedToRead;
//        
////        NSLog(@"mulite - %.2f", mulite);
//        
//        if(mulite == 1){
//            [self stopRotateView:progressView Timer:timer];
//        }
//    }];
//    
//    [operationManager setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
//        NSLog(@"downLoad success!");
//        //        self.progressView.transform = CGAffineTransformIdentity;
//        //        self.progressView.hidden = YES;
//        //        self.progressView = nil;
//        [PRJ_SQLiteMassager shareStance].tableType = TypeFaceType;
//        [[PRJ_SQLiteMassager shareStance] insertTypeFace:typeFace];
//        [_delegate haveDownLoadTypeFaceIndex:row];
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        NSLog(@"failure....:%@",error);
//        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
//    }];
//    
//    return operationManager;
//}


- (NSTimer *)startRotateView:(UIView *)view{
    return [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotateView:) userInfo:view repeats:YES];
}

- (void)stopRotateView:(UIView *)view Timer:(NSTimer *)timer{
    [timer invalidate];
    view.transform = CGAffineTransformIdentity;
    UIImageView *imageView = (UIImageView *)view;
    imageView.image = pngImagePath(@"ic_box_delete@2x");
}

- (void)rotateView:(NSTimer *)timer{
    
//    dispatch_async(dispatch_get_main_queue(), ^{

        UIView *view = timer.userInfo;
        
        [UIView animateWithDuration:0.01 animations:^{
            
            if(timer.isValid){
                view.transform = CGAffineTransformRotate(view.transform, M_PI_4 * 0.1);
            }
        }];
        
//    });

    
}


@end
