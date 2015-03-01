//
//  MessagePipe.h
//  Wisen
//
//  Created by Dev on 3/1/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Firebase/Firebase.h>

@interface MessagePipe : NSObject

@property (readonly, strong, nonatomic) NSString *selfUID;
@property (readonly, strong, nonatomic) NSString *otherUID;

- (instancetype)initWithSelfUID:(NSString *)selfUID otherUID:(NSString *)otherUID;
- (void)send:(NSDictionary *)msg;
- (void)observeWithBlock:(void (^)(NSDictionary *msg))block;
- (void)stopObserving;

@end
