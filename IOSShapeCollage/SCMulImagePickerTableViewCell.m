//
//  SCMulImagePickerTableViewCell.m
//  IOSShapeCollage
//
//  Created by wsq-wlq on 14-9-25.
//  Copyright (c) 2014年 wsq-wlq. All rights reserved.
//

#import "SCMulImagePickerTableViewCell.h"

@implementation SCMulImagePickerTableViewCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    
    self.imageView.bounds =CGRectMake(0,0,77,77);
    
    self.imageView.frame =CGRectMake(10,0,77,77);
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.imageView.center = CGPointMake(self.imageView.center.x, self.frame.size.height/2);
    
    
    CGRect tmpFrame = self.textLabel.frame;
    
    tmpFrame.origin.x = self.imageView.frame.origin.x+self.imageView.frame.size.width+10;
    
    self.textLabel.frame = tmpFrame;
    
    
    
    tmpFrame = self.detailTextLabel.frame;
    
    tmpFrame.origin.x = self.imageView.frame.origin.x+self.imageView.frame.size.width+10;
    
    self.detailTextLabel.frame = tmpFrame;
    
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
