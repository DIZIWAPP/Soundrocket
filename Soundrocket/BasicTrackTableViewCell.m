//
//  BasicTrackTableViewCell.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "BasicTrackTableViewCell.h"

@implementation BasicTrackTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.artworkImage.clipsToBounds = YES;
    self.artworkImage.layer.cornerRadius = 25;
    self.artworkImage.layer.borderColor = [[UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000] CGColor];
    self.artworkImage.layer.borderWidth = 1.0;
    
    self.firstLayerViewPlaylist.clipsToBounds = YES;
    self.firstLayerViewPlaylist.layer.cornerRadius = 25;
    self.firstLayerViewPlaylist.layer.borderColor = [[UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000] CGColor];
    self.firstLayerViewPlaylist.layer.borderWidth = 1.0;
    [self.firstLayerViewPlaylist setHidden:YES];
    
    self.secondLayerViewPlaylist.clipsToBounds = YES;
    self.secondLayerViewPlaylist.layer.cornerRadius = 25;
    self.secondLayerViewPlaylist.layer.borderColor = [[UIColor colorWithRed:1.000 green:0.180 blue:0.220 alpha:1.000] CGColor];
    self.secondLayerViewPlaylist.layer.borderWidth = 1.0;
    [self.secondLayerViewPlaylist setHidden:YES];
    
    // Configure the view for the selected state
}


-(void)prepareForReuse {
    self.accessoryType = UITableViewCellAccessoryNone;
    self.artworkImage.image = nil;
    self.userNameLabel.text = @"";
    self.firstLayerViewPlaylist.hidden = YES;
    self.secondLayerViewPlaylist.hidden = YES;
    self.backgroundColor = [UIColor whiteColor];
    [self hideUtilityButtonsAnimated:NO];
}

@end
