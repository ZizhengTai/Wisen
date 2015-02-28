//
//  Request.h
//  Wisen
//
//  Created by Zizheng Tai on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <CoreLocation/CoreLocation.h>

@interface Request : NSObject

@property (copy, nonatomic) NSString *menteeUID;
@property (copy, nonatomic) NSString *tag;
@property (strong, nonatomic) CLLocation *location;
@property (assign, nonatomic) double radius;
@property (copy, nonatomic) NSString *mentorUID;

@end
