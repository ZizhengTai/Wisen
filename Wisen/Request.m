//
//  Request.m
//  Wisen
//
//  Created by Zizheng Tai on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "Request.h"

@implementation Request

- (NSDictionary *)dictionaryRepresentation {
    return @{ @"requestID": self.requestID,
              @"menteeUID": self.menteeUID,
              @"tag": self.tag,
              @"location": self.location,
              @"radius": @(self.radius),
              @"mentorUID": self.mentorUID,
              @"status": @(self.status) };
}

- (NSDictionary *)dictionaryRepresentationForUpload {
    return @{ @"menteeUID": self.menteeUID,
              @"tag": self.tag,
              @"location": self.location,
              @"radius": @(self.radius),
              @"mentorUID": self.mentorUID,
              @"status": @(self.status) };
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", self.dictionaryRepresentation];
}

@end
