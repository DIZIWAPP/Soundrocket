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

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    self.miniPlayer.alpha =0.0f;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /* Reorganize views, or move child view controllers */
    } completion:^(id<UIViewControllerTransitionCoordinatorContext> context) {
        /* Do any cleanup, if necessary */
        self.miniPlayer.frame = CGRectMake(0,size.height-50,size.width, 50);
        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.miniPlayer.alpha = 1.0f;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
        }];
    }];
}
#pragma mark RESideMenu Delegate

- (void)sideMenu:(RESideMenu *)sideMenu willShowMenuViewController:(UIViewController *)menuViewController
{
    //NSLog(@"willShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
}

- (void)sideMenu:(RESideMenu *)sideMenu didShowMenuViewController:(UIViewController *)menuViewController
{
    //NSLog(@"didShowMenuViewController: %@", NSStringFromClass([menuViewController class]));
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    Mixpanel * mixpanel = [Mixpanel sharedInstance];
    // Checking how often the sidebar is being used
    [mixpanel track:@"sidebar_menu_selected" properties:@{@"username":delegate.currentUser.username}];
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
