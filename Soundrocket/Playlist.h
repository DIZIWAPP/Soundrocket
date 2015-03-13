//
//  Playlist.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"
#import "User.h"
#import "PlaylistRespost.h"

@interface Playlist : JSONModel
@property (nonatomic,strong) NSString<Optional> * title;
@property (nonatomic,strong) NSString<Optional> * avatar_url;
@property (nonatomic,strong) NSString<Optional> * artwork_url;
@property (nonatomic,strong) User<Optional> * user;
@property (nonatomic,strong) NSString<Optional> * url;
@property (nonatomic,strong) NSString<Optional> * sharing;
@property (nonatomic,strong) NSNumber<Optional> * track_count;
@property (nonatomic,strong) NSNumber<Optional> * id;
@property (nonatomic,strong) NSString<Optional> * tracks_uri;
@property (nonatomic,strong) NSString<Optional> * uri;

-(instancetype)initWithPlayListRepost:(PlaylistRespost*)repost;
@end



/*
 {
 "created_at" = "2014/12/18 19:44:48 +0000";
 origin =     {
 "artwork_url" = "<null>";
 "created_at" = "2014/12/18 19:44:48 +0000";
 "created_with" = "<null>";
 description = "<null>";
 downloadable = "<null>";
 duration = 7271263;
 ean = "<null>";
 "embeddable_by" = all;
 genre = "<null>";
 id = 65250228;
 kind = playlist;
 "label_name" = "<null>";
 "last_modified" = "2014/12/18 19:44:48 +0000";
 license = "all-rights-reserved";
 "likes_count" = 31;
 permalink = "sounds-we-like";
 "permalink_url" = "https://soundcloud.com/soukie-windish/sets/sounds-we-like";
 "playlist_type" = "<null>";
 "purchase_title" = "<null>";
 "purchase_url" = "<null>";
 release = "<null>";
 "release_day" = "<null>";
 "release_month" = "<null>";
 "release_year" = "<null>";
 "reposts_count" = 6;
 "secret_token" = "s-azToj";
 "secret_uri" = "https://api.soundcloud.com/playlists/65250228?secret_token=s-azToj";
 sharing = public;
 streamable = 1;
 "tag_list" = "";
 title = "Sounds we like";
 "track_count" = 1;
 "tracks_uri" = "https://api.soundcloud.com/playlists/65250228/tracks";
 type = "<null>";
 uri = "https://api.soundcloud.com/playlists/65250228";
 user =         {
 "avatar_url" = "https://i1.sndcdn.com/avatars-000108982403-e2cmz6-large.jpg";
 id = 236701;
 kind = user;
 "last_modified" = "2014/12/08 21:32:39 +0000";
 permalink = "soukie-windish";
 "permalink_url" = "http://soundcloud.com/soukie-windish";
 uri = "https://api.soundcloud.com/users/236701";
 username = "Soukie&Windish";
 };
 "user_id" = 236701;
 };
 tags = "<null>";
 type = playlist;
 }
 */