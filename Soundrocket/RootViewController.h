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
/**
 *  We create our custom Transition between the two ViewControllers
 *  the BouncePresentAnimationController is responsible for this
 * it implements the UIViewControllerAnimatedTransitioning Protocol which hast 2 methods
 * transitionDuration & animate Transition
 */
@interface BouncePresentAnimationController : NSObject<UIViewControllerAnimatedTransitioning>
@end

@interface RootViewController : RESideMenu <RESideMenuDelegate,UIViewControllerTransitioningDelegate>
@property (nonatomic,strong) MiniPlayer * miniPlayer;
@property (nonatomic,strong) BouncePresentAnimationController *bouncePresentationController;
@end


