//
//  Request.m
//  Wisen
//
//  Created by Zizheng Tai on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "Request.h"

static const double farePerHour = 10;

@implementation Request

- (instancetype)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    if (self) {
        _requestID = dictionary[@"requestID"];
        _menteeUID = dictionary[@"menteeUID"];
        _tag = [dictionary[@"tag"] lowercaseString];
        double latitude = [dictionary[@"latitude"] doubleValue];
        double longitude = [dictionary[@"longitude"] doubleValue];
        _location = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        _radius = [dictionary[@"radius"] doubleValue];
        _mentorUID = dictionary[@"mentorUID"];
        _status = [dictionary[@"status"] integerValue];
    }
    return self;
}

- (double)requestFare {
    return farePerHour * self.durationInHours;
}

- (void)setTag:(NSString *)tag {
    _tag = tag.lowercaseString;
}

- (NSDictionary *)dictionaryRepresentation {
    NSMutableDictionary *dictionary = [self.dictionaryRepresentationWithoutRequestID mutableCopy];
    dictionary[@"requestID"] = self.requestID;
    return dictionary;

}

- (NSDictionary *)dictionaryRepresentationWithoutRequestID {
    return @{ @"menteeUID": self.menteeUID,
              @"tag": self.tag,
              @"latitude": @(self.location.coordinate.latitude),
              @"longitude": @(self.location.coordinate.longitude),
              @"radius": @(self.radius),
              @"mentorUID": self.mentorUID,
              @"status": @(self.status) };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.dictionaryRepresentation];
}

@end
