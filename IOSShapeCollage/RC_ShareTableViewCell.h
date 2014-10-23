//
//  RC_ShareTableViewCell.h
//  IOSMirror
//
//  Created by gaoluyangrc on 14-10-17.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RC_ShareTableViewCell : UITableViewCell

@property (nonatomic ,strong) UIView *bottom_view;
@property (nonatomic ,strong) UIImageView *app_logo_imageView;
@property (nonatomic ,strong) UILabel *app_title_label;
@property (nonatomic ,strong) UILabel *app_detail_label;
@property (nonatomic ,strong) UIImageView *app_bander_imageView;
@property (nonatomic ,strong) UIView *back_view;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(float)height;

@end
