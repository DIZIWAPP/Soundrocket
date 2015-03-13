//
//  CredentialStore.h
//  RomoApp
//
//  Created by Sebastian Boldt on 07.05.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CredentialStore : NSObject
- (BOOL)isLoggedIn;
- (void)clearSavedCredentials;
- (NSString *)authToken;
- (void)setAuthToken:(NSString *)authToken;
- (NSString *)refreshToken;
- (void)setRefreshToken:(NSString *)refreshToken;
@end
