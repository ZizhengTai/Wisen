//
//  PaymentManager.h
//  Wisen
//
//  Created by Yihe Li on 2/28/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoinbaseOAuth.h"

@interface PaymentManager : NSObject

@property (nonatomic, strong) Coinbase *client;
+ (instancetype)sharedManager;

@end
