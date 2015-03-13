//
//  Track.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

/**
 *  2014-12-21 00:32:17.737 Soundtrace[3615:975773] Unable to load string table file: CFBundle 0x14d316c0 </private/var/mobile/Containers/Bundle/Application/D1289714-EE4C-4CD6-854C-B5FBCC31D502/Soundtrace.app> (executable, loaded) / Main: The operation couldn’t be completed. (Cocoa error 3840.)
 2014-12-21 00:32:17.956 Soundtrace[3615:975773] Warning once only: Detected a case where constraints ambiguously suggest a height of zero for a tableview cell's content view. We're considering the collapse unintentional and using standard height instead.
 (lldb) po [responseObject count]
 0x0000000a
 
 (lldb) po responseObject
 <__NSCFArray 0x14e92d40>(
 {
 "artwork_url" = "https://i1.sndcdn.com/artworks-000098855160-8ro138-large.jpg";
 "attachments_uri" = "https://api.soundcloud.com/tracks/179445588/attachments";
 bpm = "<null>";
 "comment_count" = 7;
 commentable = 1;
 "created_at" = "2014/12/01 13:03:18 +0000";
 description = "Release: 19.12.2014\nLabel: Get Physical Music / Poesie Musik\n\nTracklist:\n01. Falling (w/ Anna Leyne) (Original Mix)\n02. Finding The Others (Original Mix)\n03. Instincts";
 "download_count" = 0;
 downloadable = 0;
 duration = 204087;
 "embeddable_by" = all;
 "favoritings_count" = 94;
 genre = "get physical";
 id = 179445588;
 isrc = "<null>";
 "key_signature" = "<null>";
 kind = track;
 "label_id" = "<null>";
 "label_name" = "Get Physical Music / Poesie Musik";
 "last_modified" = "2014/12/19 19:07:17 +0000";
 license = "all-rights-reserved";
 "original_content_size" = 53978444;
 "original_format" = wav;
 permalink = "falling-w-anna-leyne-original-mix-snippet";
 "permalink_url" = "http://soundcloud.com/jonas-woehl/falling-w-anna-leyne-original-mix-snippet";
 "playback_count" = 2297;
 policy = ALLOW;
 "purchase_title" = "<null>";
 "purchase_url" = "http://www.beatport.com/track/falling-feat-anna-leyne-original-mix/6069975";
 release = "<null>";
 "release_day" = 19;
 "release_month" = 12;
 "release_year" = 2014;
 sharing = public;
 state = finished;
 "stream_url" = "https://api.soundcloud.com/tracks/179445588/stream";
 streamable = 1;
 "tag_list" = "\"poesie musik\"";
 title = "Falling (w/ Anna Leyne) (Original Mix) - snippet";
 "track_type" = "<null>";
 uri = "https://api.soundcloud.com/tracks/179445588";
 "user_favorite" = 1;
 "user_id" = 878561;
 "user_playback_count" = 1;
 "video_url" = "<null>";
 "waveform_url" = "https://w1.sndcdn.com/PNE2iyErLVOW_m.png";
 
 user =     {
    "avatar_url" = "https://i1.sndcdn.com/avatars-000102289456-1fl3km-large.jpg";
    id = 878561;
    kind = user;
    "last_modified" = "2014/12/19 19:06:03 +0000";
    permalink = "jonas-woehl";
    "permalink_url" = "http://soundcloud.com/jonas-woehl";
    uri = "https://api.soundcloud.com/users/878561";
    username = "Jonas Woehl";
 };
 

 },
*/
#import <JSONModel.h>
#import "User.h"
#import "TrackRespost.h"
@interface Track : JSONModel
@property (nonatomic,strong) User<Optional> * user;
@property (nonatomic,strong) NSString<Optional> * artwork_url;
@property (nonatomic,strong) NSString<Optional> * uri;
@property (nonatomic,strong) NSString<Optional> * permalink_url;
@property (nonatomic,strong) NSString<Optional> * waveform_url;
@property (nonatomic,strong) NSString<Optional> * title;
@property (nonatomic,strong) NSString<Optional> * stream_url;
@property (nonatomic,strong) NSNumber<Optional> * playback_count;
@property (nonatomic,strong) NSNumber<Optional> * comment_count;
@property (nonatomic,strong) NSNumber<Optional> * favoritings_count;
@property (nonatomic,strong) NSNumber<Optional> * id;
@property (nonatomic,strong) NSNumber<Optional> * duration;
@property (nonatomic,assign) BOOL downloadable;
@property (nonatomic,assign) BOOL streamable;
-(instancetype)initWithTrackRespost:(TrackRespost*)respost;
@end
