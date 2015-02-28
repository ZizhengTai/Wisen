//
//  User.m
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "User.h"

@interface User ()

@property (strong, nonatomic) FAuthData *authData;

@end

@implementation User

- (instancetype)initWithAuthData:(FAuthData *)authData {
    self = [super init];
    if (self) {
        _authData = authData;
    }
    return self;
}

- (void)setDisplayName:(NSString *)displayName {
}

- (void)addTag:(NSString *)tag {
}

- (void)allTags:(NSArray *)tags {
}

- (void)requestWithTag:(NSString *)tag location:(CGPoint)location {
}

@end
