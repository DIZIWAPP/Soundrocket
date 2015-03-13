//
//  LoadMoreTableViewCell.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 22.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoadMoreTableViewCell : UITableViewCell
@property (nonatomic,strong) IBOutlet UILabel * loadMoreLabel;
@property (nonatomic,strong) IBOutlet UIActivityIndicatorView * loadingIndicator;
@end
