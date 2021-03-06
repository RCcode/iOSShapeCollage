//
//  PopUpADView.m
//  iOSFont
//
//  Created by wsq-wlq on 14-10-31.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "PopUpADView.h"
#import "UIImageView+WebCache.h"


@implementation PopUpADView


-(void)awakeFromNib
{
    self.layer.cornerRadius = 10;
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.bannerImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(selectedAction:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self.backView addGestureRecognizer:tap];
}

- (void)setTitleColor:(UIColor *)titleColor
{
    self.nameLabel.textColor = titleColor;
}

- (void)setName:(NSString *)name
{
    self.nameLabel.text = name;
}

- (void)setAppInfo:(ME_AppInfo *)appInfo
{
    _appInfo = appInfo;
    
    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:appInfo.iconUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
    self.name = appInfo.appName;
    self.detail = appInfo.appDesc;
    [self.bannerImageView sd_setImageWithURL:[NSURL URLWithString:appInfo.bannerUrl] placeholderImage:nil options:SDWebImageRetryFailed | SDWebImageLowPriority];
}

- (void)setDetail:(NSString *)detail
{
    NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc] initWithString:detail];
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:3];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [detail length])];
    [self.detailLabel setAttributedText:attributedString];    
}

- (void)setBackViewColor:(UIColor *)backgroundColor
{
    self.backgroundColor = backgroundColor;
}

- (void)selectedAction:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"call" object:self];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
