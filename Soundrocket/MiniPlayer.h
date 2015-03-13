//
//  MiniPlayer.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel.h>
@interface MiniPlayer : UIView
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet MarqueeLabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *artistNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;
@property (nonatomic,strong) UIView * scrollbarMiniPlayer;
-(IBAction)playButtonPressed:(id)sender;
@end
