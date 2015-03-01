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

+ (instancetype)sharedManager;

- (void)authenticateWithBlock:(void (^)(BOOL))block;
- (void)finishOAuthAuthenticationForURL:(NSURL *)url;
- (void)sendMoneyToAddress:(NSString *)toAddress withAmountInUSD:(double)amount block:(void (^)(BOOL succeeded))block;

@end
