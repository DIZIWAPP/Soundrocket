//
//  RootViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "RootViewController.h"
#import "PlayerViewController.h"
#import "AppDelegate.h"
@interface RootViewController ()
@property (nonatomic,strong) UINavigationController * playerWrappingController;
@end

@implementation RootViewController

- (void)awakeFromNib
{

    self.delegate = self; // RESIDEMENU DELEGATE
    [self setupControllers];
    [self setupResideMenu];
    [self setupPlayer];
    [self setupMiniPlayer];
}



-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];

    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UINavigationController * tipsController = [storyBoard instantiateViewControllerWithIdentifier:@"IntroNav"];
        [self presentViewController:tipsController animated:YES completion:nil];
        // This is the first launch ever
        
    }
}

#pragma mark - Setup Methods
-(void)setupControllers{
    UINavigationController * controller = [self.storyboard instantiateViewControllerWithIdentifier:@"ContentNavigationController"];
    self.contentViewController = controller;
    self.leftMenuViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"MenuTableViewController"];
}

-(void)setupResideMenu {
    
    self.contentViewShadowEnabled = NO;
    self.fadeMenuView = NO;
    self.scaleMenuView = NO;
    self.scaleContentView = YES;
    self.scaleBackgroundImageView = NO;
    self.parallaxEnabled = NO;
    self.contentViewScaleValue = 0.9;
}

-(void)setupPlayer {
    // Create Navigation Controller and embed Playerviewcontroller inside
    self.playerWrappingController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlayerNavigationController"];
    [self.playerWrappingController.navigationBar setBackgroundImage:[UIImage new]
                                                      forBarMetrics:UIBarMetricsDefault];
    self.playerWrappingController.navigationBar.shadowImage = [UIImage new];
    self.playerWrappingController.navigationBar.translucent = YES;
    
    PlayerViewController * player =  [self.storyboard instantiateViewControllerWithIdentifier:@"Player"];
    [player view]; // Create the view before being dsiplayed
    [self.playerWrappingController setViewControllers:@[player]];
    
    // Set player inside delegate
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    delegate.player = player;
    
}
-(void)setupMiniPlayer {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    self.miniPlayer = [[[NSBundle mainBundle] loadNibNamed:@"MiniPlayer" owner:self options:nil] objectAtIndex:0];
    self.miniPlayer.frame = CGRectMake(0,self.view.frame.size.height,self.view.frame.size.width, 50);
    
    // Adds Tap gesture to Miniplayer
    UITapGestureRecognizer * gestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(miniPlayerPressed:)];
    [self.miniPlayer addGestureRecognizer:gestureRecognizer];
    
    delegate.miniPlayer = self.miniPlayer;
    
    // Adds miniplayer to RESIDEMenu
    [self.view addSubview:self.miniPlayer];
    [self.view bringSubviewToFront:self.miniPlayer];
}


-(void)miniPlayerPressed:(id)sender {
    
    if (!self.playerWrappingController) {
        
        [self setupPlayer];
    }
    
    [self presentViewController:self.playerWrappingController animated:YES completion:nil];
}


#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    //NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    //NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu willHideMenuViewController:(UIViewController *)menuViewController
{
    //NSLog(@"willHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didHideMenuViewController:(UIViewController *)menuViewController
{
    //NSLog(@"didHideMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

@end
