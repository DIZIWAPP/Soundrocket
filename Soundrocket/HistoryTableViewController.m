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
#import "SRStylesheet.h"
#import "UserTableViewController.h"
@interface HistoryTableViewController () <BasicTrackTableViewCellDelegate>
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
    self.navigationController.navigationBar.barTintColor = [SRStylesheet lightGrayColor];
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
        cell.delegate = self;
        cell.data = track;
        
        return cell;
    } else {
        UITableViewCell * cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        if (indexPath.row == 0) {
            NSMutableAttributedString * shuffleText = [[[FAKIonIcons plusCircledIconWithSize:17]attributedString]mutableCopy];
            [shuffleText appendAttributedString:[[NSAttributedString alloc]initWithString:@"   Add to Playlist" attributes:nil]];
            cell.textLabel.attributedText = shuffleText;
            [cell.textLabel setTextColor:[SRStylesheet darkGrayColor]];
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
            [cell.textLabel setTextColor:[SRStylesheet darkGrayColor]];

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
        cellToSelect.backgroundColor = [SRStylesheet lightGrayColor];
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

#pragma mark - BasictracktableViewCellDelegate
-(void)userButtonPressedWithUserID:(NSNumber *)user_id{
    UserTableViewController * controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"user"];
    controller.user_id = user_id;
    [self.navigationController pushViewController:controller animated:YES];
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
