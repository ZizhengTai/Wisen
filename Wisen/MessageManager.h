//
//  MessageManager.h
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Sinch/Sinch.h>

typedef NS_ENUM(NSInteger, MessageDirection) { Incoming, Outgoing, };

@interface MessageManager : NSObject <SINClientDelegate, SINMessageClientDelegate>

@property (nonatomic, strong) id<SINClient> client;
@property (nonatomic, copy) void (^reloadUI)();
//@property (nonatomic, strong) NSMutableArray *messages; // Array of two elements array
@property (nonatomic, strong) NSMutableDictionary *allMessages; // @RecipientUID -> @[@[message, direction]]

+ (instancetype)sharedManager;
- (void)sendMessage:(NSString *)text to:(NSString *)recipientUID;
+ (NSString *)getSinchIDFromUID:(NSString *)UID;

@end
