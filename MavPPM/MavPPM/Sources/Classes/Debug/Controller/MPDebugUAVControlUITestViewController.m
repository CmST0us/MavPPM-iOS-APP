//
//  MPDebugUAVControlUITestViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/11.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPCMMotionManager.h"

#import "MPDebugUAVControlUITestViewController.h"
#import "MPGravityRollIndicateView.h"
#import "MPGraviryPitchRollIndicateView.h"
#import "MPThrottleControlView.h"
#import "MPYawControlView.h"

@interface MPDebugUAVControlUITestViewController ()<MPGravityControlDelegate>

@property (nonatomic, assign) CGPoint throttleBeginPoint;
@property (nonatomic, assign) CGFloat throttleValue;

@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) MPGravityRollIndicateView *rollIndicateView;
@property (nonatomic, strong) MPGraviryPitchRollIndicateView *circleIndicateView;
@property (nonatomic, strong) MPThrottleControlView *throttleControlView;
@property (nonatomic, strong) MPYawControlView *yawControlView;
@property (nonatomic, strong) MPMotionManager *motionManager;
@property (nonatomic, strong) MPGravityDeviceMotionControl *deviceMotionControl;
@end

@implementation MPDebugUAVControlUITestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor controlBgBlack];
    
    self.throttleValue = 1000;
    
    self.label = [[UILabel alloc] init];
    [self.view addSubview:self.label];
    [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(12);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    self.label.text = @"Hello World";
    
    self.throttleControlView = [[MPThrottleControlView alloc] init];
    [self.view addSubview:self.throttleControlView];
    [self.throttleControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.rollIndicateView = [[MPGravityRollIndicateView alloc] init];
    [self.view addSubview:self.rollIndicateView];
    [self.rollIndicateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.circleIndicateView = [[MPGraviryPitchRollIndicateView alloc] init];
    [self.view addSubview:self.circleIndicateView];
    [self.circleIndicateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.yawControlView = [[MPYawControlView alloc] init];
    [self.view addSubview:self.yawControlView];
    [self.yawControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    self.deviceMotionControl = [[MPGravityDeviceMotionControl alloc] init];
    self.deviceMotionControl.delegate = self;
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
}

- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    double rollValue = self.deviceMotionControl.data.attitude.pitch;
    double pitchValue = self.deviceMotionControl.data.attitude.roll;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rollIndicateView.rollValue = @(rollValue);
        self.circleIndicateView.rollValue = @(rollValue);
        self.circleIndicateView.pitchValue = @(pitchValue);
    });
}

- (BOOL)shouldAutorotate {
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end

