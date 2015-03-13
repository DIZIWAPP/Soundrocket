//
//  UserTableViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "UserTableViewCell.h"
#import "SRStylesheet.h"
@implementation UserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 25;
    self.userImageView.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.userImageView.layer.borderWidth = 1.0;
    self.userNameAndCoutryLabel.textColor = [SRStylesheet mainColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse {
    self.userNameAndCoutryLabel.text = @"";
    [self.userImageView setImage:nil];
}

@end
