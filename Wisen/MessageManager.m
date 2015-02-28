//
//  MessageManager.m
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "MessageManager.h"

@interface MessageManager()

@property (nonatomic) id<SINMessageClient> messageClient;

@end

NSString * const appKey = @"c01240e3-aa90-482f-b9f7-e1d10e731888";
NSString * const appSecret = @"eF7ulj87k0yDqGdEzMMgfw==";
NSString * const hostName = @"sandbox.sinch.com";


@implementation MessageManager

- (instancetype)init {
    if (self = [super init]) {
        NSString *subString = [[UserManager sharedManager].user.uid substringFromIndex:@"twitter:".length];
        _client = [Sinch clientWithApplicationKey:appKey applicationSecret:appSecret environmentHost:hostName userId:subString];
        [_client setSupportMessaging:YES];
        [_client setSupportPushNotifications:YES];
        _client.delegate = self;
        [_client start];
        [_client startListeningOnActiveConnection];
        _messageClient = [_client messageClient];
        _messageClient.delegate = self;
    }
    return self;
}

+ (instancetype)sharedManager {
    static MessageManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)dealloc {
    [_client stopListeningOnActiveConnection];
    [_client terminate];
    _client = nil;
}

- (NSMutableDictionary *)allMessages {
    if (!_allMessages) {
        _allMessages = [NSMutableDictionary dictionary];
    }
    return _allMessages;
}

#pragma mark - SINClientDelegate

- (void)clientDidStart:(id<SINClient>)client {
    NSLog(@"Sinch client started successfully (version: %@)", [Sinch version]);
}

- (void)clientDidStop:(id<SINClient>)client {
    NSLog(@"Sinch client stopped");
}

- (void)clientDidFail:(id<SINClient>)client error:(NSError *)error {
    NSLog(@"Error: %@", error);
}

- (void)client:(id<SINClient>)client
    logMessage:(NSString *)message
          area:(NSString *)area
      severity:(SINLogSeverity)severity
     timestamp:(NSDate *)timestamp {
    
    if (severity == SINLogSeverityCritical) {
        NSLog(@"%@", message);
    }
}

#pragma mark - SINMessageClientDelegate

- (void)messageClient:(id<SINMessageClient>)messageClient didReceiveIncomingMessage:(id<SINMessage>)message {
    NSLog(@"Message Got");
    [self.allMessages[message.senderId] addObject:@[ message, @(Incoming) ]];
//    [self.messageView reloadData];
//    [self scrollToBottom];
    self.reloadUI();
}

- (void)messageSent:(id<SINMessage>)message recipientId:(NSString *)recipientId {
    if (!self.allMessages[recipientId]) {
        self.allMessages[recipientId] = [NSMutableArray array];
    }
    [self.allMessages[recipientId] addObject:@[ message, @(Outgoing) ]];

//    [self.messageView reloadData];
//    [self scrollToBottom];
    self.reloadUI();
}

- (void)message:(id<SINMessage>)message shouldSendPushNotifications:(NSArray *)pushPairs {
    NSLog(@"Recipient not online. \
          Should notify recipient using push (not implemented in this demo app). \
          Please refer to the documentation for a comprehensive description.");
}

- (void)messageDelivered:(id<SINMessageDeliveryInfo>)info {
    NSLog(@"Message to %@ was successfully delivered", info.recipientId);
}

- (void)messageFailed:(id<SINMessage>)message info:(id<SINMessageFailureInfo>)failureInfo {
    NSLog(@"Failed delivering message to %@. Reason: %@", failureInfo.recipientId,
          [failureInfo.error localizedDescription]);
}

#pragma mark - Message Methods

- (void)sendMessage:(NSString *)text to:(NSString *)recipientUID; {
    SINOutgoingMessage *message = [SINOutgoingMessage messageWithRecipient:recipientUID text:text];
    [self.messageClient sendMessage:message];
}

@end
