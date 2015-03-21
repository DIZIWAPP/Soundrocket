//
//  BaseViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 17.03.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController
@property(nonatomic,strong) IBOutlet UITableView * tableView;
@property(nonatomic,strong) UIView * loadingScreen;
@property(nonatomic,strong) UIActivityIndicatorView * activityIndicatorView;
@property(nonatomic,strong) UIRefreshControl * refreshControl;

-(void)setshowMenuButton;
-(void)showLoadingScreen;
-(void)hideLoadingScreen;
@end
