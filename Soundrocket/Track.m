//
//  Track.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "Track.h"
#import "TrackRespost.h"
@implementation Track
-(instancetype)initWithTrackRespost:(TrackRespost*)respost{
    if (self = [super init]) {
        _artwork_url = respost.artwork_url;
        _user = respost.user;
        _waveform_url = respost.waveform_url;
        _title = respost.title;
        _playback_count = respost.playback_count;
        _stream_url = respost.stream_url;
        _duration = respost.duration;
        _id = respost.id;
        _streamable = respost.streamable;
        _comment_count = respost.comment_count;
        _favoritings_count = respost.favoritings_count;
        _permalink_url = respost.permalink_url;
        _downloadable = respost.downloadable;
    }
    return  self;
}
@end
