//
//  UserManager.h
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserManager : NSObject

@property (readonly, strong, nonatomic) User *user;

+ (instancetype)sharedManager;

- (void)tryLogInWithBlock:(void (^)(User *user))block;
- (void)logInWithTwitterWithBlock:(void (^)(User *user))block;
- (void)logOut;

- (void)getBasicInfoForUserWithUID:(NSString *)uid block:(void (^)(NSDictionary *userInfo))block;

@end
