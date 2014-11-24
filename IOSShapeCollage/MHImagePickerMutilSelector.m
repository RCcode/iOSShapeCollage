//
//  MHMutilImagePickerViewController.m
//  doujiazi
//
//  Created by Shine.Yuan on 12-8-7.
//  Copyright (c) 2012年 mooho.inc. All rights reserved.
//

#import "MHImagePickerMutilSelector.h"
#import <QuartzCore/QuartzCore.h>
#import "UIImage+SubImage.h"


@interface MHImagePickerMutilSelector ()

@end

@implementation MHImagePickerMutilSelector

@synthesize imagePicker;
@synthesize delegate;
@synthesize maxImageCount;
@synthesize tempController;

- (id)init
{
    self = [super init];
    if (self)
    {
        // Custom initialization
        pics=[[NSMutableArray alloc] init];
        //[pics addObject:@""];
        [self.view setBackgroundColor:[UIColor blackColor]];
    }
    return self;
}

+(id)standardSelector
{
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor blackColor];
}

-(void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    viewController.navigationItem.leftBarButtonItem = nil;
    viewController.navigationItem.rightBarButtonItem = nil;
    viewController.title = @"Gallery";
    [navigationController.navigationBar setBarTintColor:colorWithHexString(@"#2d2d2d")];
    navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: colorWithHexString(@"#28d8c9"),NSFontAttributeName:[UIFont fontWithName:FONTNAMESTRING size:17]};
    tempController = viewController;
    
    if (navigationController.viewControllers.count > 0)
    {
        if ([viewController.view.subviews.firstObject isKindOfClass:[UITableView class]])
        {
            isGroup = YES;
            
            viewController.navigationItem.rightBarButtonItem = nil;
            UIButton *leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftItemButton setFrame:CGRectMake(0, 0, 30, 30)];
            [leftItemButton setImage:[UIImage imageNamed:@"gallery_back"] forState:UIControlStateNormal];
            [leftItemButton addTarget:self action:@selector(leftItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            leftItemButton.imageView.contentMode = UIViewContentModeLeft;
            
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -15;
            
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftItemButton];
            viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,leftItem, nil];

        }
        if ([viewController.view.subviews.firstObject isKindOfClass:[UICollectionView class]])
        {
            isGroup = NO;
            
            viewController.navigationItem.rightBarButtonItem = nil;
            UIButton *leftItemButton = [UIButton buttonWithType:UIButtonTypeCustom];
            [leftItemButton setFrame:CGRectMake(0, 0, 30, 30)];
            [leftItemButton setImage:[UIImage imageNamed:@"gallery_back"] forState:UIControlStateNormal];
            [leftItemButton addTarget:self action:@selector(leftItemButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            leftItemButton.imageView.contentMode = UIViewContentModeCenter;
            
            UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                               initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                               target:nil action:nil];
            negativeSpacer.width = -15;
            
            UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithCustomView:leftItemButton];
            viewController.navigationItem.leftBarButtonItems = [NSArray arrayWithObjects:negativeSpacer,leftItem, nil];
        }
        
        selectedPan=[[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-135, 320, 135)];
        selectedPan.backgroundColor = colorWithHexString(@"#2d2d2d");
        
        textlabel=[[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, 44)];
        [textlabel setBackgroundColor:[UIColor clearColor]];
        [textlabel setFont:[UIFont fontWithName:FONTNAMESTRING size:14]];
        [textlabel setTextColor:[UIColor whiteColor]];
        [textlabel setText:[NSString stringWithFormat:@"%lu/%ld",(unsigned long)pics.count,(long)maxImageCount]];
        [selectedPan addSubview:textlabel];
        
        btn_done=[UIButton buttonWithType:UIButtonTypeCustom];
        btn_done.frame = CGRectMake(self.view.frame.size.width-60-10, 0, 60, 30);
        btn_done.center = CGPointMake(btn_done.center.x, textlabel.center.y);
        [btn_done setBackgroundImage:[UIImage imageNamed:@"gallery_OK_not-available"] forState:UIControlStateNormal];
        [btn_done setBackgroundImage:[UIImage imageNamed:@"gallery_OK"] forState:UIControlStateSelected];
        [btn_done addTarget:self action:@selector(doneHandler) forControlEvents:UIControlEventTouchUpInside];
        [selectedPan addSubview:btn_done];
        
        
        tbv=[[UITableView alloc] initWithFrame:CGRectMake(0, 50, 90, 320) style:UITableViewStylePlain];
        tbv.transform=CGAffineTransformMakeRotation(M_PI * -90 / 180);
        tbv.center=CGPointMake(160, 131-90/2);
        [tbv setRowHeight:100];
        [tbv setShowsVerticalScrollIndicator:NO];
        [tbv setPagingEnabled:YES];
        
        tbv.dataSource=self;
        tbv.delegate=self;
        
        //[tbv setContentInset:UIEdgeInsetsMake(10, 0, 0, 0)];
        
        [tbv setBackgroundColor:[UIColor clearColor]];
        [tbv setBackgroundView:nil];
        
        [tbv setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
        [selectedPan addSubview:tbv];
        
        [viewController.navigationController.view addSubview:selectedPan];
    }else{
        [pics removeAllObjects];
        
    }
}
- (void)leftItemButtonPressed:(id)sender
{
    if (isGroup)
    {
        [tempController dismissViewControllerAnimated:YES completion:nil];
    }
    else
    {
        [tempController.navigationController popViewControllerAnimated:YES];
    }
}

