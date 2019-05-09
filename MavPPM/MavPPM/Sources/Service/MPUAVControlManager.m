//
//  MPUAVControlManager.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPUAVControlManager.h"
#import "MPWeakTimer.h"
#import "MPPackageManager.h"

@interface MPUAVControlManager ()
@property (nonatomic, strong) MPWeakTimer *sendTimer;
@end

@implementation MPUAVControlManager

static MPUAVControlManager *instance = nil;

- (instancetype)init {
    self = [super init];
    if (self) {
        _sendTimeInterval = 1 / 10.0;
        _throttle = 1000;
        _roll = 1500;
        _pitch = 1500;
        _yaw = 1500;
        _buttons = 0;
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
    return [MPUAVControlManager sharedInstance];
}

- (id)copy {
    return [MPUAVControlManager sharedInstance];
}

- (void)setSendTimeInterval:(NSTimeInterval)sendTimeInterval {
    if (_sendTimeInterval != sendTimeInterval) {
        _sendTimer = nil;
        [self.sendTimer fire];
    }
    _sendTimeInterval = sendTimeInterval;
}

- (MPWeakTimer *)sendTimer {
    if (_sendTimer) {
        return _sendTimer;
    }
    _sendTimer = [MPWeakTimer scheduledTimerWithTimeInterval:self.sendTimeInterval target:self selector:@selector(sendControlMessage) userInfo:nil repeats:YES];
    return _sendTimer;
}

- (void)sendControlMessage {
    MVMessageManualControl *manualControlMessage = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_SYSTEM_ID_IOS target:MAVPPM_SYSTEM_ID_EMB x:self.pitch y:self.roll z:self.throttle r:self.yaw buttons:self.buttons];
    [[MPPackageManager sharedInstance] sendMessageWithoutAck:manualControlMessage];
}

- (void)run {
    [self.sendTimer fire];
}

- (void)stop {
    [_sendTimer invalidate];
    _sendTimer = nil;
}

@end
