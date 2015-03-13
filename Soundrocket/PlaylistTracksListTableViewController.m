//
//  PlaylistTracksListTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//
#import <MBProgressHUD.h>
#import "PlaylistTracksListTableViewController.h"
#import "CredentialStore.h"
#import "AppDelegate.h"
#import "SoundtraceClient.h"
#import "BasicTrackTableViewCell.h"
#import"UIImageView+AFNetworking.h"
#import <FAKIonIcons.h>
#import "LoadMoreTableViewCell.h"
#import <TSMessage.h>
#import <SVProgressHUD.h>
#import "CreatePlaylistTableTableViewController.h"
#import <SWTableViewCell.h>
#import "UserTableViewController.h"

@interface PlaylistTracksListTableViewController() <SWTableViewCellDelegate>
@property (nonatomic,strong)CredentialStore * store;
@property (nonatomic,strong)NSMutableArray * tracks;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;

@end
@implementation PlaylistTracksListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationItem setTitle:self.currentPlaylist.title];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];
    self.store = [[CredentialStore alloc]init];
    self.tracks = [[NSMutableArray alloc]init];
    [self setupPagination];
    [self setUpRefreshControl];
    [self fetchFortrackofPlaylist];
    [self setupEditButton];
    
}

-(void)setupEditButton{
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if ([delegate.currentUser.id integerValue] == [self.currentPlaylist.user.id integerValue]) {
        UIBarButtonItem * editItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editButtonItemPressed:)];
        self.navigationItem.rightBarButtonItem = editItem;
    }
}

-(void)editButtonItemPressed:(id)sender {
    UINavigationController * wrapper = (UINavigationController*)[[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"createPlaylist"];
    CreatePlaylistTableTableViewController * createController = (CreatePlaylistTableTableViewController*)[[wrapper viewControllers]objectAtIndex:0];
    createController.playlist = self.currentPlaylist;
    [self.navigationController pushViewController:createController animated:YES];
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
        [self fetchFortrackofPlaylist];
    }
}


-(void)fetchFortrackofPlaylist {
    
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    NSString * cuttedUrl = nil;
    cuttedUrl = self.currentPlaylist.uri;
    cuttedUrl = [cuttedUrl stringByReplacingOccurrencesOfString:@"https://api.soundcloud.com" withString:@""];
    NSString * url = [NSString stringWithFormat:@"%@.json",cuttedUrl];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    [[SoundtraceClient sharedClient] GET:url parameters:paramters
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {
      
         [self.navigationItem setTitle:[responseObject objectForKey:@"title"]];
         if ([[responseObject objectForKey:@"tracks"]count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }
         for (NSDictionary * trackInfo in [responseObject objectForKey:@"tracks"]) {
             Track * track = [[Track alloc] initWithDictionary:trackInfo error:nil];
             [self.tracks addObject:track];
         }
         
         long offset = [self.offset integerValue] + [self.limit integerValue];
         self.offset = [NSNumber numberWithLong:offset];
         self.isLoading = NO;
         [self.refreshControl endRefreshing];
         self.view.userInteractionEnabled = YES;

         [self.tableView reloadData];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         [self.refreshControl endRefreshing];
         self.view.userInteractionEnabled = YES;

         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];


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
        // Wenn das item eine Playlist ist dann zeige disclosure Indicator an
        Track * track = [self.tracks objectAtIndex:indexPath.row];
        [cell.repostedImageView setImage:[UIImage imageNamed:@"user"]];
        cell.userNameLabel.text = track.user.username;
        cell.trackNameLabel.text = track.title;
        [cell.artworkImage setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
        
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
        [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithWhite:0.250 alpha:1.000] normalIcon:[icon imageWithSize:CGSizeMake(30, 30)] selectedIcon:nil];
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
                [self fetchFortrackofPlaylist];
            }
        }
    }
}


#pragma mark - Editing stuff

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (indexPath.row >= [self.tracks count]) {
        return NO;
    } else {
        if ([delegate.currentUser.id integerValue] == [self.currentPlaylist.user.id integerValue]) {
            return YES;
        } else return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [SVProgressHUD showWithStatus:@"Removing track from playlist"];
        Track * trackToRemove = [self.tracks objectAtIndex:indexPath.row];
        [self.tracks removeObjectAtIndex:indexPath.row];
        
        // Add Track to Playlist and then remove Viewcontroller from Top
        // Holen uns alle Tracks der Playlis
        NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
        [paramters setObject:self.store.authToken forKey:@"oauth_token"];
        
        [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"me/playlists/%@.json",self.currentPlaylist.id] parameters:paramters
         
         
                                     success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             // Konfiguration
             NSMutableArray * ids = [[NSMutableArray alloc]init];
             for (id trackDictionary in [responseObject objectForKey:@"tracks"]) {
                 Track * track = [[Track alloc]initWithDictionary:trackDictionary error:nil];
                 if ([trackToRemove.id integerValue] != [track.id integerValue]) {
                     [ids addObject:track.id];
                 }
             }

             
             NSMutableArray * idArray = [[NSMutableArray alloc]init];
             for (NSNumber *idNumber in ids) {
                 [idArray addObject:@{@"id":idNumber}];
             }
             
             
             NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
             [paramters setObject:self.store.authToken forKey:@"oauth_token"];
             [paramters setObject:@{@"tracks":idArray} forKey:@"playlist"];
             [[SoundtraceClient sharedClient] PUT:[NSString stringWithFormat:@"me/playlists/%@.json",self.currentPlaylist.id] parameters:paramters
              
              
              success: ^(NSURLSessionDataTask *task, id responseObject)
              {
                  [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  [SVProgressHUD showSuccessWithStatus:@"Removed track from playlists"];
                  
              }
              
                                          failure: ^(NSURLSessionDataTask *task, NSError *error)
              {
                  // Fehlerbehandlung
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  
              }];
             
             
             
         }
         
                                     failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             // Fehlerbehandlung
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];

         }];
        
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
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
