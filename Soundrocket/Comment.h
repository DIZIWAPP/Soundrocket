//
//  Comment.h
//  Soundtrace
//
//  Created by Sebastian Boldt on 21.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "JSONModel.h"
#import "User.h"
@interface Comment : JSONModel
@property (nonatomic,strong)NSString<Optional> * type;
@property (nonatomic,strong)NSString<Optional> * body;
@property (nonatomic,strong)NSNumber<Optional> * timestamp;
@property (nonatomic,strong)NSNumber<Optional> * id;
@property (nonatomic,strong)User<Optional> * user;

@end

/*{
 body = Support;
 "created_at" = "2014/12/23 20:51:40 +0000";
 id = 214310377;
 kind = comment;
 timestamp = 0;
 "track_id" = 182668912;
 uri = "https://api.soundcloud.com/comments/214310377";
 user =     {
 "avatar_url" = "https://i1.sndcdn.com/avatars-000102164341-q3us5s-large.jpg";
 id = 111621086;
 kind = user;
 "last_modified" = "2014/12/21 14:39:39 +0000";
 permalink = undergroundhouseuk;
 "permalink_url" = "http://soundcloud.com/undergroundhouseuk";
 uri = "https://api.soundcloud.com/users/111621086";
 username = "Underground House UK";
 };
 "user_id" = 111621086;
 } */