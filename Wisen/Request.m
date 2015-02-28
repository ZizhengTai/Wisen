//
//  Request.m
//  Wisen
//
//  Created by Zizheng Tai on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "Request.h"

@implementation Request

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _requestID = dictionary[@"requestID"];
        _menteeUID = dictionary[@"menteeUID"];
        _tag = dictionary[@"tag"];
        double latitude = [dictionary[@"latitude"] doubleValue];
        double longitude = [dictionary[@"longitude"] doubleValue];
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        _radius = [dictionary[@"radius"] doubleValue];
        _mentorUID = dictionary[@"mentorUID"];
        _status = [dictionary[@"status"] integerValue];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation {
    return @{ @"requestID": self.requestID,
              @"menteeUID": self.menteeUID,
              @"tag": self.tag,
              @"latitude": @(self.location.coordinate.latitude),
              @"longitude": @(self.location.coordinate.longitude),
              @"radius": @(self.radius),
              @"mentorUID": self.mentorUID,
              @"status": @(self.status) };
}

- (NSDictionary *)dictionaryRepresentationWithoutRequestID {
    NSMutableDictionary *dictionary = [self.dictionaryRepresentation mutableCopy];
    [dictionary removeObjectForKey:@"requestID"];
    return dictionary;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.dictionaryRepresentation];
}

@end
