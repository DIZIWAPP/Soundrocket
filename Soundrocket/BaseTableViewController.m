//
//  BaseTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 27.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "BaseTableViewController.h"
#import "AppDelegate.h"
#import <FAKIonIcons.h>
#import <RESideMenu.h>
#import <Mixpanel.h>
@interface BaseTableViewController ()
@property(nonatomic) CGFloat duration;
@end

@implementation BaseTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.duration = 0.5;
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setshowMenuButton {
    FAKIonIcons *cogIcon = [FAKIonIcons naviconIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showMenu)];
}

-(void)showMenu {
    [self presentLeftMenuViewController:nil];
}

@end
