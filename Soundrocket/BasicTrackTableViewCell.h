//
//  BasicTrackTableViewCell.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel.h>
#import "Track.h"

@protocol BasicTrackTableViewCellDelegate <NSObject>
-(void)userButtonPressedWithUserID:(NSNumber*)user_id;
@end

@interface BasicTrackTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UIButton * userNameLabel;
@property (nonatomic,strong) IBOutlet MarqueeLabel * trackNameLabel;
@property (nonatomic,strong) IBOutlet UIImageView * artworkImage;
@property (nonatomic,strong) IBOutlet UIImageView * repostedImageView;
@property (nonatomic,strong) IBOutlet MarqueeLabel * playbackCountLabel;
@property (weak, nonatomic) IBOutlet UIView *firstLayerViewPlaylist;
@property (weak, nonatomic) IBOutlet UIView *secondLayerViewPlaylist;
@property (weak,nonatomic) id<BasicTrackTableViewCellDelegate> delegate;
//
@property (nonatomic,strong) id data;

@end
