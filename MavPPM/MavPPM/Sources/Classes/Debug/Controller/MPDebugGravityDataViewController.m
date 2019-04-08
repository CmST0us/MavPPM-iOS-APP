//
//  MPDebugGravityDataViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/4/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import <MPGravityControlLogic/MPGravityDeviceMotionControl.h>
#import "MPDebugGravityDataViewController.h"
#import "MPCMMotionManager.h"

@interface MPDebugGravityDataViewController () <MPGravityControlDelegate>
@property (nonatomic, strong) MPMotionManager *motionManager;
@property (nonatomic, strong) MPGravityDeviceMotionControl *deviceMotionControl;
@property (nonatomic, strong) MPControlValueLinear *rollLinear;
@property (nonatomic, strong) MPControlValueLinear *pitchLinear;
@end

@implementation MPDebugGravityDataViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 10.0;
    self.deviceMotionControl = [[MPGravityDeviceMotionControl alloc] init];
    self.deviceMotionControl.delegate = self;
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
    
    self.rollLinear = [[MPControlValueLinear alloc] initWithOutputMax:2000 outputMin:1000 inputMax:90 inputMin:-90];
    self.pitchLinear = [[MPControlValueLinear alloc] initWithOutputMax:2000 outputMin:1000 inputMax:90 inputMin:-90];
    
}

- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    double rollValue = self.deviceMotionControl.data.attitude.pitch;
    double pitchValue = self.deviceMotionControl.data.attitude.roll;
    double rollDeg = RADToDEG(rollValue);
    double pitchDeg = RADToDEG(pitchValue);
    
    double rollControl = [self.rollLinear calc:rollDeg];
    double pitchControl = [self.pitchLinear calc:pitchDeg];
//    printf("roll\t%f\t%f\n", rollDeg, rollControl);
    printf("pitch\t%f\t%f\n", pitchDeg, pitchControl);
}

@end
