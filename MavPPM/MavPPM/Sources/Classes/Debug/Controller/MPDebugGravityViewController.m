//
//  MPDebugGravityViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/2/10.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import <SceneKit/SceneKit.h>

#import "MPCMMotionManager.h"
#import "MPDebugGravityViewController.h"

@interface MPDebugQuaternionConvertControlLogic: MPGravityDeviceMotionControl

@end

@implementation MPDebugQuaternionConvertControlLogic

- (SCNVector3)toEulerAngles {
    SCNVector3 v;
    CMQuaternion rq = self.data.attitude.quaternion;
    v.x = -asin(-2 * (rq.y * rq.z + rq.w * rq.x));
    v.y = -atan2(-rq.x * rq.z - rq.w * rq.y, .5 - rq.y * rq.y - rq.z * rq.z);
    v.z = atan2(rq.x * rq.y - rq.w * rq.z, .5 - rq.x * rq.x - rq.z * rq.z);
    return v;
}

- (void)onUpdataData {
    SCNVector3 v = [self toEulerAngles];
    
}

@end

@interface MPDebugGravityViewController ()
@property (nonatomic, strong) MPMotionManager *motionManager;
@property (nonatomic, strong) MPDebugQuaternionConvertControlLogic *deviceMotionControl;
@end

@implementation MPDebugGravityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.deviceMotionControl = [[MPDebugQuaternionConvertControlLogic alloc] init];
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
    // Do any additional setup after loading the view.
}

@end
