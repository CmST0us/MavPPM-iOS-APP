//
//  MPMainUAVControlViewController.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPViewController.h"

NS_ASSUME_NONNULL_BEGIN
@class MPDeviceHeartbeat;
@interface MPMainUAVControlViewController : MPViewController
@property (nonatomic, strong) MPDeviceHeartbeat *heartbeatListener;
@end

NS_ASSUME_NONNULL_END
