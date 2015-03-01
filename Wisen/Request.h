//
//  Request.h
//  Wisen
//
//  Created by Zizheng Tai on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSInteger, RequestStatus) {
    RequestStatusPending = 0,
    RequestStatusMentorConfirmed = 1,
    RequestStatusOngoing = 2,
    RequestStatusCanceled = 3,
    RequestStatusComplete = 4
};

@interface Request : NSObject

@property (copy, nonatomic) NSString *requestID;
@property (copy, nonatomic) NSString *menteeUID;
@property (copy, nonatomic) NSString *tag;
@property (strong, nonatomic) CLLocation *location;
@property (assign, nonatomic) double radius;
@property (copy, nonatomic) NSString *mentorUID;
@property (assign, nonatomic) RequestStatus status;

@property (readonly, strong, nonatomic) NSDictionary *dictionaryRepresentation;
@property (readonly, strong, nonatomic) NSDictionary *dictionaryRepresentationWithoutRequestID;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

@end
