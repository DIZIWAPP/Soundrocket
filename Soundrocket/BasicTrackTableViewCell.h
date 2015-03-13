//
//  BasicTrackTableViewCell.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MarqueeLabel.h>
#import <SWTableViewCell.h>

@interface BasicTrackTableViewCell : SWTableViewCell
@property (nonatomic,strong) IBOutlet UILabel * userNameLabel;
@property (nonatomic,strong) IBOutlet MarqueeLabel * trackNameLabel;
@property (nonatomic,strong) IBOutlet UIImageView * artworkImage;
@property (nonatomic,strong) IBOutlet UIImageView * repostedImageView;
@property (nonatomic,strong) IBOutlet MarqueeLabel * playbackCountLabel;
@property (weak, nonatomic) IBOutlet UIView *firstLayerViewPlaylist;
@property (weak, nonatomic) IBOutlet UIView *secondLayerViewPlaylist;
@end
