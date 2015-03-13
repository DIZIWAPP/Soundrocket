//
//  LibariesTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 24.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "LibariesTableViewController.h"

@interface LibariesTableViewController ()
@property (nonatomic,strong) NSMutableArray * libaries;
@end

@implementation LibariesTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupLibaries];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}


-(void)setupLibaries {
    /*
     pod 'RESideMenu', '~> 4.0.7'
     pod 'AFNetworking'
     pod 'JSONModel'
     pod 'SSKeychain'
     pod 'MarqueeLabel'
     pod 'TSMessages'
     pod 'MBProgressHUD', '~> 0.8'
     pod 'FontAwesomeKit', '~> 2.1.0'
     pod 'SVProgressHUD'
     */
    self.libaries = [[NSMutableArray alloc]init];
    [self.libaries addObject:@"RESideMenu"];
    [self.libaries addObject:@"AFNetworking"];
    [self.libaries addObject:@"JSONModel"];
    [self.libaries addObject:@"SSKeychain"];
    [self.libaries addObject:@"MarqueeLabel"];
    [self.libaries addObject:@"TSMessages"];
    [self.libaries addObject:@"MBProgressHUD"];
    [self.libaries addObject:@"FontAwesomeKit"];
    [self.libaries addObject:@"SVProgressHUD"];
    [self.libaries addObject:@"SWTableViewCell"];
    
    [self.tableView reloadData];

}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.libaries count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = [self.libaries objectAtIndex:indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:12];
    cell.textLabel.textColor = [UIColor lightGrayColor];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/romaonthego/RESideMenu"];
        [[UIApplication sharedApplication]openURL:url];
    }
    else if (indexPath.row == 1) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/AFNetworking/AFNetworking"];
        [[UIApplication sharedApplication]openURL:url];
    }
    else if (indexPath.row == 2) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/icanzilb/JSONModel"];
        [[UIApplication sharedApplication]openURL:url];
    }
    else if (indexPath.row == 3) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/soffes/sskeychain"];
        [[UIApplication sharedApplication]openURL:url];
    }
    else if (indexPath.row == 4) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/cbpowell/MarqueeLabel"];
        [[UIApplication sharedApplication]openURL:url];
    }
    else if (indexPath.row == 5) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/toursprung/TSMessages"];
        [[UIApplication sharedApplication]openURL:url];
    }
    else if (indexPath.row == 6) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/jdg/MBProgressHUD"];
        [[UIApplication sharedApplication]openURL:url];
    } else if (indexPath.row == 7) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/PrideChung/FontAwesomeKit"];
        [[UIApplication sharedApplication]openURL:url];
    } else if (indexPath.row == 8) {
        NSURL * url = [NSURL URLWithString:@"https://github.com/TransitApp/SVProgressHUD"];
        [[UIApplication sharedApplication]openURL:url];
    } else if (indexPath.row == 9){
        NSURL * url = [NSURL URLWithString:@"https://github.com/CEWendel/SWTableViewCell"];
        [[UIApplication sharedApplication]openURL:url];
    }
}
@end
