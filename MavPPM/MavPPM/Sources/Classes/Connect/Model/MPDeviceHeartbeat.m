//
//  MPDeviceHeartbeat.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPPackageManager.h"
#import "MPDeviceHeartbeat.h"

NSNotificationName MPDeviceHeartbeatNormalNotificationName = @"MPDeviceHeartbeatNormalNotificationName";
NSNotificationName MPDeviceHeartbeatLostNotificationName = @"MPDeviceHeartbeatLostNotificationName";

@interface MPDeviceHeartbeat ()

@property (nonatomic, assign) BOOL heartbeatNormal;
@property (nonatomic, assign) NSUInteger heartbeatCount;
@property (nonatomic, assign) NSUInteger lastHeartbeatCount;
@property (nonatomic, assign) NSUInteger heartbeatLostCount;

@property (nonatomic, strong) NSTimer *sendHeartbeatTimer;
@end

@implementation MPDeviceHeartbeat
- (instancetype)init {
    self = [super init];
    if (self) {
        _heartbeatInterval = 1.0;
        _heartbeatNormal = NO;
    }
    return self;
}

- (void)dealloc {
    [self.sendHeartbeatTimer invalidate];
    self.sendHeartbeatTimer = nil;
}

- (void)startListenAndSendHeartbeat {
    _heartbeatCount = 0;
    _lastHeartbeatCount = 0;
    _heartbeatLostCount = 0;
    
    __weak typeof(self) weakSelf = self;
    self.sendHeartbeatTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:self.heartbeatInterval repeats:YES block:^(NSTimer * _Nonnull timer) {
        MVMessageHeartbeat *heartbeatMessage = [[MVMessageHeartbeat alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_SYSTEM_ID_IOS type:MAV_TYPE_GCS autopilot:MAV_AUTOPILOT_GENERIC baseMode:MAV_MODE_FLAG_ENUM_END customMode:0 systemStatus:MAV_STATE_ACTIVE];
        [[MPPackageManager sharedInstance] sendMessageWithoutAck:heartbeatMessage];
        
        if (weakSelf.heartbeatCount == weakSelf.lastHeartbeatCount) {
            weakSelf.heartbeatLostCount++;
            if (weakSelf.heartbeatLostCount > 5) {
                // disconnect;
                weakSelf.heartbeatNormal = NO;
                [[NSNotificationCenter defaultCenter] postNotificationName:MPDeviceHeartbeatLostNotificationName object:nil];
                [self stop];
            }
        } else {
            weakSelf.lastHeartbeatCount = weakSelf.heartbeatCount;
            weakSelf.heartbeatLostCount = 0;
        }
    }];
    
    [[MPPackageManager sharedInstance] listenMessage:[MVMessageHeartbeat class] withObserver:self handler:^(MVMessage * _Nullable message, MPPackageManagerResultHandingType * _Nonnull handingType) {
        *handingType = MPPackageManagerResultHandingTypeContinue;
        weakSelf.heartbeatCount++;
        if (weakSelf.heartbeatNormal == NO) {
            [[NSNotificationCenter defaultCenter] postNotificationName:MPDeviceHeartbeatNormalNotificationName object:nil];
            weakSelf.heartbeatNormal = YES;
        }
    }];
    
    [[NSRunLoop currentRunLoop] addTimer:self.sendHeartbeatTimer forMode:NSRunLoopCommonModes];
    [self.sendHeartbeatTimer fire];
}

- (void)stop {
    [self.sendHeartbeatTimer invalidate];
    self.sendHeartbeatTimer = nil;
}

@end
