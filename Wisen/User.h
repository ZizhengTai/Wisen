//
//  User.h
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Firebase/Firebase.h>
#import "Request.h"

extern NSString *const kMentorFoundNotification;

@interface User : NSObject

@property (readonly, strong, nonatomic) NSString *uid;
@property (readonly, strong, nonatomic) NSString *displayName;
@property (readonly, strong, nonatomic) NSString *profileImageURL;

- (instancetype)initWithAuthData:(FAuthData *)authData;

- (void)addTag:(NSString *)tag withBlock:(void (^)(BOOL succeeded))block;
- (void)removeTag:(NSString *)tag withBlock:(void (^)(BOOL succeeded))block;
- (void)setTags:(NSArray *)tags withBlock:(void (^)(BOOL succeeded))block;
- (void)getAllTagsWithBlock:(void (^)(NSArray *tags))block;

- (FirebaseHandle)requestWithTag:(NSString *)tag location:(CLLocation *)location radius:(double)radius;
- (void)cancelRequest:(FirebaseHandle)handle;

- (void)observeAllSentRequestsWithBlock:(void (^)(NSArray *requests))block;
- (void)observeAllReceivedRequestsWithBlock:(void (^)(NSArray *requests))block;
- (void)removeAllObserverForAllRequests;

- (void)updateStatus:(RequestStatus)status forRequestWithID:(NSString *)requestID;

- (void)updateLocation:(CLLocation *)location;

@end
