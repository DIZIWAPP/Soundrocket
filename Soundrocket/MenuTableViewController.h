//
//  MenuTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UIButton *userImageView;
@property (weak, nonatomic) IBOutlet UILabel *streamIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesIConlabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutIconLabel;
@property (weak, nonatomic) IBOutlet UILabel *streamTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *likesTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *playlistsTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *aboutTextLabel;
@property (weak, nonatomic) IBOutlet UILabel *logoutTextLabel;
@end
