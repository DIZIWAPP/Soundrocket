//
//  UserTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel.h>
@interface UserTableViewController : UITableViewController
@property (nonatomic,strong) NSNumber* user_id;
@property (weak, nonatomic) IBOutlet UIImageView *userImageView;
@property (weak, nonatomic) IBOutlet MarqueeLabel *UsernameAndCountryLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfSoundsLabel;
@property (weak, nonatomic) IBOutlet UIButton *followingButton;
@property (weak, nonatomic) IBOutlet UILabel *numberOfFollowersLabel;
@property (weak, nonatomic) IBOutlet UIButton *followersButton;
@property (nonatomic,strong) UISegmentedControl * segmentedSearchControl;
@property (nonatomic,assign) BOOL showMenuButton;
@property (weak, nonatomic) IBOutlet UIImageView *imageView_backgroundBlurred;
@end
