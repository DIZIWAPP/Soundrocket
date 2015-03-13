//
//  User.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"

@interface User : JSONModel
@property (nonatomic,strong) NSString<Optional> * avatar_url;
@property (nonatomic,strong) NSString<Optional> * country;
@property (nonatomic,strong) NSString<Optional> * city;
@property (nonatomic,strong) NSNumber<Optional> *id;
@property (nonatomic,strong) NSString<Optional> * username;
@property (nonatomic,strong) NSNumber<Optional> * public_favorites_count;
@property (nonatomic,strong) NSNumber<Optional> * track_count;
@property (nonatomic,strong) NSNumber<Optional> * playlist_count;

@property (nonatomic,strong) NSString<Optional> * followers_count;
@property (nonatomic,strong) NSString<Optional> * followings_count;
@end

/*

 {
 "avatar_url" = "https://i1.sndcdn.com/avatars-000069586811-nskz6z-large.jpg";
 city = ny;
 country = "United States";
 description = "NuLu Music /  Vega Records";
 "discogs_name" = "<null>";
 "first_name" = antonello;
 "followers_count" = 1077;
 "followings_count" = 473;
 "full_name" = "antonello coghe";
 id = 2344;
 kind = user;
 "last_modified" = "2014/02/13 03:23:34 +0000";
 "last_name" = coghe;
 "myspace_name" = "<null>";
 online = 0;
 permalink = antonello;
 "permalink_url" = "http://soundcloud.com/antonello";
 plan = Free;
 "playlist_count" = 0;
 "public_favorites_count" = 2;
 subscriptions =     (
 );
 "track_count" = 1;
 uri = "https://api.soundcloud.com/users/2344";
 username = "Antonello Coghe";
 website = "http://www.nulumusic.com";
 "website_title" = "";
 } */
