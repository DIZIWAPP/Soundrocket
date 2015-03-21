//
//  PlaylistTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "CreatePlaylistTableTableViewController.h"
@interface PlaylistTableViewController : BaseViewController <CreatePlaylistDelegateProtocoll,UITableViewDataSource,UITabBarControllerDelegate>
-(void)playlistCreated;
@end
