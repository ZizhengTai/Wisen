//
//  TrendsManager.m
//  Wisen
//
//  Created by Dev on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <GeoFire/GeoFire.h>
#import "TrendsManager.h"

@implementation TrendsManager

+ (instancetype)sharedManager {
    static TrendsManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)getPopularRequestTagsAtLocation:(CLLocation *)location radius:(double)radius block:(void (^)(NSArray *tags))block {
    Firebase *requestLocationsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requestLocations"];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:requestLocationsRef];
    GFCircleQuery *query = [geoFire queryAtLocation:location withRadius:radius];
    
    NSMutableSet *tags = [NSMutableSet set];
    
    FirebaseHandle enteredHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        Firebase *requestRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/requests/%@", key]];
        [requestRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
            if (snapshot.value != [NSNull null]) {
                [tags addObject:snapshot.value[@"tag"]];
            }
        }];
    }];
    
    FirebaseHandle readyHandle = [query observeReadyWithBlock:^{
        [query removeObserverWithFirebaseHandle:enteredHandle];
        [query removeObserverWithFirebaseHandle:readyHandle];
        if (block) {
            block(tags.allObjects);
        }
    }];
}

- (void)getPopularUserTagsAtLocation:(CLLocation *)location radius:(double)radius block:(void (^)(NSArray *tags))block {
    Firebase *userLocationsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/userLocations"];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:userLocationsRef];
    GFCircleQuery *query = [geoFire queryAtLocation:location withRadius:radius];
    
    NSMutableArray *uids = [NSMutableArray array];
    
    FirebaseHandle enteredHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        [uids addObject:key];
    }];
    
    FirebaseHandle readyHandle = [query observeReadyWithBlock:^{
        [query removeObserverWithFirebaseHandle:enteredHandle];
        [query removeObserverWithFirebaseHandle:readyHandle];
        
        NSMutableSet *tags = [NSMutableSet set];
        
        for (NSString *uid in uids) {
            Firebase *tagsRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@/tags", uid]];
            [tagsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                if (snapshot.value != [NSNull null]) {
                    [tags addObjectsFromArray:[snapshot.value allKeys]];
                }
                if (tags.count == uids.count && block) {
                    block(tags.allObjects);
                }
            }];
        }
    }];
}

@end
