//
//  MPWeakTimer.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPWeakTimer : NSObject

@property(readonly, getter=isValid) BOOL valid;
@property(copy) NSDate *fireDate;
@property(readonly) NSTimeInterval timeInterval;
@property(readonly, weak) id userInfo;
@property NSTimeInterval tolerance;

+ (MPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)interval repeats:(BOOL)repeats block:(void (^)(void))block;
+ (MPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
+ (MPWeakTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo mainQueue:(BOOL)addToMainQueue;

- (void)fire;
- (void)invalidate;
@end

NS_ASSUME_NONNULL_END
