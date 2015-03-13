//
//  SearchTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKIonIcons.h>
#import <TSMessage.h>
#import "SearchTableViewController.h"
#import <RESideMenu.h>
#import "CredentialStore.h"
#import "SoundtraceClient.h"
#import "Track.h"
#import "BasicTrackTableViewCell.h"
#import "Playlist.h"
#import "User.h"
#import "UserTableViewController.h"
#import "PlaylistTracksListTableViewController.h"
#import "AppDelegate.h"
#import"UIImageView+AFNetworking.h"
#import "UserTableViewCell.h"
#import "LoadMoreTableViewCell.h"
#import <SWTableViewCell.h>

@interface SearchTableViewController () <UISearchBarDelegate,SWTableViewCellDelegate>
@property (nonatomic,strong) IBOutlet UISearchBar * searchBar;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@property (nonatomic, strong) CredentialStore *store;

// Pagination
// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;
@property (nonatomic,strong) NSMutableArray * tasks;


@end

@implementation SearchTableViewController


- (void)viewDidLoad {
    
    [super viewDidLoad];
    self.tasks = [[NSMutableArray alloc]init];
    [self setupPagination];
    self.store = [[CredentialStore alloc]init];
    self.searchBar.delegate = self;
    self.dataSourceArray = [NSMutableArray array];

    [self.navigationItem setTitle:@"Search"];
    [self setshowMenuButton];
    // register 3 Cells
    
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:@"usercell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];


}

-(void)cancelAllRequests {
    for (NSURLSessionTask * task in self.tasks) {
        [task cancel];
    }
}

