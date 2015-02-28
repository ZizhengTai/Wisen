//
//  User.h
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

- (void)logInWithTwitterWithBlock:(void (^)(BOOL))block;

@end
