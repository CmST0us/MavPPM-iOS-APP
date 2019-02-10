//
//  MPDebugGravityViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/2/10.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPCMMotionManager.h"

#import "MPDebugGravityViewController.h"

@interface MPDebugGravityViewController ()<MPGravityControlDelegate>
@property (nonatomic, strong) MPMotionManager *motionManager;
@property (nonatomic, strong) MPGravityDeviceMotionControl *deviceMotionControl;
@end

@implementation MPDebugGravityViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.deviceMotionControl = [[MPGravityDeviceMotionControl alloc] init];
    self.deviceMotionControl.delegate = self;
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
    
    // Do any additional setup after loading the view.
}

- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    NSLog(@"%@", self.deviceMotionControl.data.attitude);
}

@end
