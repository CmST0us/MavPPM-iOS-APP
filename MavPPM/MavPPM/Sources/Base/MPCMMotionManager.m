//
//  MPCMMotionManager.m
//  MavPPM
//
//  Created by CmST0us on 2019/2/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPCMMotionManager.h"

@implementation MPCMMotionManager
static MPCMMotionManager *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MPCMMotionManager sharedInstance];
}

- (id)copy {
    return [MPCMMotionManager sharedInstance];
}

- (CMMotionManager *)motionManager {
    if (_motionManager != nil) {
        return _motionManager;
    }
    return [[CMMotionManager alloc] init];
}

+ (CMMotionManager *)motionManager {
    return [MPCMMotionManager sharedInstance].motionManager;
}

@end
