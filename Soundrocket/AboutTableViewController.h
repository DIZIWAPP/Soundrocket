//
//  AboutTableViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseTableViewController.h"
@interface AboutTableViewController : BaseTableViewController
@property (weak, nonatomic) IBOutlet UILabel *webSiteLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UILabel *libariesLabel;
@property (weak, nonatomic) IBOutlet UILabel *soundrocketNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *rateThisAppLabel;
@property (weak, nonatomic) IBOutlet UILabel *poweredByLabel;

@end
