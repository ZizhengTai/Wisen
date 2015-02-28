//
//  User.m
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Firebase/Firebase.h>
#import <GeoFire/GeoFire.h>
#import "User.h"
#import "Request.h"

NSString *const kMentorFoundNotification = @"kMentorFoundNotification";

@interface User ()

@property (strong, nonatomic) FAuthData *authData;
@property (strong, nonatomic) Firebase *userRef;
@property (strong, nonatomic) GeoFire *geoFire;
@property (strong, nonatomic) NSMutableDictionary *handleQueryPairs;

@end

@implementation User

- (instancetype)initWithAuthData:(FAuthData *)authData {
    self = [super init];
    if (self) {
        _authData = authData;
        _userRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@", authData.uid]];
        _geoFire = [[GeoFire alloc] initWithFirebaseRef:[[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/userLocations"]];
        _handleQueryPairs = [NSMutableDictionary dictionary];
    }
    return self;
}

- (NSString *)uid {
    return self.authData.uid;
}

- (NSString *)displayName {
    return self.authData.providerData[@"displayName"];
}

- (NSString *)profileImageURL {
    NSString *normalSizeImageURL = self.authData.providerData[@"cachedUserProfile"][@"profile_image_url_https"];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_normal\\." options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *biggerSizeImageURL = [regex stringByReplacingMatchesInString:normalSizeImageURL options:0 range:NSMakeRange(0, normalSizeImageURL.length) withTemplate:@"\\."];
    
    return biggerSizeImageURL;
}

- (void)addTag:(NSString *)tag withBlock:(void (^)(BOOL))block {
    Firebase *tagsRef = [self.userRef childByAppendingPath:@"tags"];
    [tagsRef updateChildValues:@{ tag: @YES } withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (block) {
            block(error == nil);
        }
    }];
}

- (void)removeTag:(NSString *)tag withBlock:(void (^)(BOOL succeeded))block {
    Firebase *tagRef = [self.userRef childByAppendingPath:[NSString stringWithFormat:@"tags/%@", tag]];
    [tagRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (block) {
            block(error == nil);
        }
    }];
}

- (void)setTags:(NSArray *)tags withBlock:(void (^)(BOOL))block {
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSString *tag in tags) {
        dict[tag] = @YES;
    }
    
    Firebase *tagsRef = [self.userRef childByAppendingPath:@"tags"];
    [tagsRef setValue:dict withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (block) {
            block(error == nil);
        }
    }];
}

- (void)getAllTagsWithBlock:(void (^)(NSArray *tags))block {
    Firebase *tagsRef = [self.userRef childByAppendingPath:@"tags"];
    [tagsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (block) {
            if (snapshot.value != [NSNull null]) {
                block([snapshot.value allKeys]);
            } else {
                block(@[]);
            }
        }
    }];
}

- (void)notifyMentorWithRequest:(Request *)request {
    Firebase *receivedRequestsRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@/receivedRequests", request.mentorUID]];
    Firebase *requestRef = [receivedRequestsRef childByAutoId];
    [requestRef setValue:request.dictionaryRepresentation];
}

- (FirebaseHandle)requestWithTag:(NSString *)tag location:(CLLocation *)location radius:(double)radius {
    GFCircleQuery *query = [self.geoFire queryAtLocation:location withRadius:radius];
    
    FirebaseHandle handle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if (![key isEqualToString:self.authData.uid]) {
            Firebase *keyTagsRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@/tags", key]];
            
            [keyTagsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (snapshot.value != [NSNull null] && snapshot.value[tag]) {
                    [query removeObserverWithFirebaseHandle:handle];
                    [self.handleQueryPairs removeObjectForKey:@(handle)];
                    
                    Request *request = [[Request alloc] init];
                    request.menteeUID = self.authData.uid;
                    request.tag = tag;
                    request.location = location;
                    request.radius = radius;
                    request.mentorUID = key;
                    request.status = RequestStatusPending;
                    
                    [self notifyMentorWithRequest:request];
                    
                    [[NSNotificationCenter defaultCenter] postNotificationName:kMentorFoundNotification object:self userInfo:request.dictionaryRepresentation];
                }
            }];
        }
    }];
    
    self.handleQueryPairs[@(handle)] = query;
    
    return handle;
}

- (void)cancelRequest:(FirebaseHandle)handle {
    [self.handleQueryPairs[@(handle)] removeObserverWithFirebaseHandle:handle];
    [self.handleQueryPairs removeObjectForKey:@(handle)];
}

- (void)observeAllReceivedRequestsWithBlock:(void (^)(NSArray *requests))block {
    Firebase *receivedRequestsRef = [self.userRef childByAppendingPath:@"receivedRequests"];
    [receivedRequestsRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (block) {
            if (snapshot.value != [NSNull null]) {
                block([snapshot.value allValues]);
            } else {
                block(@[]);
            }
        }
    }];
}

- (void)stopObservingAllReceivedRequests {
    Firebase *receivedRequestsRef = [self.userRef childByAppendingPath:@"receivedRequests"];
    [receivedRequestsRef removeAllObservers];
}

- (void)updateLocation:(CLLocation *)location {
    [self.geoFire setLocation:location forKey:self.authData.uid];
}

- (NSString *)description {
    return self.displayName;
}

- (void)dealloc {
    [self stopObservingAllReceivedRequests];
}

@end
