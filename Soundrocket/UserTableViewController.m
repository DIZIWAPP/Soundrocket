//
//  UserTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <FAKFontAwesome.h>
#import "UserTableViewController.h"
#import "CredentialStore.h"
#import "SoundtraceClient.h"
#import "User.h"
#import "UIViewController+RESideMenu.h"
#import "AppDelegate.h"
#import "LoadMoreTableViewCell.h"
#import "BasicTrackTableViewCell.h"
#import <FAKIonIcons.h>
#import"UIImageView+AFNetworking.h"
#import "Playlist.h"
#import "UserTableViewCell.h"
#import <MBProgressHUD.h>
#import "PlaylistTracksListTableViewController.h"
#import "UserTableViewController.h"
#import <TSMessage.h>
#import <SVProgressHUD.h>
#import "SRStylesheet.h"

@interface UserTableViewController () <BasicTrackTableViewCellDelegate>
@property(nonatomic,strong) CredentialStore * store;
@property(nonatomic,strong) UISegmentedControl * scopeButton;
@property (nonatomic,strong)UIView * headerView;
@property(nonatomic,strong) User * displayedUser;
@property (nonatomic,strong) NSMutableArray * dataSourceArray;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL itemsAvailable;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,strong) UILabel * indicatorLabel;
@property (nonatomic,strong) NSMutableArray * tasks;
@property (nonatomic,strong) UIBarButtonItem * followButton;

@end

@implementation UserTableViewController

- (void)viewDidLoad {
    self.tasks = [[NSMutableArray alloc]init];
    [super viewDidLoad];
    [self setupPagination];
    [self setUpRefreshControl];
    [self.navigationItem setTitle:@"User"];
    [self setup];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [SRStylesheet mainColor];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

-(void)setup{
    if (self.showMenuButton) {
        [self setshowMenuButton];
    }
    self.store = [[CredentialStore alloc]init];
    [self.navigationItem setTitle:@"User"];
    self.dataSourceArray = [[NSMutableArray alloc]init];
    [self setupUserInfo];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:@"usercell"];
}

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
        [self.dataSourceArray removeAllObjects];
        [self scopeChanged:self.scopeButton];
    }
}

-(void)setupPagination {
    self.offset = @0;
    self.limit = @20;
    self.isLoading = NO;
    self.itemsAvailable = NO;
}

-(void)setshowMenuButton {
    FAKIonIcons *cogIcon = [FAKIonIcons naviconIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(showMenu)];
}


/**
 *  Follow unfolloow Sutff
 */
-(void)setFollowButton {
    // Check Follow Status
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    
    // Request all Activities
    [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/me/followings/%@.json",self.displayedUser.id] parameters:parameters
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         // everything is fine
     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
         if (response) {
             int statuscode = (int)response.statusCode;
             if (statuscode == 404) {
                 [self setupFollowButton];
             } else {
                 [self setupUnFollowButton];
             }
         }

     }];
    
    
}


-(void)setupFollowButton {
    FAKIonIcons *cogIcon = [FAKIonIcons personAddIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.rightBarButtonItem =
    self.followButton = [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(followButtonPressed:)];
}

-(void)setupUnFollowButton {

    
    FAKIonIcons *cogIcon = [FAKIonIcons minusCircledIconWithSize:20];
    [cogIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
    UIImage *leftImage = [cogIcon imageWithSize:CGSizeMake(20, 20)];
    cogIcon.iconFontSize = 15;
    UIImage *leftLandscapeImage = [cogIcon imageWithSize:CGSizeMake(15, 15)];
    self.navigationItem.rightBarButtonItem =
    self.followButton = [[UIBarButtonItem alloc] initWithImage:leftImage
                       landscapeImagePhone:leftLandscapeImage
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(unFollowButtonPressed:)];
}

-(void)followButtonPressed:(id)sender {
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    [self.followButton setEnabled:NO];
    // Request all Activities
    [[SoundtraceClient sharedClient] PUT:[NSString stringWithFormat:@"/me/followings/%@",self.displayedUser.id] parameters:parameters
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"You are now following %@",self.displayedUser.username]];
         [self setupUnFollowButton];
         [self.followButton setEnabled:YES];

     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
         [self.followButton setEnabled:YES];

     }];
}

