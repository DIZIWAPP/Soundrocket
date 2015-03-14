//
//  UserTableViewCell.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <MarqueeLabel.h>
#import <UIKit/UIKit.h>
#import "User.h"
@interface UserTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet MarqueeLabel *userNameAndCoutryLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSoundsLabel;

@property(nonatomic,strong)User * user;
@end
