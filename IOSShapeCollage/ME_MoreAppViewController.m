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
#import "PRJ_Global.h"
#import "UIImageView+WebCache.h"
#import <StoreKit/StoreKit.h>
#import "PRJ_SQLiteMassager.h"
#import "ME_AppInfo.h"

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

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(updateState) userInfo:nil repeats:YES];
    [_timer fire];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    [_timer invalidate];
    _timer = nil;
}
              
- (void)updateState{
    [appInfoTableView reloadData];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = colorWithHexString(@"#202020");
    
    //初始化导航栏
    [self.navigationController.navigationBar setBarTintColor:colorWithHexString(@"#2d2d2d")];
    self.navigationController.navigationBar.translucent = NO;
    
    CGFloat itemWH = 44;
    UIButton *navBackItem = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, itemWH, itemWH)];
    [navBackItem setImage:pngImagePath(@"share_back") forState:UIControlStateNormal];
    [navBackItem addTarget:self action:@selector(leftItemClick) forControlEvents:UIControlEventTouchUpInside];
    navBackItem.imageView.contentMode = UIViewContentModeCenter;
    navBackItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, itemWH * 0.65);
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navBackItem];
    
    //标题
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 40)];
    titleLabel.text = @"More App";
    titleLabel.font = [UIFont fontWithName:FONTNAMESTRING size:17];
    titleLabel.textColor = colorWithHexString(@"#28d8c9");
    titleLabel.textAlignment = NSTextAlignmentCenter;
    self.navigationItem.titleView = titleLabel;
    
//    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:self action:@selector(leftItemClick)];
//    self.navigationItem.leftBarButtonItem = leftItem;
//    
//    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc]initWithTitle:@"" style:UIBarButtonItemStyleDone target:self action:@selector(rightItemClick)];
//    self.navigationItem.rightBarButtonItem = rightItem;
    
    //判断是否已下载完数据
    if ([PRJ_Global shareStance].appsArray.count == 0)
    {
        //查看数据库中是否存在
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
            [PRJ_Global shareStance].appsArray = [[PRJ_SQLiteMassager shareStance] getAllAppsInfoData];
        }
    }
    
    appInfoTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, 320, self.view.bounds.size.height-44) style:UITableViewStylePlain];
    [appInfoTableView registerNib:[UINib nibWithNibName:@"Me_MoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    appInfoTableView.delegate = self;
    appInfoTableView.dataSource = self;
    appInfoTableView.backgroundColor = [UIColor clearColor];
    appInfoTableView.backgroundView = nil;
    appInfoTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:appInfoTableView];

}

- (void)leftItemClick
{
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
    return [[PRJ_Global shareStance].appsArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Me_MoreTableViewCell *cell = (Me_MoreTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.delegate = self;
    
    ME_AppInfo *appInfo = nil;
    if([PRJ_Global shareStance].appsArray.count > indexPath.row){
        appInfo = [[PRJ_Global shareStance].appsArray objectAtIndex:indexPath.row];
    }
    
    CGSize appNameSize = sizeWithContentAndFont(appInfo.appName, CGSizeMake(150, 80), 14);
    [cell.titleLabel setFrame:CGRectMake(cell.titleLabel.frame.origin.x, cell.titleLabel.frame.origin.y, appNameSize.width, appNameSize.height)];
    cell.titleLabel.text = appInfo.appName;
    cell.typeLabel.text = appInfo.appCate;
    [cell.logoImageView setImageWithURL:[NSURL URLWithString:appInfo.iconUrl] placeholderImage:nil];
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
    
    CGSize size = sizeWithContentAndFont(title, CGSizeMake(120, 26), 18);
    [cell.installBtn setFrame:CGRectMake(320 - size.width - 20, cell.installBtn.frame.origin.y, size.width, 26)];
    [cell.installBtn setTitle:title forState:UIControlStateNormal];
    
    cell.appInfo = appInfo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ME_AppInfo *appInfo = nil;
    if([PRJ_Global shareStance].appsArray.count > indexPath.row){
        appInfo = [[PRJ_Global shareStance].appsArray objectAtIndex:indexPath.row];
    }

    NSString *event = [NSString stringWithFormat:@"home_moreapps_%d", appInfo.appId];
    [PRJ_Global event:event label:@"home_moreapps"];
    
    if (appInfo.isHave)
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
    NSArray *infoArray = [dic objectForKey:@"list"];
    NSMutableArray *isDownArray = [NSMutableArray arrayWithCapacity:0];
    NSMutableArray *noDownArray = [NSMutableArray arrayWithCapacity:0];
    for (NSDictionary *infoDic in infoArray)
    {
        ME_AppInfo *appInfo = [[ME_AppInfo alloc]initWithDictionary:infoDic];
        if (appInfo.isHave)
        {
            [isDownArray addObject:appInfo];
        }
        else
        {
            [noDownArray addObject:appInfo];
        }
    }
    NSMutableArray *dataArray = [NSMutableArray arrayWithCapacity:0];
    [dataArray addObjectsFromArray:noDownArray];
    [dataArray addObjectsFromArray:isDownArray];
    [PRJ_Global shareStance].appsArray = dataArray;
    
    //判断是否有新应用
    if ([PRJ_Global shareStance].appsArray.count > 0) {
        NSMutableArray *dataArray = [[PRJ_SQLiteMassager shareStance] getAllAppsInfoData];
        NSMutableArray *array = [NSMutableArray arrayWithCapacity:0];
        
        for (ME_AppInfo *app in [PRJ_Global shareStance].appsArray)
        {
            BOOL isHave = NO;
            for (ME_AppInfo *appInfo in dataArray)
            {
                if (app.appId == appInfo.appId)
                {
                    isHave = YES;
                }
            }
            if (!isHave) {
                [array addObject:app];
            }
        }
        
        //插入新数据
        if (array.count > 0)
        {
            [PRJ_SQLiteMassager shareStance].tableType = AppInfo;
            [[PRJ_SQLiteMassager shareStance] insertAppInfo:array];
        }
    }
}

- (void)requestFailed:(NSInteger)tag
{
    
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[SDImageCache sharedImageCache] clearMemory];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
