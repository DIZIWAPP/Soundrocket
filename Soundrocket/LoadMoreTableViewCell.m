//
//  LoadMoreTableViewCell.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 22.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "LoadMoreTableViewCell.h"

@implementation LoadMoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)prepareForReuse {
    [super prepareForReuse];
    [self.loadMoreLabel setHidden:YES];
}

@end
