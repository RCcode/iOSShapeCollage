//
//  SCShareViewController.h
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-10.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SLComposeViewController;

@interface SCShareViewController : UIViewController<UIDocumentInteractionControllerDelegate, UIAlertViewDelegate,UITableViewDataSource,UITableViewDelegate,UIPageViewControllerDelegate>
{
    UIDocumentInteractionController *_documetnInteractionController;
    UIImage *theBestImage;
    UIImage *saveImage;
    SLComposeViewController *slComposerSheet;
    BOOL isSaved;
    
    NSArray *cellTitleArray;
    NSArray *cellImagesArray;
    UITableView *appMoretableView;
    
    UIView *saveView;
    CGAffineTransform originTransform;
}

@property (nonatomic) BOOL isSaved;
- (void)getImage:(UIImage *)image;
- (void)getImageFromView:(UIView *)tempView;
@end
