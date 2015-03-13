//
//  CommentTableViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "CommentTableViewCell.h"
#import "SRStylesheet.h"
@implementation CommentTableViewCell

- (void)awakeFromNib {
    // Initialization code
    
    self.avatarImageView.clipsToBounds = YES;
    self.avatarImageView.layer.cornerRadius = 25;
    self.avatarImageView.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.avatarImageView.layer.borderWidth = 1.0;
    self.userNameLabel.textColor = [SRStylesheet mainColor];
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
