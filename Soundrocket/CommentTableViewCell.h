//
//  CommentTableViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel.h>
@interface CommentTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet  MarqueeLabel * commentBodyLabel;
@property (nonatomic,strong) IBOutlet UIImageView * avatarImageView;
@property (nonatomic,strong) IBOutlet UILabel * userNameLabel;
@property (nonatomic,strong) IBOutlet UILabel * timestampLabel;
@end
