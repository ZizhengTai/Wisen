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

- (void)tryLogInWithBlock:(void (^)(User *user))block {
    __weak UserManager *weakSelf = self;
    FirebaseHandle handle = [self.ref observeAuthEventWithBlock:^(FAuthData *authData) {
        [weakSelf.ref removeAuthEventObserverWithHandle:handle];
        if (authData.uid) {
            weakSelf.user = [[User alloc] initWithAuthData:authData];
        } else {
            weakSelf.user = nil;
        }
        if (block) {
            block(weakSelf.user);
        }
    }];
}

- (void)logInWithTwitterWithBlock:(void (^)(User *user))block {
    TwitterAuthHelper *twitterAuthHelper = [[TwitterAuthHelper alloc] initWithFirebaseRef:self.ref apiKey:@"dkRAHcnzFW43tzJcSa4PZQfyP"];
    [twitterAuthHelper selectTwitterAccountWithCallback:^(NSError *error, NSArray *accounts) {
        if (error) {
            // Error retrieving Twitter accounts
            if (block) {
                block(nil);
            }
        } else if (accounts.count == 0) {
            // No Twitter accounts found on device
            if (block) {
                block(nil);
            }
        } else {
            // Select an account. Here we pick the first one for simplicity
            ACAccount *account = accounts.firstObject;
            [twitterAuthHelper authenticateAccount:account withCallback:^(NSError *error, FAuthData *authData) {
                if (error) {
                    // Error authenticating account
                    if (block) {
                        block(nil);
                    }
                } else {
                    // User logged in!
                    self.user = [[User alloc] initWithAuthData:authData];
                    if (block) {
                        block(self.user);
                    }
                }
            }];
        }
    }];
}

- (void)logOut {
    [self.ref unauth];
}

- (void)getBasicInfoForUserWithUID:(NSString *)uid block:(void (^)(NSDictionary *userInfo))block {
    Firebase *userRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/users/%@", uid]];
    [userRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (block) {
            if (snapshot.value != [NSNull null]) {
                NSDictionary *userInfo = @{ @"displayName": snapshot.value[@"displayName"],
                                            @"profileImageURL": snapshot.value[@"profileImageURL"] };
                block(userInfo);
            } else {
                block(nil);
            }
        }
    }];
}

- (NSArray *)popularRequest
{
    return @[@"Skateboard", @"Piano", @"Soccer", @"Guitar", @"Cooking", @"Workout", @"Origami"];
}

@end
