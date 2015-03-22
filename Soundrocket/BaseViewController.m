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

-(void)viewDidLoad{
    [super viewDidLoad];
    [self setupLoadingScreen];
    [self setUpRefreshControl];
}

-(void)setupLoadingScreen{
    self.loadingScreen = [[UIView alloc]initWithFrame:self.tableView.frame];
    self.loadingScreen.backgroundColor = [UIColor whiteColor];
    self.activityIndicatorView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.activityIndicatorView.color = [SRStylesheet mainColor];
    self.activityIndicatorView.center = CGPointMake(self.loadingScreen.frame.size.width/2, self.loadingScreen.frame.size.height/2);
    self.activityIndicatorView.tintColor = [SRStylesheet mainColor];
    [self.loadingScreen addSubview:self.activityIndicatorView];
    [self.view addSubview:self.loadingScreen];
    [self.view bringSubviewToFront:self.loadingScreen];
    [self.activityIndicatorView startAnimating];
}

- (void)setUpRefreshControl {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView addSubview:self.refreshControl];
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

-(void)refresh {
    NSAssert(NO, @"Subclasses need to overwrite this method");
}
-(void)showMenu {
    [self presentLeftMenuViewController:nil];
}

-(void)hideLoadingScreen {
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        self.loadingScreen.alpha = 0.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        self.loadingScreen.hidden = YES;
    }];
}

-(void)showLoadingScreen {
    [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
        // Animate the alpha value of your imageView from 1.0 to 0.0 here
        self.loadingScreen.alpha = 1.0f;
    } completion:^(BOOL finished) {
        // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        self.loadingScreen.hidden = NO;
    }];
}
@end
