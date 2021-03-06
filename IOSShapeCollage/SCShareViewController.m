//
//  SCShareViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCShareViewController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>
#import "SCAppDelegate.h"
#import "PRJ_SQLiteMassager.h"
#import "PRJ_DataRequest.h"
#import "ME_AppInfo.h"
#import "UIImageView+WebCache.h"
#import "Pic_AdMobShowTimesManager.h"
#import "GADInterstitial.h"
#import "RC_ShareTableViewCell.h"
#import "SCMaskTouchView.h"
#import "MBProgressHUD+Add.h"

#define kTheBestImagePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shareImage.igo"]
#define kToMorePath [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"shareImage.jpg"]
#define editCountPath  [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"editCount.plist"]

#define saveViewSize CGSizeMake(1200, 1200)

#define labelWidth 75.f
#define labelHeight 20.f

#define showCount @"showShareAppCount"


@interface SCShareViewController ()

@end

@implementation SCShareViewController

//
//  FONT_ShareViewController.m
//  iOSFont
//
//  Created by wsq-wlq on 14-6-27.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

@synthesize isSaved;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 16, 46, 44)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = LocalizedString(@"rc_share", @"");
        titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:22];
        titleLabel.textColor = colorWithHexString(@"#28d8c9");
        self.navigationItem.titleView = titleLabel;
        
        // Custom initialization
    }
    return self;
}

- (void)getImage
{
    
    CGFloat scale = saveViewSize.width/self.view.frame.size.width;
    
    SCMaskTouchView *tempSaveView = (SCMaskTouchView *)saveView;
    
    CGSize size = tempSaveView.frame.size;
    size = CGSizeApplyAffineTransform(size, CGAffineTransformMakeScale(scale, scale));
    UIGraphicsBeginImageContext(size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, scale, scale);
    [tempSaveView.layer renderInContext:context];
    saveImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIGraphicsEndImageContext();
    
    NSData *imageData = UIImageJPEGRepresentation(saveImage, 1);
    
    NSLog(@"%@",kToMorePath);
    
    [imageData writeToFile:kToMorePath atomically:YES];
}

- (void)getImageFromView:(UIView *)tempView
{
    saveView = tempView;
    originTransform = tempView.transform;
}


-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self.navigationController setNavigationBarHidden:YES];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setObject:[NSNumber numberWithInt:count+1] forKey:showCount];
    [userDefault synchronize];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //导航
    //    UIView *customNavgationView = [[UIView alloc]initWithFrame:CGRectMake(0, TOPORIGIN_Y, 320, 44)];
    //    NSLog(@"%d",TOPORIGIN_Y);
    //    customNavgationView.backgroundColor = [UIColor redColor];
    //    [self.view addSubview:customNavgationView];
    
