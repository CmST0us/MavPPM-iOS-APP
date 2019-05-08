//
//  MPUnlockGravityControl.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPUnlockGravityControl.h"

@interface MPUnlockGravityControl ()
@property (nonatomic, assign) NSUInteger unlockConfirmCount;
@property (nonatomic, assign) BOOL isLock;
@end

@implementation MPUnlockGravityControl
NS_CLOSE_SIGNAL_WARN(onUnlock);

- (instancetype)init {
    self = [super init];
    if (self) {
        _unlockConfirmCount = 0;
        _isLock = YES;
    }
    return self;
}

- (void)setIsLock:(BOOL)isLock {
    _isLock = isLock;
    if (isLock == NO) {
        [self emitSignal:@selector(onUnlock) withParams:nil];
    }
}

- (void)onUpdataData {
    double rollValue = self.data.attitude.pitch;
    double pitchValue = self.data.attitude.roll;
    
    double rollDeg = RADToDEG(rollValue);
    double pitchDeg = RADToDEG(pitchValue);
    
    if (ABS(rollDeg) < 2 &&
        ABS(pitchDeg) < 2) {
        self.unlockConfirmCount++;
        if (self.unlockConfirmCount > 50) {
            self.isLock = NO;
            self.unlockConfirmCount = 0;
        }
    }
}

@end
