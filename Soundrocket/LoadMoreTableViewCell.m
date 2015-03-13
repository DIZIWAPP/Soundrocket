//
//  LoadMoreTableViewCell.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 22.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "LoadMoreTableViewCell.h"
#import "SRStylesheet.h"
@implementation LoadMoreTableViewCell

- (void)awakeFromNib {
    // Initialization code
    self.loadingIndicator.tintColor = [SRStylesheet mainColor];
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
