//
//  PaymentManager.m
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "PaymentManager.h"

static NSString * const ClientID = @"047a37b1ea82ea1741a385c57973df40bf1044dd7fcb4b3ac213dd2661a99c0b";
static NSString * const ClientSecret = @"c5bb0d2f5fe8013ff4cf0e81ec7ffda33914752084a13bde557bb13be990144b";
static NSString * const RedirectURL = @"com.example.app.coinbase-oauth://coinbase-oauth";

@implementation PaymentManager

- (instancetype)init
{
    if (self = [super init])
    {
        [CoinbaseOAuth startOAuthAuthenticationWithClientId:ClientID
                                                      scope:@"user balance"
                                                redirectUri:RedirectURL
                                                       meta:nil];
    }
    return self;
}

+ (instancetype)sharedManager
{
    static PaymentManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

@end
