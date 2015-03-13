//
//  LikesTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <SWTableViewCell.h>
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
@interface LikesTableViewController ()<SWTableViewCellDelegate>
@property (nonatomic,strong) NSMutableArray * tracks;
@property (nonatomic,strong) CredentialStore * store;
@property (nonatomic,strong) UIActivityIndicatorView * activityIndicator;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;


@end

@implementation LikesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupPagination];
    [self setup];
    [self setUpRefreshControl];
    [self fetchForLikes];
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
}
/**
 *  Reinits every Pagination Parameter and then fetches Tracks
 */
- (void)refresh {
    if (!self.isLoading) {
        self.offset = @0;
        self.view.userInteractionEnabled = NO;
        [self.tracks removeAllObjects];
        [self fetchForLikes];
    }
}



-(void)fetchForLikes {
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
         
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

     }];
}

-(void)showMenu {
    [self presentLeftMenuViewController:nil];
    
}
- (IBAction)showMenuButtonPressed:(id)sender {
    [self showMenu];
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
        // Wenn das item eine Playlist ist dann zeige disclosure Indicator an
        Track * track = [self.tracks objectAtIndex:indexPath.row];
        [cell.repostedImageView setImage:[UIImage imageNamed:@"user"]];
        cell.userNameLabel.text = track.user.username;
        cell.trackNameLabel.text = track.title;
        if (track.artwork_url) {
            [cell.artworkImage setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
        } else {
            [cell.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
        }
        
        FAKIonIcons *starIcon = [FAKIonIcons playIconWithSize:10];
        NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.playback_count]];
        [playbackcount appendAttributedString:[starIcon attributedString]];
        
        
        FAKIonIcons *likeIcon = [FAKIonIcons heartIconWithSize:10];
        NSMutableAttributedString * likecount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.favoritings_count]];
        [likecount appendAttributedString:[likeIcon attributedString]];
        
        FAKIonIcons *commentIcon = [FAKIonIcons chatboxIconWithSize:10];
        NSMutableAttributedString * commentCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.comment_count]];
        [commentCount  appendAttributedString:[commentIcon attributedString]];
        
        
        
        
        [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
        [playbackcount appendAttributedString:likecount];
        [playbackcount appendAttributedString:[[NSAttributedString alloc]initWithString:@"  "]];
        [playbackcount appendAttributedString:commentCount];
        cell.playbackCountLabel.attributedText = playbackcount;
        
        /******************* SHOW USER BUTTON STUFF ****************/
        FAKIonIcons * icon = [FAKIonIcons ios7PersonIconWithSize:30];
        [icon addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                                 whiteColor]];
        cell.delegate = self;
        NSMutableArray * leftUtilityButtons = [NSMutableArray new];
        [leftUtilityButtons sw_addUtilityButtonWithColor:[SRStylesheet lightGrayColor] normalIcon:[icon imageWithSize:CGSizeMake(30, 30)] selectedIcon:nil];
        cell.leftUtilityButtons = leftUtilityButtons;
        /***********************************************************/
        
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
                [self fetchForLikes];
            }
        }
    }
}

#pragma mark - SWTableViewDelegate

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSNumber * idOfUser = @0;
    id currentObject = [self.tracks  objectAtIndex:indexPath.row];
    Track * track = (Track*)currentObject;
    idOfUser = track.user.id;
    
    [cell hideUtilityButtonsAnimated:YES];
    UserTableViewController * userTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
    userTableViewController.user_id = idOfUser;
    userTableViewController.showMenuButton = NO;
    [self.navigationController pushViewController:userTableViewController animated:YES];
}

@end
