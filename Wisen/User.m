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
#import "Request.h"

NSString *const kMentorFoundNotification = @"kMentorFoundNotification";

@interface User ()

@property (strong, nonatomic) FAuthData *authData;
@property (strong, nonatomic) Firebase *userRef;
@property (strong, nonatomic) GeoFire *geoFire;

@end

@implementation User

- (instancetype)initWithAuthData:(FAuthData *)authData {
    self = [super init];
    if (self) {
        _authData = authData;
        _userRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@", authData.uid]];
        _geoFire = [[GeoFire alloc] initWithFirebaseRef:_userRef];
    }
    return self;
}

- (NSString *)displayName {
    return self.authData.providerData[@"displayName"];
}

- (NSString *)profileImageURL {
    NSString *normalSizeImageURL = self.authData.providerData[@"cachedUserProfile"][@"profile_image_url_https"];
    
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"_normal\\." options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSString *biggerSizeImageURL = [regex stringByReplacingMatchesInString:normalSizeImageURL options:0 range:NSMakeRange(0, normalSizeImageURL.length) withTemplate:@"\\."];
    
    return biggerSizeImageURL;
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

- (void)setTags:(NSArray *)tags withBlock:(void (^)(BOOL))block {
    Firebase *tagsRef = [self.userRef childByAppendingPath:@"tags"];
    [tagsRef setValue:tags withCompletionBlock:^(NSError *error, Firebase *ref) {
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

- (void)requestWithTag:(NSString *)tag location:(CLLocation *)location radius:(double)radius {
    GFCircleQuery *query = [self.geoFire queryAtLocation:location withRadius:radius];
    FirebaseHandle handle = [query observeEventType:GFEventTypeKeyEntered withBlock:^(NSString *key, CLLocation *location) {
        
        
        
        
        
        [query removeObserverWithFirebaseHandle:handle];
        
        Request *request = [[Request alloc] init];
        request.menteeUID = self.displayName;
        request.tag = tag;
        request.location = location;
        request.radius = radius;
        request.mentorUID = key;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kMentorFoundNotification object:self userInfo:@{ @"request": request }];
    }];
}

- (void)updateLocation:(CLLocation *)location {
    [self.geoFire setLocation:location forKey:@"location"];
}

- (NSString *)description {
    return self.displayName;
}

@end
