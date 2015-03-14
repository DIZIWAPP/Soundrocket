        /* This Controller manages all Activities(Stream including) - Shares, Reposts,Playlist, Reposts*/
#import <FAKFontAwesome.h>
#import <FAKIonIcons.h>
#import "ActivitiesTableViewController.h"
#import "BasicTrackTableViewCell.h"
#import "CredentialStore.h"
#import "SoundtraceClient.h"
#import"UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "PlaylistTracksListTableViewController.h"
#import "LoadMoreTableViewCell.h"
// Headers for Avtivitys
#import "Track.h"
#import "TrackRespost.h"
#import "Playlist.h"
#import "PlaylistRespost.h"
#import "URLParser.h"
#import <MBProgressHUD.h>
#import <RESideMenu.h>
#import <TSMessage.h>
#import "UserTableViewController.h"
#import "SRStylesheet.h"
/**
 *  Private Interface
 */
@interface ActivitiesTableViewController ()

@property (nonatomic,strong) NSMutableArray * activities; // Track - Track Sharing - Comment - Favoriting
@property (nonatomic,strong) CredentialStore * store;
@property (nonatomic,strong) UIView * footerView;


// Pagination
@property (nonatomic,strong) NSString * nextUrl; // Stores the next Url
@property (nonatomic,assign) BOOL isLoading;
@end

@implementation ActivitiesTableViewController


/**
 *  Got called if view is loaded
 */

- (void)viewDidLoad {
    AFHTTPSessionManager * client = [SoundtraceClient sharedClient];
    client.securityPolicy = [AFSecurityPolicy defaultPolicy];
    client.responseSerializer = [AFJSONResponseSerializer serializer];
    client.requestSerializer = [AFJSONRequestSerializer serializer];
    [super viewDidLoad];
    self.nextUrl = nil;
    self.isLoading = NO;
    [self setup]; // Setup everything from Navigationbar registering nib files
    [self setUpRefreshControl];
    [self fetchForTracksOfStream]; // Then fetch Tracks of Stream ..
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationItem.title = @"";
    [self setupNavigationbar];
}

-(void)setupNavigationbar {
    UIView *backView =[[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 20)];// Here you can set View width and height as per your requirement for displaying titleImageView position in navigationbar
    UIImageView *titleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header"]];
    titleImageView.contentMode = UIViewContentModeScaleAspectFit;
    titleImageView.frame = backView.frame; // Here I am passing origin as (45,5) but can pass them as your requirement.
    [backView addSubview:titleImageView];
    //titleImageView.contentMode = UIViewContentModeCenter;
    self.navigationItem.titleView = backView;
}
/**
 *  Sets everything up
 */
-(void)setup {
    self.store = [[CredentialStore alloc]init];
    self.activities = [[NSMutableArray alloc]init];
    [self setshowMenuButton];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];

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
        self.view.userInteractionEnabled = NO;
        self.nextUrl = nil;
        [self.activities removeAllObjects];
        [self fetchForTracksOfStream];
    }
}

