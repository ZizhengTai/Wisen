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

@property (readonly, strong, nonatomic) NSString *displayName;
@property (readonly, strong, nonatomic) NSString *profileImageUrl;

- (instancetype)initWithAuthData:(FAuthData *)authData;

- (void)addTag:(NSString *)tag withBlock:(void (^)(BOOL succeeded))block;
- (void)removeTag:(NSString *)tag withBlock:(void (^)(BOOL succeeded))block;
- (void)getAllTagsWithBlock:(void (^)(NSArray *tags))block;
- (void)requestWithTag:(NSString *)tag location:(CGPoint)location;

@end
