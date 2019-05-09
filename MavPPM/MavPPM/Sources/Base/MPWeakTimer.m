//
//  MPWeakTimer.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPWeakTimer.h"

@interface MPWeakTimer ()
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL selector;
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, weak) id userInfo;
@end

@implementation MPWeakTimer

- (void)dealloc {
    [self.timer invalidate];
    self.timer = nil;
    self.target = nil;
    self.selector = nil;
}

- (BOOL)isValid {
    return self.timer.isValid;
}

- (NSDate *)fireDate {
    return self.timer.fireDate;
}

- (void)setFireDate:(NSDate *)fireDate {
    self.timer.fireDate = fireDate;
}

- (NSTimeInterval)timeInterval {
    return self.timer.timeInterval;
}

- (id)userInfo {
    return self.timer.userInfo;
}

- (NSTimeInterval)tolerance {
    return self.timer.tolerance;
}

- (void)setTolerance:(NSTimeInterval)tolerance {
    self.timer.tolerance = tolerance;
}

+ (MPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(void))block {
    MPWeakTimer *weakTimer = [[MPWeakTimer alloc] init];
    weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:repeats block:^(NSTimer * _Nonnull timer) {
        if (block) {
            block();
        }
    }];
    return weakTimer;
}

+ (MPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo {
    return [self scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo mainQueue:NO];
}

+ (MPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(id)userInfo repeats:(BOOL)yesOrNo mainQueue:(BOOL)addToMainQueue {
    MPWeakTimer *weakTimer = [[MPWeakTimer alloc] init];
    weakTimer.timer = [NSTimer timerWithTimeInterval:ti target:weakTimer selector:@selector(onFire) userInfo:userInfo repeats:yesOrNo];
    if (addToMainQueue) {
        if ([NSThread isMainThread]) {
            weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
        } else {
            dispatch_sync(dispatch_get_main_queue(), ^{
                weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
            });
        }
    } else {
        weakTimer.timer = [NSTimer scheduledTimerWithTimeInterval:ti target:aTarget selector:aSelector userInfo:userInfo repeats:yesOrNo];
    }
    weakTimer.target = aTarget;
    weakTimer.selector = aSelector;
    weakTimer.userInfo = userInfo;
    return weakTimer;
}
- (void)onFire {
    if (self.target) {
        NSMethodSignature *signature = [[self.target class] instanceMethodSignatureForSelector:self.selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        invocation.target = self.target;
        invocation.selector = self.selector;
        NSInteger paramtersCount = signature.numberOfArguments - 2;
        if (self.userInfo == nil) {
            paramtersCount = MIN(0, paramtersCount);
        } else {
            paramtersCount = MIN([self.userInfo count], paramtersCount);
            for (int i = 0; i < paramtersCount; i++) {
                id obj = self.userInfo[i];
                if ([obj isKindOfClass:[NSNull class]]) continue;
                [invocation setArgument:&obj atIndex:i + 2];
            }
        }
        [invocation invoke];
    }
}

- (void)fire {
    [self.timer fire];
}

- (void)invalidate {
    [self.timer invalidate];
}

@end
