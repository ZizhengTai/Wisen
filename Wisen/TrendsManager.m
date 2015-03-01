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
    Firebase *requestsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requestLocations"];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:requestsRef];
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
}

@end
