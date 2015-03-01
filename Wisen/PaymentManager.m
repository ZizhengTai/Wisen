//
//  PaymentManager.m
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <coinbase-official/CoinbaseOAuth.h>
#import "PaymentManager.h"

static NSString *const kClientID = @"047a37b1ea82ea1741a385c57973df40bf1044dd7fcb4b3ac213dd2661a99c0b";
static NSString *const kClientSecret = @"c5bb0d2f5fe8013ff4cf0e81ec7ffda33914752084a13bde557bb13be990144b";
static NSString *const kRedirectURI = @"com.example.app.coinbase-oauth://coinbase-oauth";

static NSString *const kCommissionToAddress = @"zizheng.tai@gmail.com";
static const double kCommissionRate = 0.1;
static const double kLowestAmount = 0.1;

@interface PaymentManager ()

@property (copy, nonatomic) NSString *accessToken;
@property (copy, nonatomic) NSString *refreshToken;
@property (strong, nonatomic) NSNumber *expiresIn;
@property (nonatomic, copy) void (^authenticationCompletionHandler)(BOOL);

@end

@implementation PaymentManager

+ (instancetype)sharedManager {
    static PaymentManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

- (void)authenticateWithBlock:(void (^)(BOOL))block {
    [CoinbaseOAuth startOAuthAuthenticationWithClientId:kClientID
                                                  scope:@"user send"
                                            redirectUri:kRedirectURI
                                                   meta:@{ @"send_limit_amount": @"100",
                                                           @"send_limit_currency": @"USD",
                                                           @"send_limit_period": @"day" }];
    self.authenticationCompletionHandler = block;
}

- (void)finishOAuthAuthenticationForURL:(NSURL *)url {
    // This is a redirect from the Coinbase OAuth web page or app.
    [CoinbaseOAuth finishOAuthAuthenticationForUrl:url clientId:kClientID clientSecret:kClientSecret completion:^(id result, NSError *error) {
        if (!error) {
            self.accessToken = result[@"access_token"];
            self.refreshToken = result[@"refresh_token"];
            self.expiresIn = result[@"expires_in"];
            
            self.client = [Coinbase coinbaseWithOAuthAccessToken:self.accessToken];
        }
        if (self.authenticationCompletionHandler) {
            self.authenticationCompletionHandler(error == nil);
        }
    }];
}

- (void)sendMoneyToAddress:(NSString *)toAddress withAmountInUSD:(double)amount block:(void (^)(BOOL succeeded))block {
    if (amount < kLowestAmount) {
        if (block) {
            block(NO);
        }
        return;
    }
    
    // Send commission
    NSString *amountString = [NSString stringWithFormat:@"%f", kCommissionRate * amount];
    NSDictionary *params = @{ @"transaction": @{ @"to": kCommissionToAddress,
                                                 @"amount_string": amountString,
                                                 @"amount_currency_iso": @"USD" } };
    [self.client doPost:@"transactions/send_money" parameters:params completion:^(id response, NSError *error) {
        if (error) {
            if (block) {
                block(NO);
            }
        } else {
            // Send to mentor
            NSString *amountString = [NSString stringWithFormat:@"%f", (1 - kCommissionRate) * amount];
            NSDictionary *params = @{ @"transaction": @{ @"to": toAddress,
                                                         @"amount_string": amountString,
                                                         @"amount_currency_iso": @"USD" } };
            [self.client doPost:@"transactions/send_money" parameters:params completion:^(id response, NSError *error) {
                if (block) {
                    block(error == nil);
                }
            }];
        }
    }];
}

@end
