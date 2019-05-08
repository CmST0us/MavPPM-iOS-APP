//
//  MPUnlockGravityControl.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import <NSObjectSignals/NSObject+SignalsSlots.h>
NS_ASSUME_NONNULL_BEGIN

@interface MPUnlockGravityControl : MPGravityDeviceMotionControl
@property (nonatomic, readonly) BOOL isLock;

- (NS_SIGNAL)onUnlock;

@end

NS_ASSUME_NONNULL_END
