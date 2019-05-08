//
//  MPDeviceHeartbeatManager.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPDeviceHeartbeatManager.h"
#import "MPWeakTimer.h"
#import "MPPackageManager.h"

@interface MPDeviceHeartbeatManager ()
@property (nonatomic, assign) BOOL isHeartbeatNormal;
@property (nonatomic, assign) NSUInteger currentRemoteHeartbeatCount;
@property (nonatomic, assign) NSUInteger lastRemoteHeartbeatCount;
@property (nonatomic, assign) NSUInteger heartbeatLostCount;


@property (nonatomic, strong) MPWeakTimer *timer;
@end

@implementation MPDeviceHeartbeatManager
NS_CLOSE_SIGNAL_WARN(onRecvRemoteDeviceHeartbeat)
NS_CLOSE_SIGNAL_WARN(onLostRemoteDeviceHeartbeat)

static MPDeviceHeartbeatManager *instance = nil;
- (instancetype)init {
    self = [super init];
    if (self) {
        _currentRemoteHeartbeatCount = 0;
        _lastRemoteHeartbeatCount = 0;
        _heartbeatLostCount = 0;
        _isHeartbeatNormal = NO;
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MPDeviceHeartbeatManager sharedInstance];
}

- (id)copy {
    return [MPDeviceHeartbeatManager sharedInstance];
}

- (void)setIsHeartbeatNormal:(BOOL)isHeartbeatNormal {
    _isHeartbeatNormal = isHeartbeatNormal;
    if (isHeartbeatNormal) {
        [self emitSignal:@selector(onRecvRemoteDeviceHeartbeat) withParams:nil];
    } else {
        [self emitSignal:@selector(onLostRemoteDeviceHeartbeat) withParams:nil];
    }
}

- (MPWeakTimer *)timer {
    if (_timer != nil) {
        return _timer;
    }
    _timer = [MPWeakTimer scheduledTimerWithTimeInterval:self.heartbeatInterval target:self selector:@selector(sendHeartbeatToRemote) userInfo:nil repeats:YES];
    return _timer;
}

- (void)setHeartbeatInterval:(NSTimeInterval)heartbeatInterval {
    _heartbeatInterval = heartbeatInterval;
    [_timer invalidate];
    [self.timer fire];
}

- (void)run {
    __weak typeof(self) weakSelf = self;
    self.currentRemoteHeartbeatCount = 0;
    self.lastRemoteHeartbeatCount = 0;
    self.heartbeatLostCount = 0;
    _isHeartbeatNormal = NO;
    
    [[MPPackageManager sharedInstance] listenMessage:[MVMessageHeartbeat class] withObserver:self handler:^(MVMessage * _Nullable message, MPPackageManagerResultHandingType * _Nonnull handingType) {
        *handingType = MPPackageManagerResultHandingTypeContinue;
        weakSelf.currentRemoteHeartbeatCount++;
        if (weakSelf.isHeartbeatNormal == NO) {
            weakSelf.isHeartbeatNormal = YES;
        }
    }];
    [self.timer fire];
}

- (void)stop {
    _timer = nil;
    _isHeartbeatNormal = NO;
}

#pragma mark - Slots
- (void)sendHeartbeatToRemote {
    __weak typeof(self) weakSelf = self;
    MVMessageHeartbeat *heartbeatMessage = [[MVMessageHeartbeat alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_SYSTEM_ID_IOS type:MAV_TYPE_GCS autopilot:MAV_AUTOPILOT_GENERIC baseMode:MAV_MODE_FLAG_ENUM_END customMode:0 systemStatus:MAV_STATE_ACTIVE];
    [[MPPackageManager sharedInstance] sendMessageWithoutAck:heartbeatMessage];
    
    if (weakSelf.currentRemoteHeartbeatCount == weakSelf.lastRemoteHeartbeatCount) {
        weakSelf.heartbeatLostCount++;
        if (weakSelf.heartbeatLostCount > 5) {
            // disconnect;
            weakSelf.isHeartbeatNormal = NO;
            [weakSelf stop];
        }
    } else {
        weakSelf.lastRemoteHeartbeatCount = weakSelf.currentRemoteHeartbeatCount;
        weakSelf.heartbeatLostCount = 0;
    }
}

- (void)stopSendHeartbeatToRemote {
    [self stop];
}

@end
