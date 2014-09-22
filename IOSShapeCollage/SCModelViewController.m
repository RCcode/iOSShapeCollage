//
//  SCModelViewController.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCModelViewController.h"
#import "MHImagePickerMutilSelector.h"
#import "SCEditViewController.h"

@interface SCModelViewController ()

@end

@implementation SCModelViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    modelArray = [[NSBundle mainBundle]pathsForResourcesOfType:@"png" inDirectory:@"Type"];
    //
    for (int i = 0; i < [modelArray count]; i ++)
    {
        @autoreleasepool
        {
            UIButton *modelChooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
            int location_x = i%2;
            int location_y = i/2;
            
            modelChooseButton.frame = CGRectMake(5+160*location_x, 160*location_y, 150, 150);
            [modelChooseButton addTarget:self action:@selector(modelChooseButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            modelChooseButton.tag = i+10;
            [modelChooseButton setTitle:[NSString stringWithFormat:@"模板%d",i+1] forState:UIControlStateNormal];
            [modelChooseButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            //            [button setBackgroundImage:[UIImage imageWithContentsOfFile:[modelArray objectAtIndex:i]] forState:UIControlStateNormal];
            [self.view addSubview:modelChooseButton];
        }
        
    }

    // Do any additional setup after loading the view.
}

- (void)modelChooseButtonPressed:(id)sender
{
    UIButton *tempButton = (UIButton *)sender;
    NSString *directory = [[[[[modelArray objectAtIndex:tempButton.tag-10] lastPathComponent] stringByDeletingPathExtension] componentsSeparatedByString:@"_"] objectAtIndex:0];
    
    NSDictionary *infoDic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"%@_profile",directory] ofType:@"plist" inDirectory:directory]];
    
    editControll = [[SCEditViewController alloc]init];
    editControll.backGroundImageView.image = [UIImage imageWithContentsOfFile:[[NSBundle mainBundle] pathForResource:[infoDic objectForKey:@"backGroundImage"] ofType:@"png" inDirectory:directory]];
    [editControll setInfoDictionary:infoDic];
    
    imagePickerMutilSelector=[[MHImagePickerMutilSelector alloc] init];//自动释放
    imagePickerMutilSelector.maxImageCount = [[infoDic objectForKey:@"imageName"]count];
    imagePickerMutilSelector.delegate = self;
    
    UIImagePickerController* picker=[[UIImagePickerController alloc] init];
    picker.delegate = imagePickerMutilSelector;//将UIImagePi cker的代理指向
    [picker setAllowsEditing:NO];
    picker.sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
    picker.modalTransitionStyle= UIModalTransitionStyleCoverVertical;
    picker.navigationController.delegate=imagePickerMutilSelector;//将UIImagePicker的导航代理指向到imagePickerMutilSelector
    
    imagePickerMutilSelector.imagePicker=picker;//使imagePickerMutilSelector得知其控制的UIImagePicker实例，为释放时需要。
    
    //    [self.navigationController pushViewController:picker animated:YES];
    [self presentViewController:picker animated:YES completion:nil];
}

-(void)imagePickerMutilSelectorDidGetImages:(NSArray *)imageArray
{
    [editControll setEditImageArray:imageArray];
    
    UINavigationController *presentNav = [[UINavigationController alloc]initWithRootViewController:editControll];
    presentNav.navigationBar.translucent = NO;
    [self presentViewController:presentNav animated:YES completion:nil];
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
