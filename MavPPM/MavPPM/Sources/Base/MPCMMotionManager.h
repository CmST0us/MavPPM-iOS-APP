//
//  MPCMMotionManager.h
//  MavPPM
//
//  Created by CmST0us on 2019/2/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
NS_ASSUME_NONNULL_BEGIN

@interface MPCMMotionManager : NSObject
@property (nonatomic, strong) CMMotionManager *motionManager;
+ (CMMotionManager *)motionManager;
+ (instancetype)sharedInstance;
@end

NS_ASSUME_NONNULL_END
