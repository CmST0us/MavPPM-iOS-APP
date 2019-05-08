//
//  MPUAVGravityControl.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import <NSObjectSignals/NSObject+SignalsSlots.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPUAVGravityControl : MPGravityDeviceMotionControl
@property (nonatomic, assign) double rollValue;
@property (nonatomic, assign) double pitchValue;


- (NS_SIGNAL)onFeedback;
@end

NS_ASSUME_NONNULL_END
