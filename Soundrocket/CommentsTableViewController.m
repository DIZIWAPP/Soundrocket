//
//  CommentsTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <SVProgressHUD.h>
#import "CommentsTableViewController.h"
#import "CredentialStore.h"
#import "Comment.h"
#import "CommentTableViewCell.h"
#import "SoundtraceClient.h"
#import"UIImageView+AFNetworking.h"
#import "LoadMoreTableViewCell.h"
#import "AppDelegate.h"
#import "SoundtraceClient.h"
#import "SRStylesheet.h"
@interface CommentsTableViewController ()
@property(nonatomic,strong)NSMutableArray * comments;
@property(nonatomic,strong)CredentialStore * store;
@property (nonatomic,strong) UIActivityIndicatorView * activityIndicator;

// Pagination
@property (nonatomic,strong) NSNumber * limit;
@property (nonatomic,strong) NSNumber * offset;
@property (nonatomic,assign) BOOL isLoading;
@property (nonatomic,assign) BOOL itemsAvailable;
@property (nonatomic,strong) NSString * order;
@end

@implementation CommentsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.order = @"created_at";
    [self setup];
    [self setupPagination];
    [self setupToolbar];
    [self fetchForCommentsAndShowLoadingScreen:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [SRStylesheet lightGrayColor];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
}

#pragma mark - Table view data source

-(void)setup{
    self.comments = [[NSMutableArray alloc]init];
    self.store = [[CredentialStore alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"CommentTableViewCell" bundle:nil] forCellReuseIdentifier:@"CommentCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"LoadMoreTableViewCell" bundle:nil] forCellReuseIdentifier:@"loadmorecell"];
    [self.navigationItem setTitle:@"Comments"];
}

-(void)setupPagination {
    self.offset = @0;
    self.limit = @20;
    self.isLoading = NO;
    self.itemsAvailable = YES;
}

/**
 *  Reinits every Pagination Parameter and then fetches Tracks
 */
- (void)refresh {
    if (!self.isLoading) {
        self.offset = @0;
        [self.comments removeAllObjects];
        [self fetchForCommentsAndShowLoadingScreen:NO];
    }
}

-(void)fetchForCommentsAndShowLoadingScreen:(BOOL)showLoadingScreen {
    if (showLoadingScreen) {
        [self showLoadingScreen];
    }
    self.isLoading = YES;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];

    NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    [parameters setObject:self.limit forKey:@"limit"];
    [parameters setObject:self.offset forKey:@"offset"];
    
    if (self.store.authToken) {
        [parameters setObject:self.store.authToken forKey:@"oauth_token"];
        
    } else {
        [parameters setObject:[defaults objectForKey:@"access_token"] forKey:@"oauth_token"];
    }
    // Request all Activities
    [[SoundtraceClient sharedClient] GET:[NSString stringWithFormat:@"https://api.soundcloud.com/tracks/%@/comments.json?order=%@",self.currentTrack.id,self.order] parameters:parameters
                                 success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         if ([responseObject count] == 0) {
             self.itemsAvailable = NO;
         } else {
             self.itemsAvailable = YES;
         }
         for (NSDictionary * comment in responseObject) {
             Comment * commentObject = [[Comment alloc]initWithDictionary:comment error:nil];
             [self.comments addObject:commentObject];
         }
         
         long offset = [self.offset integerValue] + [self.limit integerValue];
         self.offset = [NSNumber numberWithLong:offset];
         [self.tableView reloadData];
         
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         [self hideLoadingScreen];
     }
     
     failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         [self.tableView reloadData];
         [self.refreshControl endRefreshing];
         self.isLoading = NO;
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         [self hideLoadingScreen];
     }];
    
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [self.comments count]+1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.comments count]) {
        CommentTableViewCell *cell = (CommentTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"CommentCell" forIndexPath:indexPath];
        
        // Configure the cell...
        Comment * currentComment = [self.comments objectAtIndex:indexPath.row];
        [cell.avatarImageView setImageWithURL:[NSURL URLWithString:currentComment.user.avatar_url] placeholderImage:nil];
        cell.commentBodyLabel.text = currentComment.body;
        cell.userNameLabel.text = currentComment.user.username;
        cell.timestampLabel.text = [NSString stringWithFormat:@"says at %@",[self getDateFromTimeStamp:[currentComment.timestamp floatValue]/1000]];
        return cell;
    } else if (indexPath.row >= [self.comments count]) {
        if (indexPath.row == ([self.comments count])) {
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


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 64;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView_
{
    CGFloat actualPosition = scrollView_.contentOffset.y;
    CGFloat contentHeight = scrollView_.contentSize.height - (self.tableView.frame.size.height);
    if (actualPosition >= contentHeight) {
        if(!self.isLoading) {
            if (self.itemsAvailable) {
                LoadMoreTableViewCell * lmc = (LoadMoreTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:[self.comments count] inSection:0]];
                [lmc.loadingIndicator startAnimating];
                [self fetchForCommentsAndShowLoadingScreen:NO];
            }
        }
    }
}

-(NSString*)getDateFromTimeStamp:(float)currentTime{
    // Setze das Zeit label
    
    NSUInteger h_current = (NSUInteger)currentTime / 3600;
    NSUInteger m_current = ((NSUInteger)currentTime / 60) % 60;
    NSUInteger s_current = (NSUInteger)currentTime % 60;
    
    
    NSString *formattedCurrent;
    if (h_current == 0) {
        formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu", (unsigned long)m_current, (unsigned long)s_current];
    } else {
        formattedCurrent = [NSString stringWithFormat:@"%02lu:%02lu:%02lu", (unsigned long)h_current, (unsigned long)m_current, (unsigned long)s_current];
    }
    
    return formattedCurrent;
}

#pragma mark - Editing stuff

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // Return NO if you do not want the specified item to be editable.
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    
    if (indexPath.row >= [self.comments count]) {
        return NO;
    } else {
        if ([delegate.currentUser.id integerValue] == [self.currentTrack.user.id integerValue]) {
            return YES;
        } else return NO;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [[UIApplication sharedApplication]beginIgnoringInteractionEvents];
        [SVProgressHUD showWithStatus:@"Removing comment from track"];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        Comment * comment= [self.comments objectAtIndex:indexPath.row];
        
        // Add Track to Playlist and then remove Viewcontroller from Top
        // Holen uns alle Tracks der Playlis
        NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
        [paramters setObject:self.store.authToken forKey:@"oauth_token"];
        
        [[SoundtraceClient sharedClient] DELETE:[NSString stringWithFormat:@"tracks/%@/comments/%@.json",self.currentTrack.id,comment.id] parameters:paramters
         
         
        success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             
             // Reinitializing Comments
             AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
             PlayerViewController * player = delegate.player;
             [player setUpComments:self.currentTrack];
             
             
             
             [self.comments removeObjectAtIndex:indexPath.row];
             [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [SVProgressHUD showSuccessWithStatus:@"Removed track from playlists"];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             
         }
         
        failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             // Fehlerbehandlung
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
             [[UIApplication sharedApplication]endIgnoringInteractionEvents];
             [SVProgressHUD showErrorWithStatus:@"Something went wrong, please try again"];
             
         }];
        
        
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}


- (void)setupToolbar {
    // Todo ..
}

@end