-(void)fetchForTracksOfStream {
    
    /*******************************************************/
    /****************** MASTER BUG *************************/
    /*******************************************************/
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    self.isLoading = YES;
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    [parameters setObject:[NSNumber numberWithInt:20] forKey:@"limit"];
    if (self.nextUrl) {
        // Setze die URL wenn nicht dann halt nicht
        URLParser *parser = [[URLParser alloc] initWithURLString:self.nextUrl];
        NSString * cursor = [parser valueForVariable:@"cursor"];
        [parameters setObject:cursor forKey:@"cursor"];
    }
    // Request all Activities
    [[SoundtraceClient sharedClient] GET:@"/me/activities.json" parameters:parameters
    success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         // Save next url
         self.view.userInteractionEnabled = YES;

         if ([responseObject objectForKey:@"next_href"]) {
             self.nextUrl = [responseObject objectForKey:@"next_href"];
         } else self.nextUrl = nil;
         
         for (NSDictionary * activity in [responseObject objectForKey:@"collection"]) {
             if ([[activity objectForKey:@"type"] isEqualToString:@"track"]) {
                 Track * track = [[Track alloc]initWithDictionary:[activity objectForKey:@"origin"] error:nil];
                 [self.activities addObject:track];
             } else if ([[activity objectForKey:@"type"] isEqualToString:@"track-repost"]) {
                 TrackRespost * trackRepost = [[TrackRespost alloc]initWithDictionary:[activity objectForKey:@"origin"] error:nil];
                 [self.activities addObject:trackRepost];
                 
             } else if ([[activity objectForKey:@"type"] isEqualToString:@"playlist"]) {
                 //Playlist * playlist;
                 Playlist  * playlist= [[Playlist alloc]initWithDictionary:[activity objectForKey:@"origin"] error:nil];
                 [self.activities addObject:playlist];
             } else if ([[activity objectForKey:@"type"] isEqualToString:@"playlist-repost"]) {
                 PlaylistRespost  * playlistRepost= [[PlaylistRespost alloc]initWithDictionary:[activity objectForKey:@"origin"] error:nil];
                 [self.activities addObject:playlistRepost];
             }
         }
         
         
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         self.isLoading = NO;

         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         self.view.userInteractionEnabled = YES;
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         [TSMessage showNotificationWithTitle:@"Something went wrong" type:TSMessageNotificationTypeError];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];


     }];
    
    self.tableView.backgroundView = nil;
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
    return [self.activities count]+2; // One Cell for Loadmore
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row < [self.activities count]) {
        id currentObject = [self.activities  objectAtIndex:indexPath.row];
    
    // Setting up the Tracks
    if ([currentObject class] == [Track class]) {
        Track * track = (Track*)currentObject;
        BasicTrackTableViewCell *trackCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        
        trackCell.userNameLabel.text = track.user.username;
        trackCell.trackNameLabel.text = track.title;
        
        if (track.artwork_url) {
            NSString  *largeUrl = [track.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
        } else {
            [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
        }
        
        FAKIonIcons *playIcon = [FAKIonIcons playIconWithSize:10];
        NSMutableAttributedString * playbackcount = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ ",track.playback_count]];
        [playbackcount appendAttributedString:[playIcon attributedString]];
        
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
        
        [trackCell.repostedImageView setImage:[UIImage imageNamed:@"upload"]];
        return  trackCell;
    }
    // Track Reposts
    
    else if ([currentObject class] == [TrackRespost class]) {
        TrackRespost * track = (TrackRespost*)currentObject;
        BasicTrackTableViewCell *trackCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        
        trackCell.userNameLabel.text = track.user.username;
        trackCell.trackNameLabel.text = track.title;
        if (track.artwork_url) {
            NSString  *largeUrl = [track.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
        } else {
            [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:track.user.avatar_url] placeholderImage:nil];
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
        trackCell.playbackCountLabel.attributedText = playbackcount;

        
        [trackCell.repostedImageView setImage:[UIImage imageNamed:@"repost"]];
        return  trackCell;
    }
    // Playlist
    else if ([currentObject class] == [Playlist class]) {
        Playlist * playlist = (Playlist*)currentObject;
        BasicTrackTableViewCell *trackCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        trackCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        trackCell.userNameLabel.text = playlist.user.username;
        trackCell.trackNameLabel.text = playlist.title;
        if (playlist.artwork_url) {
            NSString  *largeUrl = [playlist.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
        } else {
            [trackCell.artworkImage setImageWithURL:[NSURL URLWithString:playlist.user.avatar_url] placeholderImage:nil];
        }
        
        // Private not private etc
        FAKFontAwesome * lockIcon = [FAKFontAwesome lockIconWithSize:10];
        NSMutableAttributedString * lockString = [[NSMutableAttributedString alloc]init];
        if ([playlist.sharing isEqualToString:@"private"]) {
             lockString = [[lockIcon attributedString]mutableCopy];
            [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ Tracks",playlist.track_count]]];

        } else {
            [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ Tracks",playlist.track_count]]];
        }
        trackCell.playbackCountLabel.attributedText = lockString;
        [trackCell.repostedImageView setImage:[UIImage imageNamed:@"list"]];
        trackCell.firstLayerViewPlaylist.hidden = NO;
        trackCell.secondLayerViewPlaylist.hidden = NO;
        return  trackCell;
    }
    
    // PlaylistRespost
    else if ([currentObject class] == [PlaylistRespost class]) {
        PlaylistRespost * playlistRepost = (PlaylistRespost*)currentObject;
        BasicTrackTableViewCell *playlistRepostCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        playlistRepostCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        playlistRepostCell.userNameLabel.text = playlistRepost.user.username;
        playlistRepostCell.trackNameLabel.text = playlistRepost.title;
        if (playlistRepost.artwork_url) {
            NSString  *largeUrl = [playlistRepost.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
            [playlistRepostCell.artworkImage setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:nil];
        } else {
            [playlistRepostCell.artworkImage setImageWithURL:[NSURL URLWithString:playlistRepost.user.avatar_url] placeholderImage:nil];
        }
        
        // Private not private etc
        FAKFontAwesome * lockIcon = [FAKFontAwesome lockIconWithSize:10];
        NSMutableAttributedString * lockString = [[NSMutableAttributedString alloc]init];
        if ([playlistRepost.sharing isEqualToString:@"private"]) {
            lockString = [[lockIcon attributedString]mutableCopy];
            [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@" %@ Tracks",playlistRepost.track_count]]];
            
        } else {
            [lockString appendAttributedString:[[NSAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@ Tracks",playlistRepost.track_count]]];
        }
        playlistRepostCell.playbackCountLabel.attributedText = lockString;
        
        [playlistRepostCell.repostedImageView setImage:[UIImage imageNamed:@"repost"]];
        playlistRepostCell.firstLayerViewPlaylist.hidden = NO;
        playlistRepostCell.secondLayerViewPlaylist.hidden = NO;
        return  playlistRepostCell;
    }
    
    }
    else if (indexPath.row >= [self.activities count]) {
        if (indexPath.row == ([self.activities count])) {
            
            LoadMoreTableViewCell *loadmoreCell = (LoadMoreTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"loadmorecell" forIndexPath:indexPath];
            if ([self.activities count] == 0) {
                [loadmoreCell.loadingIndicator stopAnimating];
                loadmoreCell.loadMoreLabel.hidden = NO;
                //[loadmoreCell.loadMoreLabel setText:@"No Activities available"];
            } else {
                [loadmoreCell.loadingIndicator startAnimating];
                loadmoreCell.userInteractionEnabled = NO;
            }
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
    
    if (indexPath.row < [self.activities count]) {
        
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        id objectAtIndexPath = [self.activities objectAtIndex:indexPath.row]; // Holen dir das Objekt aus dem Indexpath
    
        // Wenn es ein Track ist dann schiebe den Track oder Repost in den Player
        if ([objectAtIndexPath class] == [Track class]) {
            Track * track = objectAtIndexPath;
            if (track.streamable) {
                [delegate setupPlayerWithtrack:objectAtIndexPath];
                [self setUpNext:track];
            } else {
                [TSMessage showNotificationWithTitle:@"This track is not streamable" type:TSMessageNotificationTypeError];
            }
        }
        else if ([objectAtIndexPath class] == [TrackRespost class]) {
            Track * track = [[Track alloc]initWithTrackRespost:objectAtIndexPath];
            if (track.streamable) {
                [delegate setupPlayerWithtrackRepost:objectAtIndexPath];
                [self setUpNext:track];
            } else {
                [TSMessage showNotificationWithTitle:@"This track is not streamable" type:TSMessageNotificationTypeError];
            }
        }
    
        // Wenn es sich um eine Playlist handelt dann öffne den Playlist Tableview
        else if ([objectAtIndexPath class] == [Playlist class]){
            [self performSegueWithIdentifier:@"showTracksOfPlaylist" sender:self];
        }
        
        else if ([objectAtIndexPath class] == [PlaylistRespost class]){
            [self performSegueWithIdentifier:@"showTracksOfPlaylist" sender:self];
        }
    
    }
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)setUpNext:(Track*)track {
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    NSMutableArray * nextTracks = [[NSMutableArray alloc]init];
    NSIndexPath * selectedIndexPath;
    for (id activity in self.activities) {
        Track * trackToAdd = nil;
        if ([activity class] == [Track class]) {
            trackToAdd = activity;
        }
        else if ([activity class] == [TrackRespost class]) {
            TrackRespost * repost = (TrackRespost*)activity;
            trackToAdd = [[Track alloc]initWithTrackRespost:repost];
        }
        
        if (trackToAdd) {
            [nextTracks addObject:trackToAdd];
            if (track.id == trackToAdd.id) {
                NSUInteger index = [nextTracks indexOfObject:trackToAdd];
                selectedIndexPath = [NSIndexPath indexPathForItem:index inSection:0];
                [delegate setPlayingIndex:selectedIndexPath]; // hier wird der Index gesetzt
            }
        }
        
        
    }
    
    [delegate setUpNext:nextTracks];
    
    self.tableView.showsHorizontalScrollIndicator = NO;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTracksOfPlaylist"]) {
        PlaylistTracksListTableViewController * dc = (PlaylistTracksListTableViewController*)segue.destinationViewController;
        id playListOrRepostedPlaylist = [self.activities objectAtIndex:[[self.tableView indexPathForSelectedRow]row]];
        if ([playListOrRepostedPlaylist class] == [Playlist class]) {
            dc.currentPlaylist = playListOrRepostedPlaylist;
        } else if ([playListOrRepostedPlaylist class] == [PlaylistRespost class]) {
            dc.currentPlaylist = [[Playlist alloc]initWithPlayListRepost:playListOrRepostedPlaylist];
        }
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        if(!self.isLoading) {
            if (self.nextUrl) {
                [self fetchForTracksOfStream];
            }
        }
    }
}
@end
