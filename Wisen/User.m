//
//  User.m
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <GeoFire/GeoFire.h>
#import "User.h"

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
        
        [_userRef updateChildValues:@{ @"username": _authData.providerData[@"username"],
                                       @"displayName": _authData.providerData[@"displayName"],
                                       @"profileImageURL": _authData.providerData[@"cachedUserProfile"][@"profile_image_url_https"] }];
    }
    return self;
}

- (NSString *)uid {
    return self.authData.uid;
}

- (NSString *)username {
    return self.authData.providerData[@"username"];
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

- (RequestHandle)requestWithTag:(NSString *)tag location:(CLLocation *)location radius:(double)radius block:(void (^)(Request *request))block {
    GFCircleQuery *query = [self.geoFire queryAtLocation:location withRadius:radius];
    
    FirebaseHandle handle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        if (![key isEqualToString:self.uid]) {
            Firebase *keyTagsRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@/tags", key]];
            
            [keyTagsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (snapshot.value != [NSNull null] && snapshot.value[tag]) {
                    [query removeObserverWithFirebaseHandle:handle];
                    [self.handleQueryPairs removeObjectForKey:@(handle)];
                    
                    Firebase *requestRef = [[[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requests"] childByAutoId];
                    
                    Request *request = [[Request alloc] init];
                    request.requestID = requestRef.key;
                    request.menteeUID = self.uid;
                    request.tag = tag;
                    request.location = location;
                    request.radius = radius;
                    request.mentorUID = key;
                    request.status = RequestStatusPending;
                    
                    [requestRef setValue:request.dictionaryRepresentationWithoutRequestID withCompletionBlock:^(NSError *error, Firebase *ref) {
                        if (error) {
                            if (block) {
                                block(nil);
                            }
                        } else {
                            Firebase *requestLocationsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requestLocations"];
                            GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:requestLocationsRef];
                            [geoFire setLocation:request.location forKey:request.requestID withCompletionBlock:^(NSError *error) {
                                if (block) {
                                    block(error == nil ? request : nil);
                                }
                            }];
                        }
                    }];
                }
            }];
        }
    }];
    
    self.handleQueryPairs[@(handle)] = query;
    
    return handle;
}

- (void)cancelRequest:(RequestHandle)handle {
    [self.handleQueryPairs[@(handle)] removeObserverWithFirebaseHandle:handle];
    [self.handleQueryPairs removeObjectForKey:@(handle)];
}

- (void)observeRequest:(Request *)request withBlock:(void (^)(Request *request))block {
    Firebase *requestRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/requests/%@", request.requestID]];
    __block BOOL firstEvent = YES;
    [requestRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (firstEvent) {
            firstEvent = NO;
        } else if (block && snapshot.value != [NSNull null]) {
            block([[Request alloc] initWithDictionary:snapshot.value]);
        }
    }];
}

- (void)removeObserverWithRequestID:(NSString *)requestID {
    Firebase *requestRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/requests/%@", requestID]];
    [requestRef removeAllObservers];
}

- (void)observeAllReceivedRequestsWithBlock:(void (^)(NSArray *requests))block {
    Firebase *requestsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requests"];
    FQuery *query = [requestsRef queryOrderedByChild:@"mentorUID"];
    query = [query queryStartingAtValue:self.uid];
    query = [query queryEndingAtValue:self.uid];
    [query observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (block) {
            NSMutableArray *requests = [NSMutableArray array];
            if (snapshot.value != [NSNull null]) {
                for (NSString *requestID in snapshot.value) {
                    NSMutableDictionary *dictionary = snapshot.value[requestID];
                    dictionary[@"requestID"] = requestID;
                    [requests addObject:[[Request alloc] initWithDictionary:dictionary]];
                }
            }
            block(requests);
        }
    }];
}

- (void)removeAllObserversForAllRequests {
    Firebase *requestsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requests"];
    [requestsRef removeAllObservers];
}

- (void)updateStatus:(RequestStatus)status forRequestWithID:(NSString *)requestID {
    Firebase *requestRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/requests/%@", requestID]];
    [requestRef updateChildValues:@{ @"status": @(status) }];
}

- (void)updateLocation:(CLLocation *)location {
    [self.geoFire setLocation:location forKey:self.uid];
}

- (NSString *)description {
    return self.displayName;
}

- (void)dealloc {
    [self removeAllObserversForAllRequests];
}

@end
