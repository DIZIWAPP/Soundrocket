//
//  HistoryTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 26.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryTableViewController : UITableViewController
@property (weak, nonatomic) IBOutlet UISwitch *shuffleSwitch;
@property (weak, nonatomic) IBOutlet UILabel *shuffleIcon;

@end
