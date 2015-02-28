//
//  Timer.m
//  Pulse
//
//  Created by Zizheng Tai on 1/15/15.
//  Copyright (c) 2015 Zizheng Tai. All rights reserved.
//

#import "Timer.h"

static const NSTimeInterval kTolerableError = 0.01;

static NSString *const kDuration = @"kDuration";
static NSString *const kTimeInterval = @"kTimeInterval";
static NSString *const kCompletionNotification = @"kCompletionNotification";
static NSString *const kStopDate = @"kStopDate";

@interface Timer ()

@property (strong, nonatomic) NSTimer *timer;
@property (strong, nonatomic) NSDate *stopDate;

@end

@implementation Timer

- (instancetype)initWithDuration:(NSTimeInterval)duration
                    timeInterval:(NSTimeInterval)timeInterval
          completionNotification:(UILocalNotification *)notification
                        delegate:(id<TimerDelegate>)delegate {
    self = [super init];
    if (self) {
        _duration = duration;
        _timeInterval = timeInterval;
        _completionNotification = notification;
        _delegate = delegate;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _duration = [aDecoder decodeDoubleForKey:kDuration];
        _timeInterval = [aDecoder decodeDoubleForKey:kTimeInterval];
        _completionNotification = [aDecoder decodeObjectForKey:kCompletionNotification];
        _stopDate = [aDecoder decodeObjectForKey:kStopDate];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:self.duration forKey:kDuration];
    [aCoder encodeDouble:self.timeInterval forKey:kTimeInterval];
    [aCoder encodeObject:self.completionNotification forKey:kCompletionNotification];
    [aCoder encodeObject:self.stopDate forKey:kStopDate];
}

- (void)start {
    self.stopDate = [NSDate dateWithTimeIntervalSinceNow:self.duration];
    
    [self createTimer];
    
    if (self.completionNotification) {
        self.completionNotification.fireDate = self.stopDate;
        self.completionNotification.timeZone = [NSTimeZone defaultTimeZone];
        [[UIApplication sharedApplication] scheduleLocalNotification:self.completionNotification];
    }
}

- (void)abort {
    [self.timer invalidate];
    self.timer = nil;
    self.stopDate = nil;
    
    if (self.completionNotification) {
        [[UIApplication sharedApplication] cancelLocalNotification:self.completionNotification];
    }
}

- (void)resumeWithDelegate:(id<TimerDelegate>)delegate {
    if (!self.timer && self.stopDate) {
        self.delegate = delegate;
        [self createTimer];
    }
}

- (void)createTimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(timerDidFire:) userInfo:nil repeats:YES];
    [self timerDidFire:self.timer];
}

- (void)timerDidFire:(NSTimer *)timer {
    NSTimeInterval remainingTime = [self.stopDate timeIntervalSinceNow];
    NSTimeInterval error = remainingTime - round(remainingTime);
    
    if (error >= kTolerableError || error <= -kTolerableError) {
        // Calibrate timer
        [timer invalidate];
        [self performSelector:@selector(createTimer) withObject:nil afterDelay:remainingTime - floor(remainingTime)];
    } else if (remainingTime <= kTolerableError) {
        // Timer stopped
        [timer invalidate];
        if ([self.delegate respondsToSelector:@selector(timer:didStopAtDate:)]) {
            [self.delegate timer:self didStopAtDate:self.stopDate];
        }
        self.timer = nil;
        self.stopDate = nil;
    } else if ([self.delegate respondsToSelector:@selector(timer:didFireWithRemainingTime:)]) {
        // Timer fired
        [self.delegate timer:self didFireWithRemainingTime:remainingTime];
    }
}

@end
