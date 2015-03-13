//
//  CommentTableViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "CommentTableViewCell.h"

@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 25;
    self.avatarImageView.layer.borderColor = [[UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000] CGColor];
    self.avatarImageView.layer.borderWidth = 1.0;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse{
    self.commentBodyLabel.text = @"";
    self.avatarImageView.image = nil;
    self.userNameLabel.text = @"";
}
@end
