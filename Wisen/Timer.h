//
//  Timer.h
//  Pulse
//
//  Created by Zizheng Tai on 1/15/15.
//  Copyright (c) 2015 Zizheng Tai. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TimerDelegate;

@interface Timer : NSObject <NSCoding>

@property (readonly, assign, nonatomic) NSTimeInterval duration;
@property (readonly, assign, nonatomic) NSTimeInterval timeInterval;
@property (readonly, strong, nonatomic) UILocalNotification *completionNotification;
@property (weak, nonatomic) id<TimerDelegate> delegate;
@property (readonly, strong, nonatomic) NSDate *stopDate;

- (instancetype)initWithDuration:(NSTimeInterval)duration
                    timeInterval:(NSTimeInterval)timeInterval
          completionNotification:(UILocalNotification *)notification
                        delegate:(id<TimerDelegate>)delegate;

- (void)start;
- (void)abort;
- (void)resumeWithDelegate:(id<TimerDelegate>)delegate;

@end

#pragma mark - TimerDelegate protocol

@protocol TimerDelegate <NSObject>

@optional
- (void)timer:(Timer *)timer didFireWithRemainingTime:(NSTimeInterval)remainingTime;
@optional
- (void)timer:(Timer *)timer didStopAtDate:(NSDate *)date;

@end
