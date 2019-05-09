//
//  MPMainUAVControlViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MPGravityControlLogic/MPGravityControlLogic.h>

#import "MPNavigationController.h"
#import "MPCMMotionManager.h"
#import "MPMainUAVControlViewController.h"
#import "MPGravityRollIndicateView.h"
#import "MPGraviryPitchRollIndicateView.h"
#import "MPThrottleControlView.h"
#import "MPYawControlView.h"
#import "MPPackageManager.h"
#import "MPDeviceHeartbeat.h"
#import "MPBindThrottleChannelViewController.h"
#import "MPDeviceHeartbeatManager.h"
#import "MPUAVGravityControl.h"
#import "MPWeakTimer.h"
#import "MPUAVControlManager.h"

@interface MPMainUAVControlViewController () <MPGravityControlDelegate>

@property (nonatomic, strong) UILabel *attitudeInfoLabel;
@property (nonatomic, strong) MPGravityRollIndicateView *rollIndicateView;
@property (nonatomic, strong) MPGraviryPitchRollIndicateView *circleIndicateView;
@property (nonatomic, strong) MPThrottleControlView *throttleControlView;
@property (nonatomic, strong) MPYawControlView *yawControlView;
@property (nonatomic, strong) MPMotionManager *motionManager;
@property (nonatomic, strong) MPUAVGravityControl *deviceMotionControl;

@property (nonatomic, strong) UIImpactFeedbackGenerator *lightFeedback;

@property (nonatomic, strong) MPControlValueLinear *rollLinear;
@property (nonatomic, strong) MPControlValueLinear *pitchLinear;
@end

@implementation MPMainUAVControlViewController

- (void)setupView {
    self.lightFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [self.lightFeedback prepare];
    
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
    
    self.attitudeInfoLabel = [[UILabel alloc] init];
    self.attitudeInfoLabel.font = [UIFont systemFontOfSize:15];
    self.attitudeInfoLabel.textColor = [UIColor whiteColor];
    [self setAttitudeInfoWithPitch:0 roll:0];
    [self.attitudeInfoLabel sizeToFit];
    [self.view addSubview:self.attitudeInfoLabel];
    [self.attitudeInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-28);
        make.left.equalTo(self.view.mas_centerX).offset(100);
    }];
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor controlBgBlack];
    
    [self setupView];
    
    self.rollLinear = [[MPControlValueLinear alloc] initWithOutputMax:2000 outputMin:1000 inputMax:M_PI_2 inputMin:-M_PI_2];
    self.pitchLinear = [[MPControlValueLinear alloc] initWithOutputMax:2000 outputMin:1000 inputMax:M_PI_2 inputMin:-M_PI_2];
    
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    self.deviceMotionControl = [[MPUAVGravityControl alloc] init];
    self.deviceMotionControl.delegate = self;
    [self.deviceMotionControl connectSignal:@selector(onFeedback) forObserver:self slot:@selector(deviceMotionFeedback)];
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
    
    [[MPPackageManager sharedInstance] connectSignal:@selector(onDetattch) forObserver:self slot:@selector(deviceDetattch)];
    [[MPDeviceHeartbeatManager sharedInstance] connectSignal:@selector(onLostRemoteDeviceHeartbeat) forObserver:self slot:@selector(heartbeatLost)];
    [[MPUAVControlManager sharedInstance] run];
}

- (void)setAttitudeInfoWithPitch:(CGFloat)pitch
                            roll:(CGFloat)roll {
    [[NSRunLoop mainRunLoop] performBlock:^{
        self.attitudeInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"mavppm_control_view_attitude_info", @"姿态信息"), RADToDEG(roll), RADToDEG(pitch)];
    }];
}

- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rollIndicateView.rollValue = @(self.deviceMotionControl.rollValue);
        self.circleIndicateView.rollValue = @(self.deviceMotionControl.rollValue);
        self.circleIndicateView.pitchValue = @(self.deviceMotionControl.pitchValue);
        [self setAttitudeInfoWithPitch:-self.deviceMotionControl.pitchValue roll:self.deviceMotionControl.rollValue];
        MPUAVControlManager *manager = [MPUAVControlManager sharedInstance];
        manager.throttle = self.throttleControlView.throttleValue.integerValue;
        manager.yaw = self.yawControlView.yawValue.integerValue;
        manager.roll = [self.rollLinear calc:self.deviceMotionControl.rollValue];
        manager.pitch = [self.pitchLinear calc:self.deviceMotionControl.pitchValue];
    });
}


#pragma mark - Notification
- (NS_SLOT)heartbeatLost {
    [[MPUAVControlManager sharedInstance] stop];
}

- (NS_SLOT)deviceDetattch {
    [self heartbeatLost];
    [[NSRunLoop mainRunLoop] performBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (NS_SLOT)deviceMotionFeedback {
    [[NSRunLoop mainRunLoop] performBlock:^{
        [self.lightFeedback impactOccurred];
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
