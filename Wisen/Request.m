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
    return [NSString stringWithFormat: @"%@",@[self.location, self.menteeUID, self.mentorUID, self.tag]];
}
@end
