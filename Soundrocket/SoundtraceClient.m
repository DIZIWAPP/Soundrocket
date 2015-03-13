//
//  RomoClient.m
//  RomoApp
//
//  Created by Sebastian Boldt on 29.04.14.
//  Copyright (c) 2014 Sebastian Boldt. All rights reserved.
//

#import "SoundtraceClient.h"
#import "AppDelegate.h"
#import "CredentialStore.h"

@interface SoundtraceClient ()
@property (nonatomic, strong) NSString *accessToken;
@end

@implementation SoundtraceClient
+ (instancetype)sharedClient {
	static SoundtraceClient *_sharedClient = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    NSString *hostString = @"https://api.soundcloud.com";

	    _sharedClient = [[SoundtraceClient alloc] initWithBaseURL:[NSURL URLWithString:hostString]];
	    _sharedClient.securityPolicy = [AFSecurityPolicy defaultPolicy];
	    _sharedClient.responseSerializer = [AFJSONResponseSerializer serializer];
	    _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
	    
	});
	return _sharedClient;
}

@end