//    if (iPhone5)
//    {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shareViewBG.png"]];
//    }
//    else
//    {
//        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"shareViewBG-960.png"]];
//    }
    
    self.view.backgroundColor = colorWithHexString(@"#202020");
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backButton setFrame:CGRectMake(0, 0, 30, 30)];
    //    [backButton setBackgroundImage:[UIImage imageNamed:@"back.png"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"share_back.png"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    backButton.imageView.contentMode = UIViewContentModeCenter;
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 30 * 0.65);
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    UIButton *popToHomeViewButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [popToHomeViewButton setFrame:CGRectMake(kScreen_Width-44, 0, 30, 30)];
    [popToHomeViewButton addTarget:self action:@selector(popToHomeViewButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [popToHomeViewButton setBackgroundImage:[UIImage imageNamed:@"share_home.png"] forState:UIControlStateNormal];

    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithCustomView:popToHomeViewButton];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    NSArray *shareToArray = [NSArray arrayWithObjects:@"share_save-to-gallery.png", @"share_share-to-instagram.png", @"share_share-to-fb.png", @"share_more.png",nil];
    //    NSArray *shareToNameArray = [NSArray arrayWithObjects:@"save", @"instagram", @"faceBook", @"more", nil];
    NSArray *shareToNameArray = @[LocalizedString(@"rc_save", nil),
                                  @"Instagram",@"Facebook",
                                  LocalizedString(@"rc_more", nil)];
    
    for (int i = 0; i < 4; i ++)
    {
        @autoreleasepool
        {
            UIButton *shareToButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [shareToButton setBackgroundImage:[UIImage imageNamed:[shareToArray objectAtIndex:i]] forState:UIControlStateNormal];
            shareToButton.frame = CGRectMake(10+25*i+56*i, 20 , 56, 56);
            shareToButton.tag = i + 10;
            [shareToButton setTitle:[shareToNameArray objectAtIndex:i] forState:UIControlStateNormal];
            [shareToButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [shareToButton setTitleEdgeInsets:UIEdgeInsetsMake(80, -10, 0, -10)];
            shareToButton.titleLabel.textAlignment = NSTextAlignmentCenter;
            shareToButton.titleLabel.numberOfLines = 0;
            shareToButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            shareToButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
            [shareToButton addTarget:self action:@selector(shareToButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            [self.view addSubview:shareToButton];
        }
    }
    
    
//
//    UILabel *markLabel = [[UILabel alloc]initWithFrame:CGRectMake(20, 155, 240, 40)];
//    markLabel.text = LocalizedString(@"showwatermark", nil);
//    markLabel.textColor = [UIColor whiteColor];
//    markLabel.font = [UIFont systemFontOfSize:14.f];
//    [self.view addSubview:markLabel];
//    
//    UISwitch *switchBtn = [[UISwitch alloc]initWithFrame:CGRectMake(250, 160, 80, 40)];
//    if (app.isOn)
//    {
//        [switchBtn setOn:YES];
//    }
//    else
//    {
//        [switchBtn setOn:NO];
//    }
//    [switchBtn addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
//    [self.view addSubview:switchBtn];
    
    //判断是否已下载完数据
    if ([PRJ_Global shareStance].appsArray.count == 0)
    {
        //查看数据库中是否存在
        [PRJ_SQLiteMassager shareStance].tableType = moreApp;
        if ([[PRJ_SQLiteMassager shareStance] getAllAppInfoData].count == 0)
        {
            //Bundle Id
            NSString *bundleIdentifier = [[NSBundle mainBundle] bundleIdentifier];
            NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
            NSString *currentVersion = [infoDict objectForKey:@"CFBundleVersion"];
            NSString *language = [[NSLocale preferredLanguages] firstObject];
            if ([language isEqualToString:@"zh-Hans"])
            {
                language = @"zh";
            }
            else if ([language isEqualToString:@"zh-Hant"])
            {
                language = @"zh_TW";
            }
            NSDictionary *dic = @{@"appId":[NSNumber numberWithInt:moreAppID],@"packageName":bundleIdentifier,@"language":language,@"version":currentVersion,@"platform":[NSNumber numberWithInt:0]};
            PRJ_DataRequest *request = [[PRJ_DataRequest alloc] initWithDelegate:self];
            [request moreApp:dic withTag:11];
        }
        else
        {
            [PRJ_Global shareStance].appsArray = [[PRJ_SQLiteMassager shareStance] getAllAppInfoData];
            [PRJ_Global shareStance].appsArray = changeMoreTurnArray([PRJ_Global shareStance].appsArray);
        }
    }
    
//    appMoretableView = [[UITableView alloc]initWithFrame:CGRectZero];
//    if (iPhone5)
//    {
//        appMoretableView.frame = CGRectMake(0, 135, 320, kScreen_Height-210);
//    }
//    else
//    {
//        appMoretableView.frame = CGRectMake(0, 135, 320, kScreen_Height-210);
//    }
//    
//    appMoretableView.delegate = self;
//    appMoretableView.dataSource = self;
//    appMoretableView.backgroundColor = [UIColor clearColor];
//    appMoretableView.backgroundView = nil;
//    appMoretableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.view addSubview:appMoretableView];
    
    scrollView = [[UIScrollView alloc]initWithFrame:CGRectZero];
    if (iPhone5)
    {
        scrollView.frame = CGRectMake(0, 135, kScreen_Width, kScreen_Height-210-10);
    }
    else
    {
        scrollView.frame = CGRectMake(0, 135, kScreen_Width, kScreen_Height-210);
    }
    [self.view addSubview:scrollView];
    
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    if (app.moreAPPSArray.count > 0)
    {
        [self reloadAppInfo];
    }
    
    // Do any additional setup after loading the view.
}

- (void)reloadAppInfo
{
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if ([userDefault objectForKey:showCount] == nil)
    {
        [userDefault setObject:[NSNumber numberWithInt:0] forKey:showCount];
        [userDefault synchronize];
    }
    
    count = [(NSNumber *)[userDefault objectForKey:showCount] integerValue];
    
    
    BOOL canPopUp = NO;
    for (int i = 0; i < app.moreAPPSArray.count; i++)
    {
        count = count%app.moreAPPSArray.count;
        ME_AppInfo *appInfo = [app.moreAPPSArray objectAtIndex:count];
        NSString *string = appInfo.openUrl;
        NSURL *url = nil;
        
        if (![string isKindOfClass:[NSNull class]] && string != nil ) {
            url = [NSURL URLWithString:string];
        }else{
            url = nil;
        }
        if (![[UIApplication sharedApplication] canOpenURL:url])
        {
            canPopUp = YES;
            tempAppInfo = appInfo;
            break;
        }
        count = count+1;
    }
    if (canPopUp == NO)
    {
        tempAppInfo = [app.moreAPPSArray objectAtIndex:0];
        popCell = [[[NSBundle mainBundle] loadNibNamed:@"PopUpADView" owner:self options:nil] objectAtIndex:0];
        popCell.viewName = @"share";
        popCell.center = CGPointMake(scrollView.center.x, scrollView.frame.size.height/2);
        scrollView.contentSize = popCell.frame.size;
        popCell.center = CGPointMake(self.view.center.x, popCell.center.y);
        popCell.appInfo = tempAppInfo;
        [scrollView addSubview:popCell];
    }
    if (canPopUp == YES)
    {
        popCell = [[[NSBundle mainBundle] loadNibNamed:@"PopUpADView" owner:self options:nil] objectAtIndex:0];
        popCell.viewName = @"share";
        popCell.center = CGPointMake(scrollView.center.x, scrollView.frame.size.height/2);
        scrollView.contentSize = popCell.frame.size;
        popCell.center = CGPointMake(self.view.center.x, popCell.center.y);
        popCell.appInfo = tempAppInfo;
        [scrollView addSubview:popCell];
    }
}
- (void)switchChanged:(UISwitch *)switchBtn
{
//    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
//    
//    app.isOn = switchBtn.isOn;
//    if (app.isOn)
//    {
//        [self event:@"share" label:@"share_showwatermark"];
//        saveImage = [UIImage addwaterMarkOrnotWithImage:theBestImage];
//    }
//    else
//    {
//        [self event:@"share" label:@"share_hidewatermark"];
//        saveImage = theBestImage;
//    }
}

#pragma mark 导航按扭方法

//返回上一层
- (void)backButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    saveView.transform = CGAffineTransformScale(originTransform, 1, 1);
    saveImage = nil;
}

//返回到主页
- (void)popToHomeViewButtonPressed:(id)sender
{
    saveImage = nil;
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark 分享按扭方法

- (void)shareToButtonPressed:(id)sender
{
    if (!saveImage)
    {
        [self getImage];
    }
    UIButton *tempButton = (UIButton *)sender;
    NSInteger tag = tempButton.tag - 10;
    switch (tag)
    {
        case 0:
            //保存到相册
        {
            [self event:@"share" label:@"share_save"];
            UIImageWriteToSavedPhotosAlbum(saveImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
            break;
        case 1:
            //分享到instagram
        {
            [self event:@"share" label:@"share_instagram"];
            if([[NSFileManager defaultManager] fileExistsAtPath:kTheBestImagePath]){
                [[NSFileManager defaultManager] removeItemAtPath:kTheBestImagePath error:nil];
            }
            
            NSData *imageData = UIImageJPEGRepresentation(saveImage, 1);
            [imageData writeToFile:kTheBestImagePath atomically:YES];
            
            //分享
            NSURL *fileURL = [NSURL fileURLWithPath:kTheBestImagePath];
            _documetnInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            _documetnInteractionController.delegate = self;
            _documetnInteractionController.UTI = @"com.instagram.photo";
            //    _documetnInteractionController.UTI = @"public.png";
            _documetnInteractionController.annotation = @{@"InstagramCaption":kShareHotTags};
            BOOL canOpne = [_documetnInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
            if (canOpne == NO)
            {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"" message:LocalizedString(@"rc_no_instagram", @"") delegate:self cancelButtonTitle:LocalizedString(@"rc_custom_positive", @"") otherButtonTitles:nil, nil];
                [alert show];
            }
        }
            break;
        case 2:
            //分享到faceBook
        {
            [self event:@"share" label:@"share_facebook"];
            if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook])
            {
                slComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                //                    [slComposerSheet setInitialText:self.sharingText];
                if([[NSFileManager defaultManager] fileExistsAtPath:kTheBestImagePath]){
                    [[NSFileManager defaultManager] removeItemAtPath:kTheBestImagePath error:nil];
                }
                
                NSData *imageData = UIImageJPEGRepresentation(saveImage, 0.8);
                [imageData writeToFile:kTheBestImagePath atomically:YES];
                UIImage *image = [UIImage imageWithContentsOfFile:kTheBestImagePath];
                
                [slComposerSheet addImage:image];
                //                [slComposerSheet addURL:[NSURL URLWithString:@"http://www.facebook.com/"]];
                [self presentViewController:slComposerSheet animated:YES completion:nil];
            }
            else
            {
                [[[UIAlertView alloc] initWithTitle:@"No Facebook Account" message:@"There are no Facebook accounts configured. You can add or create a Facebook account in Settings" delegate: nil cancelButtonTitle:LocalizedString(@"conform", nil) otherButtonTitles:nil, nil] show];
                return;
            }
            __block SCShareViewController *controller = self;
            __block UIImage *blockImage = saveImage;
            [slComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result)
             {
                 
                 NSLog(@"start completion block");
                 switch (result) {
                     case SLComposeViewControllerResultCancelled:
                         //                         output = @"Action Cancelled";
                         break;
                     case SLComposeViewControllerResultDone:
                         
                         //                         output = @"Post Successfull";
                         break;
                     default:
                         break;
                 }
                 if (result != SLComposeViewControllerResultCancelled)
                 {
//                     [MBProgressHUD showSuccess:LocalizedString(@"share-success", @"")
//                                         toView:[UIApplication sharedApplication].keyWindow];
                     UIImageWriteToSavedPhotosAlbum(blockImage, controller, nil, nil);
                 }
             }];
            
        }
            break;
        case 3:
            //更多
        {
            [self event:@"share" label:@"share_more"];
            //保存本地 如果已存在，则删除
            if([[NSFileManager defaultManager] fileExistsAtPath:kToMorePath]){
                [[NSFileManager defaultManager] removeItemAtPath:kToMorePath error:nil];
            }
            
            NSData *imageData = UIImageJPEGRepresentation(saveImage, 0.8);
            [imageData writeToFile:kToMorePath atomically:YES];
            
            NSURL *fileURL = [NSURL fileURLWithPath:kToMorePath];
            _documetnInteractionController = [UIDocumentInteractionController interactionControllerWithURL:fileURL];
            _documetnInteractionController.delegate = self;
            _documetnInteractionController.UTI = @"com.instagram.photo";
            _documetnInteractionController.annotation = @{@"InstagramCaption":kShareHotTags};
            [_documetnInteractionController presentOpenInMenuFromRect:CGRectMake(0, 0, 0, 0) inView:self.view animated:YES];
        }
            break;
        default:
            break;
    }
}
#pragma mark 保存至本地相册 结果反馈
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo{
    if(error == nil)
    {
        [MBProgressHUD showSuccess:LocalizedString(@"rc_image_save_to_album_already", @"")
                            toView:[UIApplication sharedApplication].keyWindow];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"isSave" object:nil];
//        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//        //4次启动弹窗评价
//        int lanchCount = [[userDefault objectForKey:LANCHCOUNT] intValue];
//        if (lanchCount != -1)
//        {
//            if(lanchCount % 2 == 0)
//            {
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                                message:LocalizedString(@"comment_message_default", nil)
//                                                               delegate:self
//                                                      cancelButtonTitle:LocalizedString(@"feedback", nil)
//                                                      otherButtonTitles:LocalizedString(@"rate_now", nil), LocalizedString(@"attention_later", nil), nil];
//                alert.tag = 11;
//                [alert show];
//            }
//            lanchCount++;
//            [userDefault setObject:@(lanchCount) forKey:LANCHCOUNT];
//            [userDefault synchronize];
//        }
    }
    else
    {
        [MBProgressHUD showError:LocalizedString(@"rc_save_failed", @"")
                          toView:[UIApplication sharedApplication].keyWindow];
    }
}

#pragma mark -
#pragma mark UITableViewDelegate And UITableDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return appMoretableView.frame.size.height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [PRJ_Global shareStance].appsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RC_ShareTableViewCell *cell = (RC_ShareTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (cell == nil)
    {
        cell = [[RC_ShareTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell" withCellHeight:tableView.bounds.size.height+10];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
    }
    ME_AppInfo *appInfo = [[PRJ_Global shareStance].appsArray objectAtIndex:indexPath.row];
    
    [cell.app_logo_imageView sd_setImageWithURL:[NSURL URLWithString:appInfo.iconUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
    cell.app_title_label.text = appInfo.appName;
    cell.app_detail_label.text = appInfo.appDesc;
    [cell.app_bander_imageView sd_setImageWithURL:[NSURL URLWithString:appInfo.bannerUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ME_AppInfo *appInfo = [[PRJ_Global shareStance].appsArray objectAtIndex:indexPath.row];
    
    [self event:@"home" label:[NSString stringWithFormat:@"shareMoreApp_%d",appInfo.appId]];
    
    if (![[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appInfo.openUrl]])
    {
        NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appInfo.downUrl];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
    }
    else
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appInfo.openUrl]];
    }
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)didReceivedData:(NSDictionary *)dic withTag:(NSInteger)tag
{
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    NSArray *infoArray = [dic objectForKey:@"list"];
    //判断是否有新应用
    [PRJ_SQLiteMassager shareStance].tableType = moreApp;
    
    NSMutableArray *sqlArray = [[NSMutableArray alloc]init];
    for (NSMutableDictionary *infoDic in infoArray)
    {
        ME_AppInfo *appInfo = [[ME_AppInfo alloc]initWithDictionary:infoDic];
        [sqlArray addObject:appInfo];
    }
    
    //判断是否有新应用
    [PRJ_SQLiteMassager shareStance].tableType = moreApp;
    NSMutableArray *dataArray = [[PRJ_SQLiteMassager shareStance] getAllAppInfoData];
    for (ME_AppInfo *app in sqlArray)
    {
        BOOL isHave = NO;
        for (ME_AppInfo *appInfo in dataArray)
        {
            if (app.appId == appInfo.appId)
            {
                isHave = YES;
            }
        }
        if (!isHave)
        {
            [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:@"MoreAPP"];
            [[NSUserDefaults standardUserDefaults]synchronize];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"addMoreImage" object:nil];
            break;
        }
    }
    [PRJ_SQLiteMassager shareStance].tableType = moreApp;
    [[PRJ_SQLiteMassager shareStance] deleteAllAppInfoData];
    [[PRJ_SQLiteMassager shareStance] insertAppInfo:sqlArray];
    
    app.moreAPPSArray = changeMoreTurnArray(sqlArray);
    [appMoretableView reloadData];
}

- (void)requestFailed:(NSInteger)tag
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark 事件统计
- (void)event:(NSString *)eventID label:(NSString *)label;
{
    //友盟
    [MobClick event:eventID label:label];
    
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (alertView.tag == 11)
    {
        if(buttonIndex == 2)
        {
            return;
        }
        
        if(buttonIndex == 1)
        {//马上评
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kAppStoreURL]];
            NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
            [userDefault setObject:[NSString stringWithFormat:@"%d",-1] forKey:LANCHCOUNT];
            [userDefault synchronize];
        }
        if (buttonIndex == 0)
        {
            //返馈
            // app名称 版本
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleVersion"];
            
            //设备型号 系统版本
            NSString *deviceName = doDevicePlatform();
            NSString *deviceSystemName = [[UIDevice currentDevice] systemName];
            NSString *deviceSystemVer = [[UIDevice currentDevice] systemVersion];
            
            //设备分辨率
            CGFloat scale = [UIScreen mainScreen].scale;
            CGFloat resolutionW = [UIScreen mainScreen].bounds.size.width * scale;
            CGFloat resolutionH = [UIScreen mainScreen].bounds.size.height * scale;
            NSString *resolution = [NSString stringWithFormat:@"%.f * %.f", resolutionW, resolutionH];
            
            //本地语言
            NSString *language = [[NSLocale preferredLanguages] firstObject];
            
            //NSString *diveceInfo = @"app版本号 手机型号 手机系统版本 分辨率 语言";
            NSString *diveceInfo = [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@, %@", app_Name, app_Version, deviceName, deviceSystemName, deviceSystemVer,  resolution, language];
            
            //直接发邮件
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            picker.mailComposeDelegate =self;
            NSString *subject = @"-CollageShape Feedback";
            [picker setSubject:subject];
            [picker setToRecipients:@[kFeedbackEmail]];
            [picker setMessageBody:diveceInfo isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
        }
    }
    
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
