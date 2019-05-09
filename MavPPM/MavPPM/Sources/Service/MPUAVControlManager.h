//
//  MPUAVControlManager.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPServiceProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@interface MPUAVControlManager : NSObject<MPServiceProtocol>

@property (nonatomic, assign) NSTimeInterval sendTimeInterval;

@property (nonatomic, assign) NSInteger throttle;
@property (nonatomic, assign) NSInteger roll;
@property (nonatomic, assign) NSInteger pitch;
@property (nonatomic, assign) NSInteger yaw;
@property (nonatomic, assign) uint8_t buttons;

+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
