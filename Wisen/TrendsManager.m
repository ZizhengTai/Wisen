//
//  TrendsManager.m
//  Wisen
//
//  Created by Dev on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <libkern/OSAtomic.h>
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
    
    NSMutableArray *requestIDs = [NSMutableArray array];
    
    FirebaseHandle enteredHandle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        [requestIDs addObject:key];
    }];
    
    FirebaseHandle readyHandle = [query observeReadyWithBlock:^{
        [query removeObserverWithFirebaseHandle:enteredHandle];
        [query removeObserverWithFirebaseHandle:readyHandle];
        
        if (requestIDs.count == 0) {
            if (block) {
                block(@[]);
            }
        } else {
            NSMutableSet *tags = [NSMutableSet set];
            __block int32_t count = (int32_t)requestIDs.count;
            
            for (NSString *requestID in requestIDs) {
                Firebase *tagRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/request/%@/tag", requestID]];
                [tagRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    if (snapshot.value != [NSNull null]) {
                        [tags addObject:snapshot.value];
                    }
                    if (OSAtomicDecrement32(&count) == 0 && block) {
                        block(tags.allObjects);
                    }
                }];
            }
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
        
        if (uids.count == 0) {
            if (block) {
                block(@[]);
            }
        } else {
            NSMutableSet *tags = [NSMutableSet set];
            __block int32_t count = (int32_t)uids.count;
            
            for (NSString *uid in uids) {
                Firebase *tagsRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@/tags", uid]];
                [tagsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
                    if (snapshot.value != [NSNull null]) {
                        [tags addObjectsFromArray:[snapshot.value allKeys]];
                    }
                    if (OSAtomicDecrement32(&count) == 0 && block) {
                        block(tags.allObjects);
                    }
                }];
            }
        }
    }];
}

@end
