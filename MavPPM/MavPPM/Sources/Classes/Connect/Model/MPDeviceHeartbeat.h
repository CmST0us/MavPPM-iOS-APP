//
//  MPDeviceHeartbeat.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

// 请监听这两个事件判断设备是否连接成功
extern NSNotificationName MPDeviceHeartbeatNormalNotificationName;
extern NSNotificationName MPDeviceHeartbeatLostNotificationName;

@interface MPDeviceHeartbeat : NSObject
@property (nonatomic, assign) NSTimeInterval heartbeatInterval;
- (void)startListenAndSendHeartbeat;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
