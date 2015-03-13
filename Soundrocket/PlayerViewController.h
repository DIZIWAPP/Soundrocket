//
//  PlayerViewController.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//
#import <MarqueeLabel.h>
#import <UIKit/UIKit.h>
#import "Track.h"
@interface PlayerViewController : UIViewController
@property (nonatomic,strong) Track * currentTrack;
+ (instancetype)sharedPlayer;
@property (weak, nonatomic) IBOutlet MarqueeLabel *trackIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistLabel;
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIImageView *waveformImageView;
@property (weak,nonatomic) IBOutlet UIImageView * backGroundView;
@property (weak, nonatomic) IBOutlet UIView * commentsView;
@property (weak, nonatomic) IBOutlet UILabel * noCommentsLabel;
@property (weak, nonatomic) IBOutlet UIButton * likeButton;
@property (weak, nonatomic) IBOutlet UILabel * durationLabel;
@property (weak, nonatomic) IBOutlet UIImageView *userCommentedImageView;
@property (weak, nonatomic) IBOutlet MarqueeLabel *currentCommentLabel;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (weak, nonatomic) IBOutlet UILabel *commentIconLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextCommentButton;
@property (weak, nonatomic) IBOutlet UIButton *lastCommentButton;
@property (weak, nonatomic) IBOutlet UIView *commentView;
- (IBAction)lastCommentButtonPressed:(id)sender;
- (IBAction)nextCommentButtonPressed:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *lastTrackButton;
@property (weak, nonatomic) IBOutlet UIButton *nextTrackButton;
@property (weak, nonatomic) IBOutlet MarqueeLabel *userNameLabel;

- (IBAction)playPauseButtonPressed:(id)sender;
-(void)initiatePlayback; // Should be called by Miniplayer to start playback
-(void)unsubScribe;
-(void)stop;
-(void)play;
-(void)pause;
-(IBAction)favButtonPressed:(id)sender;
-(void)playNextTrack;
-(void)playLastTrack;
-(void)setUpComments:(Track*)track;

@end
