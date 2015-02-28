//
//  User.h
//  Wisen
//
//  Created by Zizheng Tai on 2/27/15.
//  Copyright (c) 2015 self. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Firebase/Firebase.h>

@interface User : NSObject

@property (copy, nonatomic) NSString *displayName;

- (instancetype)initWithAuthData:(FAuthData *)authData;

- (void)addTag:(NSString *)tag;
- (void)allTags:(NSArray *)tags;
- (void)requestWithTag:(NSString *)tag location:(CGPoint)location;

@end
