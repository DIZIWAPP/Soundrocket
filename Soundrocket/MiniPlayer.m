//
//  MiniPlayer.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "MiniPlayer.h"
#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "SRStylesheet.h"
@implementation MiniPlayer


-(void)drawRect:(CGRect)rect {
    //NSLog(@"************************SCROLLBAR CREATED************************");
    if (!self.scrollbarMiniPlayer) {
        self.scrollbarMiniPlayer = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 2, 4)];
    }
    self.scrollbarMiniPlayer.backgroundColor = [SRStylesheet mainColor];
    [self addSubview:self.scrollbarMiniPlayer];
}
-(IBAction)playButtonPressed:(id)sender {
    
    
    // Hier noch überprüfen ob track schon geliked wurde oder nicht
    [UIView animateWithDuration:1.0
                          delay: 0
         usingSpringWithDamping: 0.4
          initialSpringVelocity: .5
                        options: 0
                     animations: ^
     {
         
         self.playButton.transform = CGAffineTransformMakeScale(0.5, 0.5);
         self.playButton.transform = CGAffineTransformMakeScale(1.0, 1.0);
     }
                     completion: nil
     ];
    
    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    PlayerViewController * player =  delegate.player;
    [player initiatePlayback];
}
@end
