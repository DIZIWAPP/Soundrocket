//
//  UsersListTableViewController.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 27.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "UsersListTableViewController.h"
#import "CredentialStore.h"
#import "AppDelegate.h"
#import "UserTableViewCell.h"

@interface UsersListTableViewController ()
@property (nonatomic,strong) CredentialStore *store;
@property (nonatomic,strong) NSMutableArray * users;
@end

@implementation UsersListTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.store = [[CredentialStore alloc]init];
    [self.tableView registerNib:[UINib nibWithNibName:@"UserTableViewCell" bundle:nil] forCellReuseIdentifier:@"usercell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20; //self.users.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UserTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"usercell" forIndexPath:indexPath];
    
    return cell;
}

@end
