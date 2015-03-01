//
//  TrendsManager.h
//  Wisen
//
//  Created by Dev on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface TrendsManager : NSObject

+ (instancetype)sharedManager;

- (void)getPopularRequestTagsAtLocation:(CLLocation *)location radius:(double)radius block:(void (^)(NSArray *tags))block;
- (void)getPopularUserTagsAtLocation:(CLLocation *)location radius:(double)radius block:(void (^)(NSArray *tags))block;

@end
