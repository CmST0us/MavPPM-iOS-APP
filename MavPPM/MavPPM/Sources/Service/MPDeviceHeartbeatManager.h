//
//  MPDeviceHeartbeatManager.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSObjectSignals/NSObject+SignalsSlots.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPDeviceHeartbeatManager : NSObject

@property (nonatomic, assign) NSTimeInterval heartbeatInterval; // Default is 1s;
@property (nonatomic, readonly) BOOL isHeartbeatNormal;
+ (instancetype)sharedInstance;

// Signals
- (NS_SIGNAL)onRecvRemoteDeviceHeartbeat;
- (NS_SIGNAL)onLostRemoteDeviceHeartbeat;

// Slot
- (NS_SLOT)startListenRemoteDeviceHeartbeat;
- (NS_SLOT)startSendHeartbeatToRemote;
- (NS_SLOT)stopSendHeartbeatToRemote;

@end

NS_ASSUME_NONNULL_END
