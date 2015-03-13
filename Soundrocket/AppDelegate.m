//
//  AppDelegate.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 19.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//
#import <MBProgressHUD.h>
#import "AppDelegate.h"
#import "RootViewController.h"
#import "LoginTableViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import"UIImageView+AFNetworking.h"
#import "Track.h"
#import "TrackRespost.h"
#import "CredentialStore.h"
#import "SoundtraceClient.h"
#import "Constants.h"
#import <TSMessage.h>
#import <SVProgressHUD.h>


@interface AppDelegate ()
@property(nonatomic,assign) BOOL isLoggedIn;
@property(nonatomic,strong) CredentialStore * store;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptios

{
    [self setup];
    [self setupMixpanel];
    [self setupUI];
    [self setUpAudioPlayback];
    [self setupReceiveRemoteControlEvents];
    [self setFirstViewController];
    [Fabric with:@[CrashlyticsKit]];
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)setupMixpanel {
    [Mixpanel sharedInstanceWithToken:MIXPANEL_TOKEN];
}

-(void)setFirstViewController {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    // Login state will be fetched from Credentialstore
    
    if (self.isLoggedIn) {
        LoginTableViewController * rootLogin = [storyBoard instantiateViewControllerWithIdentifier:@"loggingIn"];
        self.window.rootViewController  = rootLogin;
        [self getUserData];
    } else  {
        LoginTableViewController * rootLogin = [storyBoard instantiateViewControllerWithIdentifier:@"Login"];
        self.window.rootViewController  = rootLogin;
    }
}


// Speichert aktuellen User in delegate.currentUser
-(void)getUserData {
    
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:self.store.authToken forKey:@"access_token"];
    [defaults synchronize];
    
    [[SoundtraceClient sharedClient] GET:@"/me.json" parameters:paramters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSError * error = nil;
         AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
         User *currentUser = [[User alloc]initWithDictionary:responseObject error:&error];
         delegate.currentUser = currentUser;
         
         UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         RootViewController * root = [storyBoard instantiateViewControllerWithIdentifier:@"Root"];
         self.window.rootViewController  = root;
         
     }
     
                                 failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
         LoginTableViewController * rootLogin = [storyBoard instantiateViewControllerWithIdentifier:@"Login"];
         self.window.rootViewController  = rootLogin;
         [TSMessage showNotificationInViewController:self.window.rootViewController
                                               title:@"Something went wrong, please try again"
                                            subtitle:nil
                                                type:TSMessageNotificationTypeError
                                            duration:2.0
                                canBeDismissedByUser:YES];
         
         
     }];
}


-(void)setup {
    self.upNext = [[NSMutableArray alloc]init];
    self.history = [[NSMutableArray alloc]init];
    self.playingIndex = 0;
    self.store = [[CredentialStore alloc]init];
    
    self.currentUser = [[User alloc]init];
    self.isLoggedIn = self.store.isLoggedIn;
}

-(void)setupUI{
    
    self.window = [[UIWindow alloc]initWithFrame:[[UIScreen mainScreen]bounds]]; // Initializing the window
    [self.window setBackgroundColor:[UIColor whiteColor]];
    
    [SVProgressHUD setBackgroundColor:[UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    UIColor * soundrocketRed = [UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000];
    UIPageControl *pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor =  [UIColor grayColor];
    pageControl.backgroundColor = [UIColor clearColor];
    pageControl.currentPageIndicatorTintColor = soundrocketRed;
}

-(void)setupReceiveRemoteControlEvents {
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    [self becomeFirstResponder];
}

-(void)setUpAudioPlayback {
    // Setup Audio Stuff for  App
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    NSError *setCategoryError = nil;
    BOOL success = [audioSession setCategory:AVAudioSessionCategoryPlayback error:&setCategoryError];
    if (!success) { /* handle the error condition */ }
    
    NSError *activationError = nil;
    success = [audioSession setActive:YES error:&activationError];
    if (!success) { /* handle the error condition */ }
}


-(void)remoteControlReceivedWithEvent:(UIEvent *)receivedEvent
{
    PlayerViewController * player = self.player;

    if (receivedEvent.type == UIEventTypeRemoteControl)
    {
        switch (receivedEvent.subtype)
        {
            case UIEventSubtypeRemoteControlPlay:
                //  play the video
                [player play];
                break;
                
            case  UIEventSubtypeRemoteControlPause:
                // pause the video
                [player pause];
                break;
                
            case  UIEventSubtypeRemoteControlNextTrack:
                // to change the video
                [player playNextTrack];
                break;
                
            case  UIEventSubtypeRemoteControlPreviousTrack:
                // to play the privious video
                [player playLastTrack];
                break;
                
            default:
                break;
        }
    }
}


-(void)setupPlayerWithtrack:(Track*)currentTrack {

    self.miniPlayer.artistNameLabel.text = currentTrack.user.username;
    self.miniPlayer.titleLabel.text = currentTrack.title;
    NSString * largeUrl = nil;
    if (currentTrack.artwork_url) {
        largeUrl = [currentTrack.artwork_url stringByReplacingOccurrencesOfString:@"large" withString:@"t500x500"];
    } else {
        largeUrl = currentTrack.user.avatar_url;
    }
    [self.miniPlayer.coverImageView setImageWithURL:[NSURL URLWithString:largeUrl] placeholderImage:[UIImage imageNamed:@"music"]];
    
    // Setup PlayerViewController
    PlayerViewController * player = self.player;
    [player setCurrentTrack:currentTrack];

    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    //[UIView setAnimationDidStopSelector:@selector(callFunctionAfterAnimation)]; //this would call a method named - (void)callFunctionAfterAnimation; inside this class
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    
    self.miniPlayer.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height -50,[UIScreen mainScreen].bounds.size.width, 50);
    
    
    [UIView commitAnimations];
    
}

-(void)setupPlayerWithtrackRepost:(TrackRespost*)currentTrack {
    
    self.miniPlayer.artistNameLabel.text = currentTrack.user.username;
    self.miniPlayer.titleLabel.text = currentTrack.title;
    [self.miniPlayer.coverImageView setImageWithURL:[NSURL URLWithString:currentTrack.artwork_url] placeholderImage:nil];
    
    // Setup PlayerViewController
    PlayerViewController * player = self.player;
    [player setCurrentTrack:[[Track alloc]initWithTrackRespost:currentTrack]];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    [UIView beginAnimations:nil context:context];
    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    //[UIView setAnimationDidStopSelector:@selector(callFunctionAfterAnimation)]; //this would call a method named - (void)callFunctionAfterAnimation; inside this class
    [UIView setAnimationDuration: .5];
    [UIView setAnimationDelegate: self];
    
    self.miniPlayer.frame = CGRectMake(0,[UIScreen mainScreen].bounds.size.height -50,[UIScreen mainScreen].bounds.size.width, 50);
    
    
    [UIView commitAnimations];
}



- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}




#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.sebastianboldt.Soundtrace" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Soundtrace" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Soundtrace.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
