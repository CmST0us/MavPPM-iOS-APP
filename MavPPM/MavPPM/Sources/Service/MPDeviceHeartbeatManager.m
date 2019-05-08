//
//  MPDeviceHeartbeatManager.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPDeviceHeartbeatManager.h"

@interface MPDeviceHeartbeatManager ()
@property (nonatomic, assign) BOOL isHeartbeatNormal;
@property (nonatomic, assign) NSUInteger currentRemoteHeartbeatCount;
@property (nonatomic, assign) NSUInteger lastRemoteHeartbeatCount;
@property (nonatomic, assign) NSUInteger heartbeatLostCount;

@end

@implementation MPDeviceHeartbeatManager
NS_CLOSE_SIGNAL_WARN(onRecvRemoteDeviceHeartbeat)
NS_CLOSE_SIGNAL_WARN(onLostRemoteDeviceHeartbeat)

static MPDeviceHeartbeatManager *instance = nil;

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


#pragma mark - Slots
- (void)startSendHeartbeatToRemote {
    
}

- (void)startListenRemoteDeviceHeartbeat {
    
}

- (void)stopSendHeartbeatToRemote {
    
}

@end