-(void)unFollowButtonPressed:(id)sender {
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    [self.followButton setEnabled:NO];
    // Request all Activities
    [[SoundtraceClient sharedClient] DELETE:[NSString stringWithFormat:@"/me/followings/%@",self.displayedUser.id] parameters:parameters
                                    success: ^(NSURLSessionDataTask *task, id responseObject)
     {
        [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"You unfollowed %@",self.displayedUser.username]];
        [self setupFollowButton];
         [self.followButton setEnabled:YES];
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [self.followButton setEnabled:YES];
     }];
}



-(void)showMenu {
    [self presentLeftMenuViewController:nil];
    
}
- (IBAction)showMenuButtonPressed:(id)sender {
    [self showMenu];
}

-(void)setupUserInfo {
    
    self.userImageView.clipsToBounds = YES;
    self.userImageView.layer.cornerRadius = 40;
    self.userImageView.layer.borderColor = [[SRStylesheet mainColor] CGColor];
    self.userImageView.layer.borderWidth = 1.0;
    
    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    [parameters setObject:self.store.authToken forKey:@"oauth_token"];
    
    // Request all Activities
    [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@.json",self.user_id] parameters:parameters
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         // Überprüfen ob der User = Me ist
         // falls ja zeige keinen Follow Button an
         
         User * user = [[User alloc]initWithDictionary:responseObject error:nil];
         self.displayedUser = user;
         if (user.country) {
             self.UsernameAndCountryLabel.text = [NSString stringWithFormat:@"%@,%@",user.username,user.country];
         } else {
             self.UsernameAndCountryLabel.text = [NSString stringWithFormat:@"%@",user.username];
         }
         [self.navigationItem setTitle:user.username];

         
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
         self.numberOfSoundsLabel.attributedText = followersCount;
         
         dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^(){
             

            NSString*largeUrl = [user.avatar_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];

             
             NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:largeUrl]];
             UIImage * image = [UIImage imageWithData:data];
             
             dispatch_async(dispatch_get_main_queue(), ^(){
                 [self.userImageView setImage:image];
                 [self.imageView_backgroundBlurred setImage:image];
             });
             
         });
         
         // Follow Button setzen oder nicht
         AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
         if ([delegate.currentUser.id integerValue] == [self.user_id integerValue]) {
             [self.navigationItem setRightBarButtonItem:nil];
         }
         
         else {
             [self setFollowButton];
         }
         
         [self scopeChanged:self.scopeButton];
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
    {
         // Something went wrong
    }];
}

