//
//  AppDelegate.m
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import <Fabric/Fabric.h>
#import "AppDelegate.h"
#import "CoinbaseOAuth.h"

static NSString * const ClientID = @"047a37b1ea82ea1741a385c57973df40bf1044dd7fcb4b3ac213dd2661a99c0b";
static NSString * const ClientSecret = @"c5bb0d2f5fe8013ff4cf0e81ec7ffda33914752084a13bde557bb13be990144b";
static NSString * const RedirectURL = @"com.example.app.coinbase-oauth://coinbase-oauth";
@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Fabric with:@[ CrashlyticsKit ]]; // Crashlytics is just one option, you can also pass TwitterKit and MoPubKit
    
    [[UserManager sharedManager] tryLogInWithBlock:^(User *user) {
        if (user) {
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"MainScene"];
        } else {
            self.window.rootViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"LoginScene"];
        }
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    
    if ([[url scheme] isEqualToString:@"com.example.app.coinbase-oauth"]) {
        // This is a redirect from the Coinbase OAuth web page or app.
        [CoinbaseOAuth finishOAuthAuthenticationForUrl:url
                                              clientId:ClientID
                                          clientSecret:ClientSecret
                                            completion:^(id result, NSError *error) {
                                                if (error) {
                                                    // Could not authenticate.
                                                } else {
                                                    // Tokens successfully obtained!
                                                    // Do something with them (store them, etc.)
                                                    Coinbase *apiClient = [Coinbase coinbaseWithOAuthAccessToken:[result objectForKey:@"access_token"]];
                                                    [PaymentManager sharedManager].client = apiClient;
                                                    // Note that you should also store 'expire_in' and refresh the token using [CoinbaseOAuth getOAuthTokensForRefreshToken] when it expires
                                                    [apiClient doGet:@"users/self" parameters:nil completion:^(id result, NSError *error) {
                                                        if (error) {
                                                            NSLog(@"Could not load user: %@", error);
                                                        } else {
                                                            NSLog(@"Signed in as: %@", [[result objectForKey:@"user"] objectForKey:@"email"]);
                                                        }
                                                    }];
                                                }
                                            }];
        
        return YES;
    }
    return NO;
    
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
