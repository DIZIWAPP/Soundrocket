//
//  AddToPlaylistTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 03.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "AddToPlaylistTableViewController.h"

//
//  PlaylistTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKIonIcons.h>
#import <FAKFontAwesome.h>
#import <MBProgressHUD.h>
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
#import "PlayerViewController.h"
#import <SVProgressHUD.h>

@interface AddToPlaylistTableViewController ()
@property (nonatomic,strong)CredentialStore * store;
@property (nonatomic,strong)NSMutableArray * playlists;
@property (nonatomic,strong) NSString * tracksURL;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;
@end

@implementation AddToPlaylistTableViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.navigationItem setTitle:@"Playlists"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];
    self.store = [[CredentialStore alloc]init];
    self.playlists = [[NSMutableArray alloc]init];
    [self setupPagination];
    [self setUpRefreshControl];
    [self fetchForPlaylists];
}

-(void)setupPagination {
    self.offset = @0;
    self.limit = @20;
    self.isLoading = NO;
    self.itemsAvailable = NO;
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
    self.offset = @0;
    self.view.userInteractionEnabled = NO;
    [self.playlists removeAllObjects];
    [self fetchForPlaylists];
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
         if ([responseObject count] == 0) {
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
         self.view.userInteractionEnabled = YES;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

         
     }
     
                                 failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         self.view.userInteractionEnabled = YES;
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
    return [self.playlists count]+2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.playlists count]) {
        
        BasicTrackTableViewCell *cell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        Playlist *playlist = [self.playlists objectAtIndex:indexPath.row];
        cell.data = playlist;
        return cell;
    }
    
    else if (indexPath.row >= [self.playlists count]) {
        if (indexPath.row == ([self.playlists count])) {
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
        [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        // Add Track to Playlist and then remove Viewcontroller from Top
        Playlist * playlist = [self.playlists objectAtIndex:[[self.tableView indexPathForSelectedRow]row]];
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        PlayerViewController   *player = delegate.player;
        [SVProgressHUD showWithStatus:[NSString stringWithFormat:@"Adding Track %@ to %@",player.currentTrack.title,playlist.title]];
        // Holen uns alle Tracks der Playlis
        NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
        [paramters setObject:self.store.authToken forKey:@"oauth_token"];
        
        [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"me/playlists/%@.json",playlist.id] parameters:paramters
         
         
         success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             // Konfiguration
             NSMutableArray * ids = [[NSMutableArray alloc]init];
             for (id trackDictionary in [responseObject objectForKey:@"tracks"]) {
                 Track * track = [[Track alloc]initWithDictionary:trackDictionary error:nil];
                 [ids addObject:track.id];
             }
             
             // Füge neue ID hinzu

             [ids addObject:player.currentTrack.id];
             
             NSMutableArray * idArray = [[NSMutableArray alloc]init];
             for (NSNumber *idNumber in ids) {
                 [idArray addObject:@{@"id":idNumber}];
             }
             
             
             NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
             [paramters setObject:self.store.authToken forKey:@"oauth_token"];
             [paramters setObject:@{@"tracks":idArray} forKey:@"playlist"];
             [[SoundtraceClient sharedClient] PUT:[NSString stringWithFormat:@"me/playlists/%@.json",playlist.id] parameters:paramters
              
              
                                          success: ^(NSURLSessionDataTask *task, id responseObject)
              {
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  [[UIApplication sharedApplication]endIgnoringInteractionEvents];

                  [self.navigationController popViewControllerAnimated:YES];
                  [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"Added Track %@ to %@",player.currentTrack.title,playlist.title]];
              }
              
                                          failure: ^(NSURLSessionDataTask *task, NSError *error)
              {
                  // Fehlerbehandlung
                  [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
                  [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
                  [[UIApplication sharedApplication]endIgnoringInteractionEvents];
                  
              }];
             
             
             
         }
         
         failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             // Fehlerbehandlung
             [SVProgressHUD showWithStatus:@"Something went wrong, please try agian"];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             
         }];
        // Array aus den IDs der Playlist
        // Neue ID reinschieben
        // Auf array mappen
        // tracks = [{:id=>22448500}, {:id=>21928809}, {:id=>21778201}]
        // Put :tracks => tracks
  
        
    }
    else if (indexPath.row == [self.playlists count]) {
        LoadMoreTableViewCell * loadMoreCell = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [loadMoreCell.loadMoreLabel setHidden:true];
        [loadMoreCell.loadingIndicator startAnimating];
        [self fetchForPlaylists];
        
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
    return YES;
}



- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
        [paramters setObject:self.store.authToken forKey:@"oauth_token"];
        
        [paramters setObject:self.limit forKey:@"limit"];
        [paramters setObject:self.offset forKey:@"offset"];
        Playlist * list = [self.playlists objectAtIndex:indexPath.row];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

        [[SoundtraceClient sharedClient] DELETE:[NSString stringWithFormat:@"/playlists/%@",list.id] parameters:paramters
         
         
        success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             [SVProgressHUD showSuccessWithStatus:@"Playlist removed"];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             [self.playlists removeObjectAtIndex:indexPath.row];
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             
         }
         
        failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             [SVProgressHUD showSuccessWithStatus:@"Something went wrong, please try again"];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             [self.refreshControl endRefreshing];
             
             
             
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

@end
