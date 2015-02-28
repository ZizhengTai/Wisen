//
//  Request.m
//  Wisen
//
//  Created by Zizheng Tai on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "Request.h"

@implementation Request

- (NSString *)description {
    return [NSString stringWithFormat:@"%@", @{
                                               @"menteeUID": self.menteeUID,
                                               @"tag": self.tag,
                                               @"location": self.location,
                                               @"radius": @(self.radius),
                                               @"mentorUID": self.mentorUID
                                               }];
}

@end
