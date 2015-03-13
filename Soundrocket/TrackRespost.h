//
//  TrackRespost.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"
#import "User.h"
@interface TrackRespost : JSONModel
@property (nonatomic,strong)NSString<Optional> * type;
@property (nonatomic,strong) User<Optional> * user;
@property (nonatomic,strong) NSString<Optional> * artwork_url;
@property (nonatomic,strong) NSString<Optional> * waveform_url;
@property (nonatomic,strong) NSString<Optional> * title;
@property (nonatomic,strong) NSString<Optional> * uri;
@property (nonatomic,strong) NSString<Optional> * permalink_url;
@property (nonatomic,strong) NSString<Optional> * stream_url;
@property (nonatomic,strong) NSNumber<Optional> * playback_count;
@property (nonatomic,strong) NSNumber<Optional> * comment_count;
@property (nonatomic,strong) NSNumber<Optional> * favoritings_count;
@property (nonatomic,strong) NSNumber<Optional> * duration;
@property (nonatomic,strong) NSNumber<Optional> * id;
@property (nonatomic,assign) BOOL downloadable;
@property (nonatomic) BOOL streamable;
@property (nonatomic,strong) NSNumber<Optional> * user_id;
@end