-(void)setupPagination {
    self.offset = @0;
    self.limit = @20;
    self.isLoading = NO;
    self.itemsAvailable = NO;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
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
    return [_dataSourceArray count]+2;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.dataSourceArray count]) {
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            BasicTrackTableViewCell * trackCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
            Track * track = [self.dataSourceArray objectAtIndex:indexPath.row];
            trackCell .trackNameLabel.text  = track.title;
            trackCell .userNameLabel.text = track.user.username;
            [trackCell .repostedImageView setImage:[UIImage imageNamed:@"user"]];
            
            if (track.artwork_url) {
                [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:track.artwork_url] placeholderImage:nil];
            } else {
                [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
            }
            
            trackCell.accessoryType = UITableViewCellAccessoryNone;
            
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
            trackCell.playbackCountLabel.attributedText = playbackcount;
            
            /******************* SHOW USER BUTTON STUFF ****************/
            FAKIonIcons * icon = [FAKIonIcons ios7PersonIconWithSize:30];
            [icon addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                                     whiteColor]];
            trackCell.delegate = self;
            NSMutableArray * leftUtilityButtons = [NSMutableArray new];
            [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithWhite:0.250 alpha:1.000] normalIcon:[icon imageWithSize:CGSizeMake(30, 30)] selectedIcon:nil];
            trackCell.leftUtilityButtons = leftUtilityButtons;
            /***********************************************************/
            return  trackCell;
        } else if (self.searchBar.selectedScopeButtonIndex == 1) {
            
            UserTableViewCell * userCell = (UserTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
            userCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            User * user = [self.dataSourceArray objectAtIndex:indexPath.row];
            
            if (user.country) {
                userCell.userNameAndCoutryLabel.text = [NSString stringWithFormat:@"%@,%@",user.username,user.country];
            } else {
                userCell.userNameAndCoutryLabel.text = [NSString stringWithFormat:@"%@",user.username];
            }
            
            userCell.numberOfSoundsLabel.text = [NSString stringWithFormat:@"%@ Sounds",user.track_count];
            FAKIonIcons *soundsIcon = [FAKIonIcons podiumIconWithSize:10];
            NSMutableAttributedString * soundsCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",user.track_count]];
            [soundsCount appendAttributedString:[soundsIcon attributedString]];
            // Number of Followers label
            FAKIonIcons *followersIcon = [FAKIonIcons personStalkerIconWithSize:10];
            NSMutableAttributedString * followersCount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",user.followers_count]];
            [followersCount appendAttributedString:[followersIcon attributedString]];
            NSAttributedString * spacer = [[NSMutableAttributedString alloc]initWithString:@"    " attributes:nil];
            [followersCount appendAttributedString:spacer];
            [followersCount appendAttributedString:soundsCount];
            userCell.numberOfSoundsLabel.attributedText = followersCount;
    
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
                NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:user.avatar_url]];
                UIImage * image = [UIImage imageWithData:data];
                
                dispatch_async(dispatch_get_main_queue(), ^(){
                    [userCell.userImageView setImage:image];
                });
                
            });
            
            
            return  userCell;
        } else if (self.searchBar.selectedScopeButtonIndex == 2) {
            
            BasicTrackTableViewCell * listCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
            Playlist * list = [self.dataSourceArray objectAtIndex:indexPath.row];
            listCell.trackNameLabel.text  = list.title;
            listCell.userNameLabel.text = list.user.username;
            [listCell.repostedImageView setImage:[UIImage imageNamed:@"user"]];
            listCell.playbackCountLabel.text = [NSString stringWithFormat:@"%@ Tracks",list.track_count];
            if (list.artwork_url) {
                [listCell.artworkImage setImageWithURL:[NSURL URLWithString:list.artwork_url] placeholderImage:nil];
            } else {
                [listCell.artworkImage setImageWithURL:[NSURL URLWithString:list.user.avatar_url] placeholderImage:nil];
            }
            listCell.firstLayerViewPlaylist.hidden = NO;
            listCell.secondLayerViewPlaylist.hidden = NO;
            listCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            /******************* SHOW USER BUTTON STUFF ****************/
            FAKIonIcons * icon = [FAKIonIcons ios7PersonIconWithSize:30];
            [icon addAttribute:NSForegroundColorAttributeName value:[UIColor
                                                                     whiteColor]];
            listCell.delegate = self;
            NSMutableArray * leftUtilityButtons = [NSMutableArray new];
            [leftUtilityButtons sw_addUtilityButtonWithColor:[UIColor colorWithWhite:0.250 alpha:1.000] normalIcon:[icon imageWithSize:CGSizeMake(30, 30)] selectedIcon:nil];
            listCell.leftUtilityButtons = leftUtilityButtons;
            /***********************************************************/
            
            return listCell;
        }
    }
    
    
    else if (indexPath.row >= [self.dataSourceArray count]) {
        if (indexPath.row == ([self.dataSourceArray count])) {
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

#pragma mark -searchbar


-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [self search];
    [self.searchBar resignFirstResponder];
}

-(void)search {
    self.offset = @0;
    [self.dataSourceArray removeAllObjects];
    NSInteger index = self.searchBar.selectedScopeButtonIndex;
    if (index == 0) {
        [self searchForTracks];
    } else if(index == 1) {
        [self searchForUsers];
    } else if(index == 2) {
        [self searchForPlaylists];
    }
}

-(void)searchForTracks {
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    [paramters setObject:self.searchBar.text forKey:@"q"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];

    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/tracks.json"] parameters:paramters
     
     
    success: ^(NSURLSessionDataTask *task, id responseObject)
     {
      
         if ([responseObject count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }

         for (NSDictionary * track in responseObject) {
             Track * trackToAdd = [[Track alloc]initWithDictionary:track error:nil];
             [self.dataSourceArray addObject:trackToAdd];
         }
         long offset = [self.offset integerValue] + [self.limit integerValue];
         self.offset = [NSNumber numberWithLong:offset];
         self.isLoading = NO;
         [self.tableView reloadData];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }
     
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }];
    
    [self.tasks addObject:task];
}
-(void)searchForUsers {
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    [paramters setObject:self.searchBar.text forKey:@"q"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task =[[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users.json"] parameters:paramters
     
     
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if ([responseObject count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }

         for (NSDictionary * userDict in responseObject) {
             User * user = [[User alloc]initWithDictionary:userDict error:nil];
             [self.dataSourceArray addObject:user];
         }
         
         long offset = [self.offset integerValue] + [self.limit integerValue];
         self.offset = [NSNumber numberWithLong:offset];
         self.isLoading = NO;

         [self.tableView reloadData];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }
     
                                 failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

         
     }];
    
    [self.tasks addObject:task];
}
-(void)searchForPlaylists {
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    [paramters setObject:self.searchBar.text forKey:@"q"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/playlists.json"] parameters:paramters
     
     
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {

         if ([responseObject count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }

         for (NSDictionary * userDict in responseObject) {
             Playlist * playlist = [[Playlist alloc]initWithDictionary:userDict error:nil];
             [self.dataSourceArray addObject:playlist];
         }
         
         long offset = [self.offset integerValue] + [self.limit integerValue];
         self.offset = [NSNumber numberWithLong:offset];
         self.isLoading = NO;

         [self.tableView reloadData];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

         
     }];
    
    [self.tasks addObject:task];
}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    [self cancelAllRequests];
    [self.dataSourceArray removeAllObjects];
    [self setupPagination];
    self.offset = @0;
    [self.tableView reloadData];
    if ([self.searchBar.text length] != 0) {
        NSInteger index = self.searchBar.selectedScopeButtonIndex;
        if (index == 0) {
            [self searchForTracks];
        } else if(index == 1) {
            [self searchForUsers];
        } else if(index == 2) {
            [self searchForPlaylists];
        }
    }

}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row < [self.dataSourceArray count]) {
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
            Track * track = [self.dataSourceArray objectAtIndex:indexPath.row];
            if (track.streamable) {
                [delegate setupPlayerWithtrack:track];
                delegate.upNext = [self.dataSourceArray mutableCopy];
                [delegate setPlayingIndex:indexPath];
            } else {
                [TSMessage showNotificationWithTitle:@"This track is not streamable" type:TSMessageNotificationTypeError];
            }
            
        } else if (self.searchBar.selectedScopeButtonIndex == 1) {
            [self performSegueWithIdentifier:@"showUser" sender:self];
        } else if (self.searchBar.selectedScopeButtonIndex == 2) {
            [self performSegueWithIdentifier:@"showPlaylist" sender:self];
        }
    }
    else if (indexPath.row == [self.dataSourceArray count]) {
        LoadMoreTableViewCell * loadMoreCell = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [loadMoreCell.loadMoreLabel setHidden:true];
        [loadMoreCell.loadingIndicator startAnimating];
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            [self searchForTracks];
        } else if (self.searchBar.selectedScopeButtonIndex == 1) {
            [self searchForUsers];
        } else if (self.searchBar.selectedScopeButtonIndex == 2) {
            [self searchForPlaylists];
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showUser"]) {
        UserTableViewController * dc = (UserTableViewController*)segue.destinationViewController;
        User * user = [self.dataSourceArray objectAtIndex:[[self.tableView indexPathForSelectedRow]row]];
        dc.user_id = user.id;
        dc.showMenuButton = false;
    } else if ([segue.identifier isEqualToString:@"showPlaylist"]) {
        PlaylistTracksListTableViewController * dc = (PlaylistTracksListTableViewController*)segue.destinationViewController;
        Playlist * list = [self.dataSourceArray objectAtIndex:[[self.tableView indexPathForSelectedRow]row]];
        dc.currentPlaylist = list;
    }

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    [self.searchBar resignFirstResponder];

    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        if(!self.isLoading) {
            if (self.itemsAvailable) {
                LoadMoreTableViewCell * lmc = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self.dataSourceArray count] inSection:0]];
                [lmc.loadingIndicator startAnimating];
                if (self.searchBar.selectedScopeButtonIndex == 0) {
                    [self searchForTracks];
                } else if (self.searchBar.selectedScopeButtonIndex == 1) {
                    [self searchForUsers];
                } else if (self.searchBar.selectedScopeButtonIndex == 2) {
                    [self searchForPlaylists];
                }
                
            }
        }
    }
}

#pragma mark - SWTableViewDelegate

-(void)swipeableTableViewCell:(SWTableViewCell *)cell didTriggerLeftUtilityButtonWithIndex:(NSInteger)index{
    
    NSIndexPath * indexPath = [self.tableView indexPathForCell:cell];
    NSNumber * idOfUser = @0;
    id currentObject = [self.dataSourceArray  objectAtIndex:indexPath.row];
    Track * track = (Track*)currentObject;
    idOfUser = track.user.id;
    
    [cell hideUtilityButtonsAnimated:YES];
    UserTableViewController * userTableViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"user"];
    userTableViewController.user_id = idOfUser;
    userTableViewController.showMenuButton = NO;
    [self.navigationController pushViewController:userTableViewController animated:YES];
}
@end
