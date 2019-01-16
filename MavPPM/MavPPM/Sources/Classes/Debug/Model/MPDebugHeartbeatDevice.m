//
//  MPDebugHeartbeatDevice.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/17.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPDebugHeartbeatDevice.h"

@interface MPDebugHeartbeatDevice () {
    
}
@property (nonatomic, strong) MPUDPSocket *udp;
@property (nonatomic, strong) MVMavlink *mavlink;
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@end

@implementation MPDebugHeartbeatDevice
- (instancetype)initWithLocalPort:(short)localPort
                       RemotePort:(short)remotePort{
    self = [super init];
    if (self) {
        _udp = [[MPUDPSocket alloc] initWithLocalPort:localPort delegate:self];
        [_udp connect:@"127.0.0.1" port:remotePort];
        _mavlink = [[MVMavlink alloc] init];
        _mavlink.delegate = self;
    }
    return self;
}

- (void)start {
    __weak typeof(self) weakSelf = self;
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        MVMessageHeartbeat *message = [[MVMessageHeartbeat alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_SYSTEM_ID_IOS type:MAV_TYPE_GENERIC autopilot:MAV_AUTOPILOT_GENERIC baseMode:0 customMode:0 systemStatus:MAV_STATE_STANDBY];
        [weakSelf.udp write:[message data]];
    }];
}

- (void)stop {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
}

- (void)dealloc {
    [self stop];
}

- (void)communicator:(id)aCommunicator handleEvent:(MPCommEvent)event {
    if (event == MPCommEventHasBytesAvailable) {
        [aCommunicator read];
    }
}

- (void)communicator:(id)aCommunicator didReadData:(NSData *)data {
    [self.mavlink parseData:data];
}

- (void)mavlink:(MVMavlink *)mavlink didGetMessage:(id<MVMessage>)message {
    NSLog(@"[DEBUG][HEARTBEATDEVICE]: %@", message);
}

- (BOOL)mavlink:(MVMavlink *)mavlink shouldWriteData:(NSData *)data {
    return YES;
}

@end
