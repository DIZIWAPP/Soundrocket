//
//  ContentNavigationViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "ContentNavigationViewController.h"
#import "SRStylesheet.h"
@interface ContentNavigationViewController ()

@end

@implementation ContentNavigationViewController


-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.navigationBar.barTintColor = [SRStylesheet mainColor];
    self.navigationBar.tintColor = [UIColor whiteColor];
    
    [self.navigationBar
     setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationBar.translucent = NO;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
