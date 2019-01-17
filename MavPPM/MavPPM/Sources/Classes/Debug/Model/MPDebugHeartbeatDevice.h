//
//  MPDebugHeartbeatDevice.h
//  MavPPM
//
//  Created by CmST0us on 2019/1/17.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MPMavlink/MPMavlink.h>
#import <MPCommLayer/MPCommLayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPDebugHeartbeatDevice : NSObject<MPCommDelegate, MVMavlinkDelegate>

- (instancetype)initWithLocalPort:(short)localPort
                       RemotePort:(short)remotePort;

- (void)start;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
