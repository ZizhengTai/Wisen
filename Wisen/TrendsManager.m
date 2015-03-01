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

- (void)getPopularRequestTagsAtLocation:(CLLocation *)location radius:(double)radius block:(void (^)(NSArray *))block {
    /*Firebase *requestsRef = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com/requests"];
    GeoFire *geoFire = [[GeoFire alloc] initWithFirebaseRef:requestsRef];
    
    GFCircleQuery *query = [geoFire queryAtLocation:location withRadius:radius];
    FirebaseHandle handle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
    }];*/
}

- (void)getPopularUserTagsAtLocation:(CLLocation *)location radius:(double)radius block:(void (^)(NSArray *))block {
}

@end
