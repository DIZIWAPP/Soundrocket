//
//  CreatePlaylistTableTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Playlist.h"
@protocol CreatePlaylistDelegateProtocoll
-(void)playlistCreated;
@end

@interface CreatePlaylistTableTableViewController : UITableViewController
@property(nonatomic,strong)id<CreatePlaylistDelegateProtocoll> createPlaylistDelegate;
@property (weak, nonatomic) IBOutlet UIButton *createPlaylistButton;
@property (weak, nonatomic) IBOutlet UISwitch *sharingSwitch;
@property (weak, nonatomic) IBOutlet UITextField *nameOfPlaylistTextField;
- (IBAction)createPlaylistButtonPressed:(id)sender;
@property (nonatomic,strong) Playlist * playlist;
@end
