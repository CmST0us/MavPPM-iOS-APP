//
//  MPUAVGravityControl.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPUAVGravityControl.h"

@interface MPUAVGravityControl ()
@property (nonatomic, assign) double lastRoll;
@property (nonatomic, assign) double lastPitch;
@end

@implementation MPUAVGravityControl
NS_CLOSE_SIGNAL_WARN(onFeedback);

- (instancetype)init {
    self = [super init];
    if (self) {
        _lastRoll = 0;
        _lastPitch = 0;
        _rollValue = 0;
        _pitchValue = 0;
    }
    return self;
}

- (void)onUpdataData {
    double rollValue = self.data.attitude.pitch;
    double pitchValue = self.data.attitude.roll;
    
    double rollDeg = RADToDEG(rollValue);
    double pitchDeg = RADToDEG(pitchValue);
    
    double lastRollDeg = RADToDEG(self.lastRoll);
    double lastPitchDeg = RADToDEG(self.lastPitch);
    
    self.rollValue = rollValue;
    self.pitchValue = pitchValue;
    
    if (ABS(lastRollDeg - rollDeg) > 1) {
        self.lastRoll = rollValue;
        [self emitSignal:@selector(onFeedback) withParams:nil];
    }
    
    if (ABS(lastPitchDeg - pitchDeg) > 1) {
        self.lastPitch = pitchValue;
        [self emitSignal:@selector(onFeedback) withParams:nil];
    }
    
    if (ABS(lastPitchDeg - pitchDeg) > 1 &&
        ABS(lastRollDeg - rollDeg) > 1 &&
        ABS(rollDeg) < 1 &&
        ABS(pitchDeg) < 1) {
        self.lastRoll = rollValue;
        self.lastPitch = pitchValue;
    }

}

@end
