//
//  MenuTableViewCell.m
//  Soundrocket
//
//  Created by Sebastian Boldt on 09.01.15.
//  Copyright (c) 2015 sebastianboldt. All rights reserved.
//

#import "MenuTableViewCell.h"

@implementation MenuTableViewCell

- (void)awakeFromNib {
    // Initialization code
    UIView *selectionColor = [[UIView alloc] init];
    selectionColor.backgroundColor = [UIColor whiteColor];
    self.selectedBackgroundView = selectionColor;
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