-(void)doneHandler
{
    if (pics.count == maxImageCount)
    {
        [self close];
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"请选择%ld张图片",(long)maxImageCount] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
    }
    
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return maxImageCount;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    
    NSInteger row=indexPath.row;

        if (cell==nil)
        {
            cell=[[UITableViewCell alloc] initWithFrame:CGRectZero];
            cell.selectionStyle=UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            UIView* rotateView=[[UIView alloc] initWithFrame:CGRectMake(10, 0, 80 , 80)];
            [rotateView setBackgroundColor:[UIColor clearColor]];
            rotateView.transform=CGAffineTransformMakeRotation(M_PI * 90 / 180);
            rotateView.center=CGPointMake(45, 45);
            [cell.contentView addSubview:rotateView];
            
            UIImageView* imv=[[UIImageView alloc] init];
            [imv setFrame:CGRectMake(10, 0, 80, 80)];
            imv.tag = indexPath.row+10;
            [imv setClipsToBounds:YES];
            [imv setContentMode:UIViewContentModeScaleAspectFill];
            
            [imv.layer setBorderColor:colorWithHexString(@"#28d8c9").CGColor];
            [imv.layer setBorderWidth:2.0f];
            [rotateView addSubview:imv];
            
        }
        if (pics.count > 0)
        {
            if (indexPath.row < pics.count)
            {
                UIImageView *tempImageView = (UIImageView *)[cell viewWithTag:indexPath.row+10];
                tempImageView.userInteractionEnabled = YES;
                tempImageView.contentMode = UIViewContentModeScaleAspectFill;
                tempImageView.image = [pics objectAtIndex:indexPath.row];
                
                UIButton*   btn_delete=[UIButton buttonWithType:UIButtonTypeRoundedRect];
                [btn_delete setFrame:CGRectMake(tempImageView.frame.size.width-15, 5, 30, 30)];
                [btn_delete setBackgroundImage:[UIImage imageNamed:@"gallery_cancel"] forState:UIControlStateNormal];
//                [btn_delete setTitle:@"删除" forState:UIControlStateNormal];
//                btn_delete.titleLabel.font = [UIFont fontWithName:@"Arial" size:10];
                [btn_delete addTarget:self action:@selector(deletePicHandler:) forControlEvents:UIControlEventTouchUpInside];
                [btn_delete setTag:row];
                
                [cell addSubview:btn_delete];
            }
            
        }    
    return cell;
}

-(void)deletePicHandler:(UIButton*)btn
{
    [pics removeObjectAtIndex:btn.tag];
    [btn removeFromSuperview];
    [self updateTableView];
}

-(void)updateTableView
{
    textlabel.text=[NSString stringWithFormat:@"%lu/%ld",(unsigned long)pics.count,(long)maxImageCount];
    if (pics.count == maxImageCount)
    {
        btn_done.selected = YES;
    }
    if (pics.count < maxImageCount)
    {
        btn_done.selected = NO;
    }
    [tbv reloadData];
    
    if (pics.count>3) {
        CGFloat offsetY=tbv.contentSize.height-tbv.frame.size.height-(320-90);
        [tbv setContentOffset:CGPointMake(0, offsetY) animated:YES];
    }else{
        [tbv setContentOffset:CGPointMake(0, 0) animated:YES];
    }
    
}

//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo
//{
//    //[btn_addCover.imageView setImage:image forState:UIControlStateNormal];
//    
//    //[picker dismissModalViewControllerAnimated:YES];
//    if (pics.count>=10) {
//        return;
//    }
//    
//    image = [image rescaleImageToPX:320 * 1.4];
//    
//    if (pics.count == maxImageCount)
//    {
//        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%d张图片",maxImageCount] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//        
//        [alert show];
//
//    }
//    else
//    {
//        [pics addObject:image];
//        [self updateTableView];
//    }
//}

-(void)getChoosePhoto:(UIImage *)image
{
    NSLog(@"原图");
    image = [image rescaleImageToPX:1200];
    NSLog(@"压缩图");
    if (pics.count == maxImageCount)
    {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示" message:[NSString stringWithFormat:@"最多选择%d张图片",maxImageCount] delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        
        [alert show];
        
    }
    else
    {
        [pics addObject:image];
        [self updateTableView];
    }
}

- (void)getChoosePhotoURL:(NSURL *)url
{
//    UIImage *image = [UIImage imageWith]
}


-(void)close
{
    [tempController dismissViewControllerAnimated:YES completion:^
    {
        if (delegate && [delegate respondsToSelector:@selector(imagePickerMutilSelectorDidGetImages:)])
        {
            [delegate performSelector:@selector(imagePickerMutilSelectorDidGetImages:) withObject:pics];
        }

    }];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    photoGroupTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height-135) style:UITableViewStylePlain];
//    photoGroupTable.delegate = self;
//    photoGroupTable.dataSource = self;
//    photoGroupTable.backgroundColor = colorWithHexString(@"#202020");
//    photoGroupTable.tag = 100;
//    [photoGroupTable setRowHeight:100];
//    [photoGroupTable setShowsVerticalScrollIndicator:NO];
//    [photoGroupTable setPagingEnabled:YES];
//    [self.view addSubview:photoGroupTable];
    
	// Do any additional setup after loading the view.
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}
//
//-(void)dealloc
//{
//    delegate=nil;
//    imagePicker=nil;
//    [super dealloc];
//}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
