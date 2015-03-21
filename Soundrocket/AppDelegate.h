//
//  AppDelegate.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 19.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//
// 45E0A9 FARBCODE GREEN HEX
#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "User.h"
#import "MiniPlayer.h"
#import "PlayerViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import <Mixpanel.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic,strong) User * currentUser;                // Stores the current logged in User
@property (nonatomic,strong) MiniPlayer * miniPlayer;           // A Reference to the miniplayer
@property (nonatomic,strong) PlayerViewController * player;     // stores the Fullscreen Player
@property (nonatomic,strong) NSMutableArray * upNext;           // Stores up Next Tracks inside an Array
@property (nonatomic,strong) NSIndexPath* playingIndex;         // Indexpath of currently paying Track
@property (nonatomic,strong) NSMutableArray * history;          // Array of Tracks played in the past

-(void)setupPlayerWithtrack:(Track*)currentTrack;               // Sets up players with Track
-(void)setupPlayerWithtrackRepost:(TrackRespost*)currentTrack;  // Sets up player with Track Repost

@end

