//
//  PlaylistTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "UserTableViewController.h"
#import <MBProgressHUD.h>
#import <FAKIonIcons.h>
#import "PlaylistTableViewController.h"
#import <RESideMenu.h>
#import "CredentialStore.h"
#import "AppDelegate.h"
#import "SoundtraceClient.h"
#import "Playlist.h"
#import "BasicTrackTableViewCell.h"
#import"UIImageView+AFNetworking.h"
#import "PlaylistTracksListTableViewController.h"
#import "LoadMoreTableViewCell.h"
#import "CreatePlaylistTableTableViewController.h"
#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <SVProgressHUD.h>


@interface PlaylistTableViewController () <BasicTrackTableViewCellDelegate>
@property (nonatomic,strong)CredentialStore * store;
@property (nonatomic,strong)NSMutableArray * playlists;
@property (nonatomic,strong) NSString * tracksURL;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;
@end

@implementation PlaylistTableViewController

- (void)viewDidLoad {
 
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Playlists"];
    [self setshowMenuButton];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
      [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];
    self.store = [[CredentialStore alloc]init];
    self.playlists = [[NSMutableArray alloc]init];
    [self setAddButton];
    [self setupPagination];
    [self setUpRefreshControl];
    [self fetchForPlaylists];
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
        [self.playlists removeAllObjects];
        [self fetchForPlaylists];
    }
}

-(void)setAddButton {
    FAKIonIcons *cogIcon = [FAKIonIcons ios7PlusEmptyIconWithSize:30];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(30, 30)];
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(addPlaylistButtonPressed:)];
}


-(void)addPlaylistButtonPressed:(id)sender {
    UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController * nav = [storyboard instantiateViewControllerWithIdentifier:@"createPlaylist"];
    CreatePlaylistTableTableViewController * controller = [[nav viewControllers]objectAtIndex:0];
    controller.createPlaylistDelegate = self;
    
    [self presentViewController:nav animated:YES completion:nil];
}


-(void)fetchForPlaylists {
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    [paramters setObject:[NSNumber numberWithInt:20] forKey:@"limit"];
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/playlists.json",delegate.currentUser.id] parameters:paramters
    
    
                                      success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if ([responseObject count] < [self.limit integerValue]) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }
         
         for (NSDictionary * playlist in responseObject) {
             [self.playlists addObject:[[Playlist alloc] initWithDictionary:playlist error:nil]];
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
    return [self.playlists count]+2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.playlists count]) {
    
        BasicTrackTableViewCell *cell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        Playlist *playlist = [self.playlists objectAtIndex:indexPath.row];
        cell.delegate = self;
        cell.data = playlist;
        return cell;
    }
    
    else if (indexPath.row >= [self.playlists count]) {
        if (indexPath.row == ([self.playlists  count])) {
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.playlists count]) {
        [self performSegueWithIdentifier:@"showTracksOfPlaylist" sender:self];
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

// Gefrickel 
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTracksOfPlaylist"]) {
        PlaylistTracksListTableViewController * dc = (PlaylistTracksListTableViewController*)segue.destinationViewController;
        id playListOrRepostedPlaylist = [self.playlists objectAtIndex:[[self.tableView indexPathForSelectedRow]row]];
        if ([playListOrRepostedPlaylist class] == [Playlist class]) {
            Playlist * list = (Playlist*)playListOrRepostedPlaylist;
            list.tracks_uri = [list.uri stringByAppendingString:@"/tracks"];
            dc.currentPlaylist = list;
        }
    }
}

-(void)playlistCreated{
    [self refresh];
}


// Deletion Stuff



 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
     if (indexPath.row >= [self.playlists count]) {
         return NO;
     }
     return YES;
}


// Deleting Playlists stuff
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
     if (editingStyle == UITableViewCellEditingStyleDelete) {
         // Delete the row from the data source
         
         [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
         [SVProgressHUD showWithStatus:@"Removing playlist"];
         NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
         [paramters setObject:self.store.authToken forKey:@"oauth_token"];
         [paramters setObject:self.limit forKey:@"limit"];
         [paramters setObject:self.offset forKey:@"offset"];
         Playlist * list = [self.playlists objectAtIndex:indexPath.row];
         [[SoundtraceClient sharedClient] DELETE:[NSString stringWithFormat:@"/playlists/%@",list.id] parameters:paramters
          
          
            success: ^(NSURLSessionDataTask *task, id responseObject)
          {
              [self.playlists removeObjectAtIndex:indexPath.row];
              [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
              [SVProgressHUD showSuccessWithStatus:@"Playlist removed"];
              [[UIApplication sharedApplication] endIgnoringInteractionEvents];
              
          }
          
            failure: ^(NSURLSessionDataTask *task, NSError *error)
          {
              [self.refreshControl endRefreshing];
              [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try agin"];
              [[UIApplication sharedApplication] endIgnoringInteractionEvents];
              
          }];
         
         ;
     } else if (editingStyle == UITableViewCellEditingStyleInsert) {
         // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
     }
 }

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        if(!self.isLoading) {
            if (self.itemsAvailable) {
                LoadMoreTableViewCell * lmc = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self.playlists count] inSection:0]];
                [lmc.loadingIndicator startAnimating];
                [self fetchForPlaylists];
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
