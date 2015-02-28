//
//  UserManager.m
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Firebase/Firebase.h>
#import "UserManager.h"
#import "TwitterAuthHelper.h"

@interface UserManager ()

@property (strong, nonatomic) Firebase *ref;
@property (strong, nonatomic) User *user;

@end

@implementation UserManager

+ (instancetype)sharedManager {
    static UserManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _ref = [[Firebase alloc] initWithUrl:@"https://wisen.firebaseio.com"];
    }
    return self;
}

- (void)logInWithTwitterWithBlock:(void (^)(BOOL succeeded))block {
    TwitterAuthHelper *twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.ref apiKey:@"dkRAHcnzFW43tzJcSa4PZQfyP"];
    [twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
            // Error retrieving Twitter accounts
            if (block) {
                block(NO);
            }
        } else if (accounts.count == 0) {
            // No Twitter accounts found on device
            if (block) {
                block(NO);
            }
        } else {
            // Select an account. Here we pick the first one for simplicity
            ACAccount *account = accounts.firstObject;
            [twitterAuthHelper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
                if (error) {
                    // Error authenticating account
                    if (block) {
                        block(NO);
                    }
                } else {
                    // User logged in!
                    NSLog(@"%@", authData);
                    Firebase *userRef = [self.ref childByAppendingPath:[NSString stringWithFormat:@"users/%@", authData.uid]];
                    self.user = [[User alloc] initWithAuthData:authData];
                    if (block) {
                        block(YES);
                    }
                }
            }];
        }
    }];
}

- (void)logOut {
    [self.ref unauth];
}

@end
