//
//  LoginTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginTableViewController : UITableViewController
@property (nonatomic,strong)    IBOutlet UITextField * emailTextField;
@property (nonatomic,strong)    IBOutlet UITextField * passWordTextField;
@property (weak, nonatomic)     IBOutlet UIButton *loginButton;
@property (weak, nonatomic)     IBOutlet UIActivityIndicatorView *activityIndicatorLoggingIn;
@property (weak, nonatomic)     IBOutlet UILabel *soundrocketNameLabel;

- (IBAction)loginButtonPressed:(id)sender;

@end
