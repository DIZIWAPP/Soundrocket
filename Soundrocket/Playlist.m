//
//  Playlist.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "Playlist.h"

@implementation Playlist
-(instancetype)initWithPlayListRepost:(PlaylistRespost*)repost {
    if (self = [super init]) {
        _title = repost.title;
        _avatar_url = repost.avatar_url;
        _artwork_url = repost.artwork_url;
        _user = repost.user;
        _url  = repost.url;
        _uri = repost.uri;
        _sharing = repost.sharing;
        _track_count = repost.track_count;
    }
    
    return  self;
}
@end
