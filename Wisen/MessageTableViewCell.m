//
//  MessageTableViewCell.m
//  
//
//  Created by Yihe Li on 2/28/15.
//
//

#import "MessageTableViewCell.h"

@implementation MessageTableViewCell

- (void)awakeFromNib
{
    self.bubbleView.layer.cornerRadius = 10;
}

- (void)layoutSubviews
{
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = CGRectGetHeight(self.avatarImageView.frame) / 2;
}

@end
