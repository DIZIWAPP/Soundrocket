//
//  UsersListTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 27.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UsersListTableViewController : UITableViewController
@property (nonatomic,strong) NSURL * followingOrFollowersURL;
@property (nonatomic) BOOL following;
@end
