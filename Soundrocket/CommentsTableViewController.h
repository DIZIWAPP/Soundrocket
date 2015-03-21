//
//  CommentsTableViewController.h
//  Soundrocket
//
//  Created by Sebastian Boldt on 15.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "Track.h"
@interface CommentsTableViewController : BaseViewController
@property (nonatomic,strong) Track * currentTrack;
@end
