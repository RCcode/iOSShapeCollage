//
//  RC_ShareTableViewCell.m
//  IOSMirror
//
//  Created by gaoluyangrc on 14-10-17.
//  Copyright (c) 2014年 rcplatformhk. All rights reserved.
//

#import "RC_ShareTableViewCell.h"
#import "CMethods.h"

@implementation RC_ShareTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier withCellHeight:(float)height
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self)
    {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, height);
        
        //底图
        _bottom_view = [[UIView alloc] initWithFrame:CGRectMake(8, 10, 304, height - 20)];
        _bottom_view.backgroundColor = [UIColor whiteColor];
        _bottom_view.layer.cornerRadius = 10.f;
        [self.contentView addSubview:_bottom_view];
        
        //背景
        _back_view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 288,  252 )];
        if (iPhone5)
        {
            _back_view.frame = CGRectMake(0, 0, 288, 280);
        }
        [_bottom_view addSubview:_back_view];
        _back_view.center = CGPointMake(_bottom_view.frame.size.width/2.f, _bottom_view.frame.size.height/2.f);
        
        //logo
        _app_logo_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 70, 70)];
        [_back_view addSubview:_app_logo_imageView];
        
        //应用名称
        _app_title_label = [[UILabel alloc] initWithFrame:CGRectMake(90, 0, 180, 40)];
        _app_title_label.font = [UIFont boldSystemFontOfSize:20.f];
        [_back_view addSubview:_app_title_label];
        
        //应用描述
        _app_detail_label = [[UILabel alloc] initWithFrame:CGRectMake(90, 20, 180, 50)];
        _app_detail_label.font = [UIFont systemFontOfSize:14.f];
        _app_detail_label.numberOfLines = 0;
        _app_detail_label.lineBreakMode = NSLineBreakByWordWrapping;
        [_back_view addSubview:_app_detail_label];
        
        //宣传图
        _app_bander_imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0,  75, 288, 177)];
        if (iPhone5)
        {
            _app_bander_imageView.frame = CGRectMake(0, 103, 288, 177);
        }
        _app_bander_imageView.contentMode = UIViewContentModeScaleAspectFit;
        [_back_view addSubview:_app_bander_imageView];
    }
    
    return self;
}

- (void)awakeFromNib
{
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
