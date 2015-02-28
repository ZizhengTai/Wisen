//
//  User.m
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Firebase/Firebase.h>
#import <GeoFire/GeoFire.h>
#import "User.h"

@interface User ()

@property (strong, nonatomic) FAuthData *authData;
@property (strong, nonatomic) Firebase *userRef;
@property (strong, nonatomic) GeoFire *geoFire;

@end

@implementation User

- (instancetype)initWithAuthData:(FAuthData *)authData {
    self = [super init];
    if (self) {
        Firebase *ref = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com"];
        
        _authData = authData;
        _userRef = [ref childByAppendingPath:[NSString stringWithFormat:@"users/%@", authData.uid]];
        _geoFire = [[GeoFire alloc] initWithFirebaseRef:ref];
    }
    return self;
}

- (NSString *)displayName {
    return self.authData.providerData[@"displayName"];
}

- (NSString *)profileImageUrl {
    NSString *normalSizeImageUrl = self.authData.providerData[@"cachedUserProfile"][@"profile_image_url_https"];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_normal\\." options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *biggerSizeImageUrl = [regex stringByReplacingMatchesInString:normalSizeImageUrl options:0 range:NSMakeRange(0, normalSizeImageUrl.length) withTemplate:@"\\."];
    
    return biggerSizeImageUrl;
}

- (void)addTag:(NSString *)tag withBlock:(void (^)(BOOL))block {
    Firebase *tagsRef = [self.userRef childByAppendingPath:@"tags"];
    [tagsRef updateChildValues:@{ tag: @YES } withCompletionBlock:^(NSError *error, Firebase *ref) {
        if (block) {
            block(error == nil);
        }
    }];
}

- (void)removeTag:(NSString *)tag withBlock:(void (^)(BOOL succeeded))block {
    Firebase *tagRef = [self.userRef childByAppendingPath:[NSString stringWithFormat:@"tags/%@", tag]];
    [tagRef removeValueWithCompletionBlock:^(NSError *error, Firebase *ref) {
        if (block) {
            block(error == nil);
        }
    }];
}

- (void)getAllTagsWithBlock:(void (^)(NSArray *tags))block {
    Firebase *tagsRef = [self.userRef childByAppendingPath:@"tags"];
    [tagsRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (block) {
            block(snapshot.value);
        }
    }];
}

- (void)requestWithTag:(NSString *)tag location:(CGPoint)location {
#warning Not implemented
}

- (void)updateLocationWithLatitude:(CGFloat)latitude longitude:(CGFloat)longitude {
#warning Not implemented
}

- (NSString *)description {
    return self.displayName;
}

@end
