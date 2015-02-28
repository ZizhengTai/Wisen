//
//  PaymentManager.m
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import "PaymentManager.h"

static NSString *const kClientID = @"047a37b1ea82ea1741a385c57973df40bf1044dd7fcb4b3ac213dd2661a99c0b";
static NSString *const kClientSecret = @"c5bb0d2f5fe8013ff4cf0e81ec7ffda33914752084a13bde557bb13be990144b";
static NSString *const kRedirectURI = @"com.example.app.coinbase-oauth://coinbase-oauth";

@interface PaymentManager ()

@property (copy, nonatomic) NSString *accessToken;// = [response objectForKey:@"access_token"];
@property (copy, nonatomic) NSString *refreshToken;// = [response objectForKey:@"refresh_token"];
@property (strong, nonatomic) NSNumber *expiresIn;// = [response objectForKey:@"expires_in"];

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

- (instancetype)init {
    self = [super init];
    if (self) {
        [CoinbaseOAuth startOAuthAuthenticationWithClientId:kClientID scope:@"user balance" redirectUri:kRedirectURI meta:nil];
    }
    return self;
}

- (void)finishOAuthAuthenticationForURL:(NSURL *)url withBlock:(void (^)(BOOL succeeded))block {
    // This is a redirect from the Coinbase OAuth web page or app.
    [CoinbaseOAuth finishOAuthAuthenticationForUrl:url clientId:kClientID clientSecret:kClientSecret completion:^(id result, NSError *error) {
        if (error) {
            // Could not authenticate.
        } else {
            self.accessToken = result[@"access_token"];
            self.refreshToken = result[@"refresh_token"];
            self.expiresIn = result[@"expires_in"];
            
            self.client = [Coinbase coinbaseWithOAuthAccessToken:self.accessToken];
            
            // Note that you should also store 'expire_in' and refresh the token using [CoinbaseOAuth getOAuthTokensForRefreshToken] when it expires
            [self.client doGet:@"users/self" parameters:nil completion:^(id result, NSError *error) {
                if (error) {
                    NSLog(@"Could not load user: %@", error);
                } else {
                    NSLog(@"Signed in as: %@", result[@"user"][@"email"]);
                }
            }];
        }
        if (block) {
            block(error == nil);
        }
    }];
}

@end
