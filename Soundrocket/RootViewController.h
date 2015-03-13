//
//  RootViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RESideMenu.h>
#import "MiniPlayer.h"
@interface RootViewController : RESideMenu <RESideMenuDelegate>
@property (nonatomic,strong) MiniPlayer * miniPlayer;
@end
