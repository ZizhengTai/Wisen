//
//  PaymentManager.h
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <coinbase-official/Coinbase.h>

@interface PaymentManager : NSObject

@property (nonatomic, strong) Coinbase *client;
@property (copy, nonatomic) NSString *recipientAddress;

+ (instancetype)sharedManager;

- (void)authenticateWithBlock:(void (^)(BOOL))block;
- (void)finishOAuthAuthenticationForURL:(NSURL *)url;
- (void)sendMoneywithAmountInUSD:(double)amount block:(void (^)(BOOL succeeded))block;

@end
