//
//  LikesTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKIonIcons.h>
#import "LikesTableViewController.h"
#import "BasicTrackTableViewCell.h"
#import "CredentialStore.h"
#import "SoundtraceClient.h"
#import "AppDelegate.h"
#import "Track.h"
#import <RESideMenu.h>
#import"UIImageView+AFNetworking.h"
#import "URLParser.h"
#import "LoadMoreTableViewCell.h"
#import <TSMessage.h>
#import "UserTableViewController.h"
#import "SRStylesheet.h"
@interface LikesTableViewController () <BasicTrackTableViewCellDelegate>
@property (nonatomic,strong) NSMutableArray * tracks;
@property (nonatomic,strong) CredentialStore * store;
@property (nonatomic,strong) UIActivityIndicatorView * activityIndicator;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;
@property (nonatomic,strong) UIRefreshControl * refreshControl;


@end

@implementation LikesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupPagination];
    [self setup];
    [self setUpRefreshControl];
    [self fetchForLikesAndShowLoadingScreen:YES];
}

-(void)setup{
    
    [self.navigationItem setTitle:@"Likes"];
    [self setshowMenuButton];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];
    self.store = [[CredentialStore alloc]init];
    self.tracks = [[NSMutableArray alloc]init];
}

-(void)setupPagination {
    self.offset = @0;
    self.limit = @20;
    self.isLoading = NO;
    self.itemsAvailable = YES;
}

/**
 *  Sets up Refresh Controler and Selector calls specific selector
 */
- (void)setUpRefreshControl {
    UIRefreshControl *refresh = [[UIRefreshControl alloc] init];
    [refresh addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refresh;
    [self.tableView addSubview:self.refreshControl];
}
/**
 *  Reinits every Pagination Parameter and then fetches Tracks
 */
- (void)refresh {
    if (!self.isLoading) {
        self.offset = @0;
        self.view.userInteractionEnabled = NO;
        [self.tracks removeAllObjects];
        [self fetchForLikesAndShowLoadingScreen:NO];
    }
}



-(void)fetchForLikesAndShowLoadingScreen:(BOOL)showLoadingScreen {
    if (showLoadingScreen) {
        [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
            // Animate the alpha value of your imageView from 1.0 to 0.0 here
            self.loadingScreen.alpha = 1.0f;
        } completion:^(BOOL finished) {
            // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
            self.loadingScreen.hidden = NO;
        }];
    }
    
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AppDelegate * delegate = (AppDelegate*) [[UIApplication sharedApplication]delegate];
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/favorites.json",delegate.currentUser.id] parameters:paramters
    success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         
         if ([responseObject count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }
         // Save next url
         self.view.userInteractionEnabled = YES;
         
         for (NSDictionary * trackInfo in responseObject) {
             [self.tracks addObject:[[Track alloc] initWithDictionary:trackInfo error:nil]];
         }
         
         long offset = [self.offset integerValue] + [self.limit integerValue];
         self.offset = [NSNumber numberWithLong:offset];
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
         [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
             // Animate the alpha value of your imageView from 1.0 to 0.0 here
             self.loadingScreen.alpha = 0.0f;
         } completion:^(BOOL finished) {
             // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
             self.loadingScreen.hidden = YES;
         }];
         
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         [UIView animateWithDuration:0.5 delay:0.0 options:0 animations:^{
             // Animate the alpha value of your imageView from 1.0 to 0.0 here
             self.loadingScreen.alpha = 0.0f;
         } completion:^(BOOL finished) {
             // Once the animation is completed and the alpha has gone to 0.0, hide the view for good
             self.loadingScreen.hidden = YES;
         }];

     }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.tracks count]+2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.tracks count]) {
        BasicTrackTableViewCell *cell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        Track * track = [self.tracks objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.data = track;
        return  cell;
        
    }
    
    else if (indexPath.row >= [self.tracks count]) {
        if (indexPath.row == ([self.tracks count])) {
            LoadMoreTableViewCell *loadmoreCell = (LoadMoreTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"loadmorecell" forIndexPath:indexPath];
            [loadmoreCell.loadingIndicator stopAnimating];
            loadmoreCell.userInteractionEnabled = NO;
            return  loadmoreCell;
        }
        
    }
    
    UITableViewCell *cell = [[UITableViewCell alloc]init];
    cell.userInteractionEnabled = NO;
    return cell;

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    if (indexPath.row < [self.tracks count]) {
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        Track * track = [self.tracks objectAtIndex:indexPath.row];
        if (track.streamable) {
            delegate.upNext = [self.tracks mutableCopy];
            [delegate setupPlayerWithtrack:[self.tracks objectAtIndex:indexPath.row]];
            [delegate setPlayingIndex:indexPath];
        } else {
            [TSMessage showNotificationWithTitle:@"This track is not streamable" type:TSMessageNotificationTypeError];
        }

    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        if(!self.isLoading) {
            if (self.itemsAvailable) {
                LoadMoreTableViewCell * lmc = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self.tracks count] inSection:0]];
                [lmc.loadingIndicator startAnimating];
                [self fetchForLikesAndShowLoadingScreen:NO];
            }
        }
    }
}

#pragma mark - BasictracktableViewCellDelegate
-(void)userButtonPressedWithUserID:(NSNumber *)user_id{
    UserTableViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"user"];
    controller.user_id = user_id;
    [self.navigationController pushViewController:controller animated:YES];
}


@end
