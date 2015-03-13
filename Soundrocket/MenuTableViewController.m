//
//  MenuTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "MenuTableViewController.h"
#import <RESideMenu/RESideMenu.h>
#import"UIImageView+AFNetworking.h"
#import "ActivitiesTableViewController.h"
#import "LikesTableViewController.h"
#import "PlaylistTableViewController.h"
#import "SearchTableViewController.h"
#import "AboutTableViewController.h"
#import "AppDelegate.h"
#import "LoginTableViewController.h"
#import "SoundtraceClient.h"
#import "UserTableViewController.h"
#import "CredentialStore.h"
#import "User.h"
#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <FAKFoundationIcons.h>
#import "SRStylesheet.h"

@interface MenuTableViewController ()
@property (nonatomic,strong) CredentialStore *store;
@property (nonatomic,strong) User * currentUser;
@property (nonatomic,strong) NSIndexPath * selectedMenuPoint;
@end

@implementation MenuTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.store = [[CredentialStore alloc]init];
    
    [self setupAvatarImage];
    [self setupIcons];
    [self setupMenu];
    [self setupMenuPoints];
    
}


-(void)setupMenu{
    if (self.selectedMenuPoint) {
        if (self.selectedMenuPoint.row == -1) {
            self.userImageView.layer.borderColor = [[SRStylesheet mainColor]CGColor];
        } else {
            [self.tableView selectRowAtIndexPath:self.selectedMenuPoint animated:YES scrollPosition:UITableViewScrollPositionNone];
        }
    } else {
        [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
    }
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    [self setupMenu];
}

-(void)setupMenuPoints{
   
     NSDictionary *attributes = @{
       NSForegroundColorAttributeName : [SRStylesheet darkGrayColor],
       };
    
    self.streamTextLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Stream" attributes:attributes];
    self.likesTextLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Likes" attributes:attributes];
    self.playlistsTextLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Playlists" attributes:attributes];
    self.searchTextLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Search" attributes:attributes];
    self.aboutTextLabel.attributedText = [[NSAttributedString alloc]initWithString:@"About" attributes:attributes];
    self.logoutTextLabel.attributedText = [[NSAttributedString alloc]initWithString:@"Logout" attributes:attributes];

    
}
-(void)setupIcons {
    NSInteger iconSize = 15;
    self.streamIconLabel.attributedText = [[FAKIonIcons ios7CloudIconWithSize:iconSize]attributedString];
    self.likesIConlabel.attributedText = [[FAKIonIcons ios7HeartIconWithSize:iconSize]attributedString];
    self.playlistIconLabel.attributedText = [[FAKIonIcons ios7AlbumsIconWithSize:iconSize]attributedString];
    self.searchIconLabel.attributedText=[[FAKIonIcons searchIconWithSize:iconSize]attributedString];
    self.aboutIconLabel.attributedText=[[FAKIonIcons ios7InformationIconWithSize:iconSize]attributedString];
    self.logoutIconLabel.attributedText=[[FAKIonIcons logOutIconWithSize:iconSize]attributedString];
    
    self.streamIconLabel.textColor = [SRStylesheet mainColor];
    self.likesIConlabel.textColor = [SRStylesheet mainColor];
    self.playlistIconLabel.textColor = [SRStylesheet mainColor];
    self.searchIconLabel.textColor = [SRStylesheet mainColor];
    self.aboutIconLabel.textColor = [SRStylesheet mainColor];
    self.logoutIconLabel.textColor = [SRStylesheet mainColor];

}

-(void)setupAvatarImage {
    
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 30;
    self.userImageView.layer.borderColor = [[SRStylesheet lightGrayColor]CGColor];
    self.userImageView.layer.borderWidth = 1.0;
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication ]delegate];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
        NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:delegate.currentUser.avatar_url]];
        UIImage * image = [UIImage imageWithData:data];
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self.userImageView setBackgroundImage:image forState:UIControlStateNormal];
        });

    });
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedMenuPoint = indexPath;
    self.userImageView.layer.borderColor = [[SRStylesheet lightGrayColor]CGColor];

    UINavigationController * mainNavigationController = (UINavigationController*)self.sideMenuViewController.contentViewController;
    // Stream
    if (indexPath.row == 0) {
        ActivitiesTableViewController * streamTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Stream"];
        [mainNavigationController setViewControllers:@[streamTableViewController] animated:NO];
        [self.sideMenuViewController hideMenuViewController];

    }
    // Likes
    else if (indexPath.row == 1) {
        LikesTableViewController * likesTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Likes"];
        [mainNavigationController setViewControllers:@[likesTableViewController] animated:NO];
        [self.sideMenuViewController hideMenuViewController];

    }
    // Playlists
    else if (indexPath.row == 2) {
        PlaylistTableViewController * playlistTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Playlist"];
        [mainNavigationController setViewControllers:@[playlistTableViewController] animated:NO];
        [self.sideMenuViewController hideMenuViewController];


    }
    // Search
    else if (indexPath.row == 3) {
        SearchTableViewController * searchTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Search"];
        [mainNavigationController setViewControllers:@[searchTableViewController] animated:NO];
        [self.sideMenuViewController hideMenuViewController];

    }
    // About
    else if (indexPath.row == 4) {
        AboutTableViewController * aboutTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"about"];
        [mainNavigationController setViewControllers:@[aboutTableViewController] animated:NO];
        [self.sideMenuViewController hideMenuViewController];

    }
    // Logout
    else if (indexPath.row == 5) {
        // Do the Logout Stuff
        UITableViewController * loginController = [self.storyboard instantiateViewControllerWithIdentifier:@"Login"];
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        PlayerViewController * player = delegate.player;
        
        NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
        [defaults removeObjectForKey:@"access_token"];
        [defaults synchronize];
        
        [player unsubScribe]; // Dont forget because iOS8 will Crash
        [UIView transitionFromView:delegate.window.rootViewController.view
                            toView:loginController.view
                          duration:0.65f
                           options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve)
                        completion:^(BOOL finished){
                            
                            delegate.window.rootViewController = loginController;
                            delegate.currentUser = nil;
                            // We have to set it to nil cause the player should be destroyed
                            [self.store setAuthToken:nil];
                            delegate.player = nil;
                            delegate.miniPlayer = nil;
                        }];

    }
    
}
- (IBAction)showUserButtonPressed:(id)sender {
    
    self.selectedMenuPoint = [NSIndexPath indexPathForItem:-1 inSection:0];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UINavigationController * mainNavigationController = (UINavigationController*)self.sideMenuViewController.contentViewController;

    UserTableViewController * userTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
    userTableViewController.user_id = delegate.currentUser.id;
    userTableViewController.showMenuButton = YES;
    [mainNavigationController setViewControllers:@[userTableViewController] animated:NO];
    self.userImageView.layer.borderColor = [[SRStylesheet mainColor]CGColor];

    [self.sideMenuViewController hideMenuViewController];
}
@end