// Displaying Data Stuff
-(void)fetchData {
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSourceArray count]+2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.row < [self.dataSourceArray count]) {
        if ((self.scopeButton.selectedSegmentIndex == 0) || (self.scopeButton.selectedSegmentIndex == 2)) {
            BasicTrackTableViewCell * trackCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
            Track * track = [self.dataSourceArray objectAtIndex:indexPath.row];
            trackCell.delegate = self;
            trackCell.data = track;
            return  trackCell;
        } else if (self.scopeButton.selectedSegmentIndex == 1) {
            
            BasicTrackTableViewCell * listCell = (BasicTrackTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
            Playlist * list = [self.dataSourceArray objectAtIndex:indexPath.row];
            listCell.delegate = self;
            listCell.data = list;
            return listCell;
            
        } else if ((self.scopeButton.selectedSegmentIndex == 3) || (self.scopeButton.selectedSegmentIndex == 4)) {
            
            UserTableViewCell * userCell = (UserTableViewCell*)[self.tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
            userCell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            User * user = [self.dataSourceArray objectAtIndex:indexPath.row];
            userCell.user = user;
            return  userCell;
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    if(section == 0) {
        
        if (self.headerView) {
            return self.headerView;
        } else {
            UIView * viewHeader = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width,40)];
            [viewHeader setBackgroundColor:[UIColor whiteColor]];
            
            UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:@[@"Songs", @"Playlists",@"Likes",@"Followers",@"Following"]];
            self.segmentedSearchControl = segmentedControl;
            
            FAKIonIcons *podium = [FAKIonIcons ios7MusicalNoteIconWithSize:15];
            [podium addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            UIImage *leftImage = [podium imageWithSize:CGSizeMake(15, 15)];
            [segmentedControl setImage:leftImage forSegmentAtIndex:0];
            
            FAKIonIcons *listIcon = [FAKIonIcons ios7AlbumsIconWithSize:15];
            [listIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            UIImage *listImagg = [listIcon imageWithSize:CGSizeMake(15, 15)];
            [segmentedControl setImage:listImagg forSegmentAtIndex:1];
            
            FAKIonIcons *heartIcon = [FAKIonIcons ios7HeartIconWithSize:15];
            [heartIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            UIImage *heartImage= [heartIcon imageWithSize:CGSizeMake(15, 15)];
            [segmentedControl setImage:heartImage forSegmentAtIndex:2];
            
            FAKIonIcons *followersIcon = [FAKIonIcons ios7PersonIconWithSize:15];
            [followersIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            UIImage *followersImage = [followersIcon imageWithSize:CGSizeMake(15, 15)];
            [segmentedControl setImage:followersImage forSegmentAtIndex:3];
            
            FAKIonIcons *followingIcon = [FAKIonIcons ios7PeopleIconWithSize:15];
            [followingIcon addAttribute:NSForegroundColorAttributeName value:[UIColor whiteColor]];
            UIImage *followingImage = [followingIcon imageWithSize:CGSizeMake(15, 15)];
            [segmentedControl setImage:followingImage forSegmentAtIndex:4];
            
            
            [segmentedControl setFrame:CGRectMake(5, 5, viewHeader.frame.size.width-10 , 30)];
            [segmentedControl setSelectedSegmentIndex:0];
            [segmentedControl addTarget:self action:@selector(scopeChanged:) forControlEvents:UIControlEventValueChanged];
            [segmentedControl setTintColor:[SRStylesheet darkGrayColor]];
            [viewHeader addSubview:segmentedControl];
            
            self.indicatorLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 40, viewHeader.frame.size.width, 20)];
            [self.indicatorLabel setText:@"Tracks"];
            self.indicatorLabel.textAlignment = NSTextAlignmentCenter;
            self.indicatorLabel.textColor = [SRStylesheet darkGrayColor];
            [self.indicatorLabel setFont:[UIFont systemFontOfSize:13]];
            [viewHeader addSubview:self.indicatorLabel];
            
            // Seperator
            UILabel * seperator = [[UILabel alloc]initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 1)];
            seperator.backgroundColor = [SRStylesheet lightGrayColor];
            [viewHeader addSubview:seperator];
            self.scopeButton = segmentedControl;
            self.headerView = viewHeader;
            return viewHeader;
        }
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 65;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

-(void)cancelAllRequest {
    for (NSURLSessionTask * task in self.tasks) {
        [task cancel];
    }
}
// Here is where the Magic happens
-(void)scopeChanged:(UISegmentedControl*)sender {
    [self cancelAllRequest];
    [self setupPagination];
    [self.dataSourceArray removeAllObjects];
    [self.tableView reloadData];
    NSInteger index = sender.selectedSegmentIndex;
    if (index == 0) {
        [self fetchUsersSounds];
        [self.indicatorLabel setText:[NSString stringWithFormat:@"Tracks (%@)",self.displayedUser.track_count]];

    } else if(index == 1) {
        [self fetchUsersPlaylists];
        [self.indicatorLabel setText:[NSString stringWithFormat:@"Playlists (%@)",self.displayedUser.playlist_count]];

    } else if(index == 2) {
        [self fetchUsersLikes];
        [self.indicatorLabel setText:[NSString stringWithFormat:@"Likes (%@)",self.displayedUser.public_favorites_count]];

    } else if(index == 3) {
        [self fetchUsersFollowers];
        [self.indicatorLabel setText:[NSString stringWithFormat:@"People who follow %@",self.displayedUser.username]];

    } else if(index == 4) {
        [self fetchUsersFollowings];
        [self.indicatorLabel setText:[NSString stringWithFormat:@"People %@ follows",self.displayedUser.username]];

    }
}

-(void)fetchUsersSounds {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    self.isLoading = YES;
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/tracks.json",self.displayedUser.id] parameters:paramters
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
             [self.dataSourceArray addObject:[[Track alloc] initWithDictionary:trackInfo error:nil]];
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
    
    [self.tasks addObject:task];
}

-(void)fetchUsersPlaylists {
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/playlists.json",self.displayedUser.id] parameters:paramters
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
             [self.dataSourceArray addObject:[[Playlist alloc] initWithDictionary:trackInfo error:nil]];
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
    [self.tasks addObject:task];
    
}

-(void)fetchUsersLikes {
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    self.isLoading = YES;

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/favorites.json",self.displayedUser.id] parameters:paramters
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
             [self.dataSourceArray addObject:[[Track alloc] initWithDictionary:trackInfo error:nil]];
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
    
    [self.tasks addObject:task];
}

-(void)fetchUsersFollowers {
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/followers.json",self.displayedUser.id] parameters:paramters
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
             [self.dataSourceArray addObject:[[User alloc] initWithDictionary:trackInfo error:nil]];
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
    
    [self.tasks addObject:task];
}

-(void)fetchUsersFollowings {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    self.isLoading = YES;
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    [paramters setObject:self.limit forKey:@"limit"];
    [paramters setObject:self.offset forKey:@"offset"];
    
    NSURLSessionTask * task = [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"/users/%@/followings.json",self.displayedUser.id] parameters:paramters
    success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if ([responseObject count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }
         self.view.userInteractionEnabled = YES;
         for (NSDictionary * trackInfo in responseObject) {
             [self.dataSourceArray addObject:[[User alloc] initWithDictionary:trackInfo error:nil]];
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
    
    [self.tasks addObject:task];
    
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (indexPath.row < [self.dataSourceArray count]) {
        if (self.scopeButton.selectedSegmentIndex == 0) {
            Track * track = [self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
            if (track.streamable) {
                [delegate setupPlayerWithtrack:[self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
                [delegate setPlayingIndex:indexPath];
                [delegate setUpNext:self.dataSourceArray];
            } else {
                [TSMessage showNotificationWithTitle:@"This track is not streamable" type:TSMessageNotificationTypeError];
            }
            
        } else if (self.scopeButton.selectedSegmentIndex == 1) {
            [self performSegueWithIdentifier:@"showTracksOfPlaylist" sender:self];
        } else if (self.scopeButton.selectedSegmentIndex == 2) {
            Track * track = [self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
            if (track.streamable) {
                [delegate setupPlayerWithtrack:[self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row]];
                [delegate setPlayingIndex:indexPath];
                [delegate setUpNext:self.dataSourceArray];
            } else {
                [TSMessage showNotificationWithTitle:@"This track is not streamable" type:TSMessageNotificationTypeError];
            }
        } else if (self.scopeButton.selectedSegmentIndex == 3) {
            UserTableViewController * userC = [storyBoard instantiateViewControllerWithIdentifier:@"user"];
            User * user = [self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
            userC.user_id = user.id;
            [self.navigationController pushViewController:userC animated:YES];

        } else if (self.scopeButton.selectedSegmentIndex == 4) {
            UserTableViewController * userC = [storyBoard instantiateViewControllerWithIdentifier:@"user"];
            User * user = [self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
            userC.user_id = user.id;
            [self.navigationController pushViewController:userC animated:YES];

        }
    }
    else if (indexPath.row == [self.dataSourceArray count]) {
        LoadMoreTableViewCell * loadMoreCell = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        [loadMoreCell.loadMoreLabel setHidden:true];
        [loadMoreCell.loadingIndicator startAnimating];
        if (self.scopeButton.selectedSegmentIndex == 0) {
            [self fetchUsersSounds];
        } else if (self.scopeButton.selectedSegmentIndex == 1) {
            [self fetchUsersPlaylists];
        } else if (self.scopeButton.selectedSegmentIndex == 2) {
            [self fetchUsersLikes];
        } else if (self.scopeButton.selectedSegmentIndex == 3) {
            [self fetchUsersFollowers];
        } else if (self.scopeButton.selectedSegmentIndex == 4) {
            [self fetchUsersFollowings];
        }
        
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showTracksOfPlaylist"]) {
        PlaylistTracksListTableViewController * dvc = (PlaylistTracksListTableViewController*)segue.destinationViewController;
        dvc.currentPlaylist = [self.dataSourceArray objectAtIndex:[self.tableView indexPathForSelectedRow].row];
    }
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        if(!self.isLoading) {
            if (self.itemsAvailable) {
                LoadMoreTableViewCell * lmc = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self.dataSourceArray count] inSection:0]];
                [lmc.loadingIndicator startAnimating];
                if (self.scopeButton.selectedSegmentIndex == 0) {
                    [self fetchUsersSounds];
                } else if (self.scopeButton.selectedSegmentIndex == 1) {
                    [self fetchUsersPlaylists];
                } else if (self.scopeButton.selectedSegmentIndex == 2) {
                    [self fetchUsersLikes];
                } else if (self.scopeButton.selectedSegmentIndex == 3) {
                    [self fetchUsersFollowers];
                } else if (self.scopeButton.selectedSegmentIndex == 4) {
                    [self fetchUsersFollowings];
                }
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
