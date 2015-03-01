//
//  MessagePipe.m
//  Wisen
//
//  Created by Dev on 3/1/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "MessagePipe.h"

@interface MessagePipe ()

@property (strong, nonatomic) Firebase *sendRef;
@property (strong, nonatomic) Firebase *receiveRef;

@end

@implementation MessagePipe

- (instancetype)initWithSelfUID:(NSString *)selfUID otherUID:(NSString *)otherUID {
    self = [super init];
    if (self) {
        _selfUID = [selfUID copy];
        _otherUID = [otherUID copy];
        
        _sendRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/messages/%@/%@", _selfUID, _otherUID]];
        _receiveRef = [[Firebase alloc] initWithUrl:[NSString stringWithFormat:@"https://wisen.firebaseio.com/messages/%@/%@", _otherUID, _selfUID]];
    }
    return self;
}

- (void)send:(NSDictionary *)msg {
    [self.sendRef setValue:msg];
}

- (void)observeWithBlock:(void (^)(NSDictionary *msg))block {
    __block BOOL first = YES;
    [self.receiveRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        if (first) {
            first = NO;
        } else {
            if (block && snapshot.value != [NSNull null]) {
                block(snapshot.value);
            }
        }
    }];
}

- (void)stopObserving {
    [self.receiveRef removeAllObservers];
}

- (void)dealloc {
    [self stopObserving];
}

@end
