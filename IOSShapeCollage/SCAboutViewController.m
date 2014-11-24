//
//  SCAboutViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCAboutViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

#import "PRJ_DataRequest.h"
#import "MBProgressHUD.h"
@interface SCAboutViewController ()

@property (nonatomic, strong) UITableView *tabbleView;
@property (nonatomic, strong) NSArray *tableNameArray;
@property (nonatomic, strong) NSArray *tableImageArray;
@end

@implementation SCAboutViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    UIImageView *backImage = [[UIImageView alloc]initWithFrame:self.view.bounds];
//    backImage.image = [UIImage imageNamed:@"aboutUsBG.png"];
    self.view.backgroundColor = colorWithHexString(@"#0e1b1b");
//    [self.view addSubview:backImage];
    _tableImageArray = [[NSArray alloc]initWithObjects:@"更新",@"评分",@"关注我们",@"反馈",@"分享", nil];
    _tableNameArray = [[NSArray alloc]initWithObjects:
                       LocalizedString(@"update", nil),
                       LocalizedString(@"rate", nil),
                       LocalizedString(@"follow", nil),
                       LocalizedString(@"feedback", nil),
                       LocalizedString(@"share", nil),
                       nil];
    
    _tabbleView = [[UITableView alloc]initWithFrame:CGRectMake(0, 44, 260, self.view.frame.size.height) style:UITableViewStylePlain];
    _tabbleView.backgroundColor = colorWithHexString(@"#0e1b1b");
    _tabbleView.backgroundView = nil;
    _tabbleView.separatorStyle = UITableViewCellSelectionStyleNone;
    _tabbleView.delegate = self;
    _tabbleView.dataSource = self;
    [self.view addSubview:_tabbleView];
    // Do any additional setup after loading the view.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
{
    return [_tableNameArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *indentify = @"aboutCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentify];
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:indentify];
        cell.backgroundView = nil;
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        [cell.textLabel sizeToFit];
    }
    cell.imageView.image = [UIImage imageNamed:[_tableImageArray objectAtIndex:indexPath.row]];
    cell.textLabel.text = [_tableNameArray objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath;
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.row) {
        case 0://更新
        {
            [self event:@"home" label:@"home_menu_update"];
            NSString *upDateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", appleID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:upDateString]];
        }
            
            break;
        case 1://评分
        {
            [self event:@"home" label:@"home_menu_rateus"];
            NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?type=Purple+Software&id=%@", appleID];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
        }
            break;
        case 2://关注我
        {
            [self event:@"home" label:@"home_menu_followus"];
            NSURL *instagramURL = [NSURL URLWithString:instagramFollowString];
            if ([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
                [[UIApplication sharedApplication] openURL:instagramURL];
            }else {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kFollwUsURL]];
            }
        }
            break;

        case 3://反馈
        {
            [self event:@"home" label:@"home_menu_feedback"];
            
            // app名称 版本
            NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
            NSString *app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
            NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
            
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
            
            //            NSString *diveceInfo = @"app版本号 手机型号 手机系统版本 分辨率 语言";
            NSString *diveceInfo = [NSString stringWithFormat:@"%@ %@, %@, %@ %@, %@, %@", app_Name, app_Version, deviceName, deviceSystemName, deviceSystemVer,  resolution, language];
            
            //直接发邮件
            MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
            if(!picker) break;
            picker.mailComposeDelegate =self;
            NSString *subject = [NSString stringWithFormat:@"%@ %@ (iOS)",app_Name, LocalizedString(@"feedback", nil)];
            [picker setSubject:subject];
            [picker setToRecipients:@[kFeedbackEmail]];
            [picker setMessageBody:diveceInfo isHTML:NO];
            [self presentViewController:picker animated:YES completion:nil];
        }
            break;
        case 4://分享应用
        {
            [self event:@"home" label:@"home_menu_share"];
            //需要分享的内容
            NSString *shareContent = [NSString stringWithFormat:@"%@ http://bit.ly/1r0PhkE",LocalizedString(@"share_msg", @"")];
            NSArray *activityItems = @[shareContent];
            
            UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
            __weak UIActivityViewController *blockActivityVC = activityVC;
            
            activityVC.completionHandler = ^(NSString *activityType,BOOL completed){
                if(completed){
                    //                    MBProgressHUD *hud = showMBProgressHUD(@"success", NO);
                    //                    [hud performSelector:@selector(hide:) withObject:nil afterDelay:1.5];
                }
                [blockActivityVC dismissViewControllerAnimated:YES completion:nil];
            };
            [self presentViewController:activityVC animated:YES completion:nil];
        }
            
            break;
        default:
            break;
    }
}

#pragma mark -
#pragma mark 版本检测
- (void)checkVersion
{
    NSString *urlStr = [NSString stringWithFormat:@"http://itunes.apple.com/lookup?id=%@",appleID];
    PRJ_DataRequest *request = [[PRJ_DataRequest alloc] initWithDelegate:self];
    [request updateVersion:urlStr withTag:10];
}

#pragma mark - MFMailComposeViewControllerDelegate
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark 事件统计
- (void)event:(NSString *)eventID label:(NSString *)label;
{
    //友盟
    [MobClick event:eventID label:label];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
