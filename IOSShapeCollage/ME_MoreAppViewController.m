//
//  ME_MoreAppViewController.m
//  IOSMirror
//
//  Created by gaoluyangrc on 14-7-14.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "ME_MoreAppViewController.h"
#import "PRJ_DataRequest.h"
#import "CMethods.h"
#import "Me_MoreTableViewCell.h"
#import "ME_AppInfo.h"
#import "UIImageView+WebCache.h"
#import <StoreKit/StoreKit.h>
#import "PRJ_SQLiteMassager.h"
#import "SCAppDelegate.h"

@interface ME_MoreAppViewController () <UITableViewDataSource,UITableViewDelegate,SKStoreProductViewControllerDelegate>
{
    UITableView *appInfoTableView;
    NSTimer *_timer;
}
@end

@implementation ME_MoreAppViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc
{
    appInfoTableView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = colorWithHexString(@"#0e1b1b");
    self.view.frame = CGRectMake(0, 0, kScreen_Width, kScreen_Height);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"More Apps";
    
    if (iPhone5)
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG-font-download-1136.png"]];
    }
    else
    {
        self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BG-font-download-960.png"]];
    }
    
    UIButton *leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftItemButton.frame = CGRectMake(0, 0, 30, 30);
    [leftItemButton setBackgroundImage:[UIImage imageNamed:@"edit_back.png"] forState:UIControlStateNormal];
    [leftItemButton addTarget:self action:@selector(leftItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];//    navBackItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, itemWH * 0.65);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:leftItemButton];
    
    //    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
    //    self.navigationItem.rightBarButtonItem = rightItem;
    
    //判断是否已下载完数据
    SCAppDelegate *app = (SCAppDelegate *)[UIApplication sharedApplication].delegate;
    
    if (app.moreAPPSArray.count == 0)
    {
        MBProgressHUD *hud = showMBProgressHUD(nil, YES);
        hud.userInteractionEnabled = NO;
        hud.color = [UIColor blackColor];
        
        //查看数据库中是否存在
        [PRJ_SQLiteMassager shareStance].tableType = AppInfo;
        if ([[PRJ_SQLiteMassager shareStance] getAllAppsInfoData].count == 0)
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
            app.moreAPPSArray = [[PRJ_SQLiteMassager shareStance] getAllAppsInfoData];
            app.moreAPPSArray = changeMoreTurnArray(app.moreAPPSArray);
        }
        hideMBProgressHUD();
    }
//    for (ME_AppInfo* appInfo in app.appsArray)
//    {
//        if (appInfo.openUrl)
//        {
//            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appInfo.openUrl]])
//            {
//                <#statements#>
//            }
//        }
//    }
    
    
    appInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.frame.size.height) style:UITableViewStylePlain];
    [appInfoTableView registerNib:[UINib nibWithNibName:@"Me_MoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    appInfoTableView.backgroundColor = [UIColor clearColor];
    appInfoTableView.backgroundView = nil;
    appInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    appInfoTableView.delegate = self;
    appInfoTableView.dataSource = self;
    [self.view addSubview:appInfoTableView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateState) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
//    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)updateState{
    [appInfoTableView reloadData];
}

- (void)leftItemButtonPressed:(id)sender
{
    
    cancleAllRequests();
    hideMBProgressHUD();
    [[NSNotificationCenter defaultCenter] postNotificationName:@"restartTimer" object:nil];
    [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:@"MoreAPP"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removeMoreImage" object:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)rightItemClick
{
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 95.f;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] moreAPPSArray] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Me_MoreTableViewCell *cell = (Me_MoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.delegate = self;
    
    ME_AppInfo *appInfo = [[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] moreAPPSArray] objectAtIndex:indexPath.row];
    NSLog(@"%@",appInfo.appName);
    CGSize appNameSize = getTextLabelRectWithContentAndFont(appInfo.appName, [UIFont fontWithName:FONTNAMESTRING size:14]).size;
    if (appNameSize.height < 20.f)
    {
        [cell.titleLabel setFrame:CGRectMake(cell.typeLabel.frame.origin.x, cell.typeLabel.frame.origin.y - appNameSize.height - 6, appNameSize.width+5, appNameSize.height)];
    }
    else
    {
        [cell.titleLabel setFrame:CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y - 6, appNameSize.width+5, appNameSize.height)];
    }
    cell.titleLabel.font = [UIFont systemFontOfSize:14];
    cell.titleLabel.text = appInfo.appName;
    cell.typeLabel.text = appInfo.appCate;

    [cell.logoImageView sd_setImageWithURL:[NSURL URLWithString:appInfo.iconUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
    
    cell.commentLabel.text = [NSString stringWithFormat:@"(%d)",appInfo.appComment];
    NSString *title = @"";
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appInfo.openUrl]])
    {
        title = LocalizedString(@"open", @"");
    }
    else
    {
        if ([appInfo.price isEqualToString:@"0"])
        {
            title = LocalizedString(@"free", @"");
        }
        else
        {
            title = appInfo.price;
        }
    }
    
    CGSize size = getTextLabelRectWithContentAndFont(title, [UIFont fontWithName:FONTNAMESTRING size:18]).size;
    [cell.installBtn setFrame:CGRectMake(320 - size.width - 20, cell.installBtn.frame.origin.y, size.width, 26)];
    [cell.installBtn setTitle:title forState:UIControlStateNormal];
    
    cell.appInfo = appInfo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ME_AppInfo *appInfo = [[(SCAppDelegate *)[[UIApplication sharedApplication] delegate] moreAPPSArray] objectAtIndex:indexPath.row];
    [self event:@"home" label:[NSString stringWithFormat:@"homeMoreApp_%d",appInfo.appId]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:appInfo.openUrl]])
    {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appInfo.openUrl]];
    }
    else
    {
        [self jumpAppStore:appInfo.downUrl];
    }
}

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)jumpAppStore:(NSString *)appid
{
    NSString *evaluateString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@",appid];
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:evaluateString]];
}

#pragma mark -
#pragma mark WebRequestDelegate
- (void)didReceivedData:(NSDictionary *)dic withTag:(NSInteger)tag
{
    SCAppDelegate *app = (SCAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    NSArray *infoArray = [dic objectForKey:@"list"];
    NSMutableArray *sqlArray = [[NSMutableArray alloc]init];

    for (NSMutableDictionary *infoDic in infoArray)
    {
        ME_AppInfo *appInfo = [[ME_AppInfo alloc]initWithDictionary:infoDic];
        [sqlArray addObject:appInfo];
    }
    
    //判断是否有新应用
    [PRJ_SQLiteMassager shareStance].tableType = AppInfo;
    NSMutableArray *dataArray = [[PRJ_SQLiteMassager shareStance] getAllAppsInfoData];
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
    [[PRJ_SQLiteMassager shareStance] deleteAllAppInfoData];
    [[PRJ_SQLiteMassager shareStance] insertAppInfo:sqlArray];
    
    app.moreAPPSArray = changeMoreTurnArray(app.moreAPPSArray);
    
    [appInfoTableView reloadData];
    hideMBProgressHUD();
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
    
    //Flurry
    [Flurry logEvent:eventID];
}

@end

