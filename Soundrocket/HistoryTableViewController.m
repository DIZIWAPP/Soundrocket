//
//  HistoryTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "HistoryTableViewController.h"
#import "BasicTrackTableViewCell.h"
#import "AppDelegate.h"
#import"UIImageView+AFNetworking.h"
#import <FAKIonIcons.h>
@interface HistoryTableViewController ()
@property (nonatomic,strong)NSIndexPath * currentTrackIndexPath;
@end

@implementation HistoryTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"BasicTrackTableViewCell" bundle:nil] forCellReuseIdentifier:@"basictrackcell"];
    //self.navigationItem.rightBarButtonItem =  self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithWhite:0.500 alpha:1.000];
    [self.navigationController.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationController.navigationBar.translucent = NO;
    //[self.tableView setEditing:YES animated:YES];
}

-(void)shuffleSwitchChanged:(UISwitch*)sender {
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:[NSNumber numberWithBool:sender.isOn] forKey:@"shuffle"];
    [defaults synchronize];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (section == 1) {
        return [delegate.upNext count];
    }
    else return 1; // Raise to 2 to show shuffle Button
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        BasicTrackTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"basictrackcell" forIndexPath:indexPath];
        AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
        
        Track * track = [delegate.upNext objectAtIndex:indexPath.row];
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
        
        if (delegate.playingIndex.row == indexPath.row) {
            cell.backgroundColor = [UIColor colorWithWhite:0.860 alpha:1.000];
            self.currentTrackIndexPath = indexPath;
        }
        cell.playbackCountLabel.attributedText = playbackcount;
        
        return cell;
    } else {
        UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            NSMutableAttributedString * shuffleText = [[[FAKIonIcons plusCircledIconWithSize:17]attributedString]mutableCopy];
            [shuffleText appendAttributedString:[[NSAttributedString alloc]initWithString:@"   Add to Playlist" attributes:nil]];
            cell.textLabel.attributedText = shuffleText;
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else {
            NSMutableAttributedString * shuffleText = [[[FAKIonIcons shuffleIconWithSize:17]attributedString]mutableCopy];
            [shuffleText appendAttributedString:[[NSAttributedString alloc]initWithString:@"   Shuffle" attributes:nil]];
            cell.textLabel.attributedText = shuffleText;
            cell.accessoryType = UITableViewCellAccessoryNone;
            UISwitch * shuffleSwitch = [[UISwitch alloc]initWithFrame:cell.accessoryView.frame];
            [shuffleSwitch addTarget:self action:@selector(shuffleSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
            NSNumber * shuffle = [defaults objectForKey:@"shuffle"];
            [shuffleSwitch setOn:[shuffle boolValue]];

            cell.accessoryView = shuffleSwitch;
            self.shuffleSwitch = shuffleSwitch;
            [cell.textLabel setTextColor:[UIColor darkGrayColor]];

        }
        return  cell;
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        return @"Up next";
    } else return nil;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            [self performSegueWithIdentifier:@"showAddToPlaylist" sender:self];
        }
    }
    else if (indexPath.section == 1) {
        Track * track = [delegate.upNext objectAtIndex:indexPath.row];
        
        BasicTrackTableViewCell * cellToDeselect = (BasicTrackTableViewCell*)[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForItem:self.currentTrackIndexPath.row inSection:1]];
        cellToDeselect.backgroundColor = [UIColor whiteColor];
        
        BasicTrackTableViewCell * cellToSelect = (BasicTrackTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
        cellToSelect.backgroundColor = [UIColor colorWithWhite:0.860 alpha:1.000];
        [delegate setPlayingIndex:indexPath];
        [delegate setupPlayerWithtrack:track];
        self.currentTrackIndexPath = indexPath;

    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return  45;
    } else
    return 80;
}

/*
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 0){
        return NO;
    }
    return YES;
}

-(void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath{
    
}

-(BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath{
    return NO;
}*/
@end
