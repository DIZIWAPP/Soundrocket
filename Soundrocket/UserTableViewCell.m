//
//  UserTableViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "UserTableViewCell.h"
#import "SRStylesheet.h"
#import <FAKIonIcons.h>
#import <UIImageView+AFNetworking.h>
@implementation UserTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 25;
    self.userImageView.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.userImageView.layer.borderWidth = 1.0;
    self.userNameAndCoutryLabel.textColor = [SRStylesheet mainColor];

}


-(void)setUser:(User *)user {
    _user = user;
    [self setupDataWithUser:user];
}

-(void)setupDataWithUser:(User*)user {
    if (user.country) {
        self.userNameAndCoutryLabel.text = [NSString stringWithFormat:@"%@,%@",user.username,user.country];
    } else {
        self.userNameAndCoutryLabel.text = [NSString stringWithFormat:@"%@",user.username];
    }
    
    FAKIonIcons *soundsIcon = [FAKIonIcons podiumIconWithSize:10];
    NSMutableAttributedString * soundsCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",user.track_count]];
    [soundsCount appendAttributedString:[soundsIcon attributedString]];
    // Number of Followers label
    FAKIonIcons *followersIcon = [FAKIonIcons personStalkerIconWithSize:10];
    NSMutableAttributedString * followersCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",user.followers_count]];
    [followersCount appendAttributedString:[followersIcon attributedString]];
    NSAttributedString * spacer = [[NSMutableAttributedString alloc]initWithString:@"    " attributes:nil];
    [followersCount appendAttributedString:spacer];
    [followersCount appendAttributedString:soundsCount];
    self.numberOfSoundsLabel.attributedText = followersCount;
    
    [self.userImageView setImageWithURL:[NSURL URLWithString:user.avatar_url] placeholderImage:nil];
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
