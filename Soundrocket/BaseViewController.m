//
//  BaseViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 17.03.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "BaseViewController.h"
#import <FAKIonIcons.h>
#import <RESideMenu.h>
#import "SRStylesheet.h"

@implementation BaseViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self setupLoadingScreen];
}

-(void)setupLoadingScreen{
    self.loadingScreen = [[UIView alloc]initWithFrame:self.view.bounds];
    self.loadingScreen.backgroundColor = [UIColor whiteColor];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicatorView.color = [SRStylesheet mainColor];
    self.activityIndicatorView.center = self.loadingScreen.center;
    self.activityIndicatorView.tintColor = [SRStylesheet mainColor];
    [self.loadingScreen addSubview:self.activityIndicatorView];
    [self.view addSubview:self.loadingScreen];
    [self.view bringSubviewToFront:self.loadingScreen];
    [self.activityIndicatorView startAnimating];
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
