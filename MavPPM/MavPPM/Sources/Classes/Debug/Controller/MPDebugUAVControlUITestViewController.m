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
@property (nonatomic, assign) CGFloat lastRoll;
@property (nonatomic, assign) CGFloat lastPitch;
@property (nonatomic, assign) NSInteger unlockConfirmCount;
@property (nonatomic, assign) BOOL isLock;

@property (nonatomic, strong) UILabel *attitudeInfoLabel;
@property (nonatomic, strong) UIImageView *controlLockView;
@property (nonatomic, strong) UIAlertController *unlockAlertController;

@property (nonatomic, strong) MPGravityRollIndicateView *rollIndicateView;
@property (nonatomic, strong) MPGraviryPitchRollIndicateView *circleIndicateView;
@property (nonatomic, strong) MPThrottleControlView *throttleControlView;
@property (nonatomic, strong) MPYawControlView *yawControlView;
@property (nonatomic, strong) MPMotionManager *motionManager;
@property (nonatomic, strong) MPGravityDeviceMotionControl *deviceMotionControl;

@property (nonatomic, strong) UIImpactFeedbackGenerator *lightFeedback;
@property (nonatomic, strong) UIImpactFeedbackGenerator *heavyFeedback;
@end

@implementation MPDebugUAVControlUITestViewController

- (void)tryUnlock {
    self.unlockAlertController = [UIAlertController alertControllerWithTitle:@"MavPPM" message:NSLocalizedString(@"mavppm_control_view_try_unlock_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:self.unlockAlertController animated:YES completion:^{
        [self unlock];
    }];
}

- (void)unlock {
    self.throttleValue = 1000;
    _lastRoll = 0;
    _lastPitch = 0;
    _unlockConfirmCount = 0;
    
    self.lightFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    self.heavyFeedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [self.lightFeedback prepare];
    [self.heavyFeedback prepare];
    
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
    [self setAttitudeInfoWithPitch:self.lastPitch roll:self.lastRoll];
    [self.attitudeInfoLabel sizeToFit];
    [self.view addSubview:self.attitudeInfoLabel];
    [self.attitudeInfoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(-28);
        make.left.equalTo(self.view.mas_centerX).offset(100);
    }];
    
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    self.deviceMotionControl = [[MPGravityDeviceMotionControl alloc] init];
    self.deviceMotionControl.delegate = self;
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
    
    [self.controlLockView removeFromSuperview];
    self.controlLockView = nil;
}

- (void)lock {
    [self.throttleControlView removeFromSuperview];
    self.throttleControlView = nil;
    [self.yawControlView removeFromSuperview];
    self.yawControlView = nil;
    [self.rollIndicateView removeFromSuperview];
    self.rollIndicateView = nil;
    [self.circleIndicateView removeFromSuperview];
    self.circleIndicateView = nil;
    [self.attitudeInfoLabel removeFromSuperview];
    self.attitudeInfoLabel = nil;
    [self.motionManager stop];
    self.motionManager = nil;
    self.deviceMotionControl = nil;
    
    self.controlLockView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"control_view_lock"]];
    [self.view addSubview:self.controlLockView];
    [self.controlLockView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
    }];
    self.controlLockView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tryUnlock)];
    [self.controlLockView addGestureRecognizer:tap];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor controlBgBlack];
    _isLock = YES;
    [self lock];
}

- (void)setAttitudeInfoWithPitch:(CGFloat)pitch
                            roll:(CGFloat)roll {
    [[NSRunLoop mainRunLoop] performBlock:^{
        self.attitudeInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"mavppm_control_view_attitude_info", @"姿态信息"), RADToDEG(roll), RADToDEG(pitch)];
    }];
}

- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    double rollValue = self.deviceMotionControl.data.attitude.pitch;
    double pitchValue = self.deviceMotionControl.data.attitude.roll;
    double rollDeg = RADToDEG(rollValue);
    double pitchDeg = RADToDEG(pitchValue);
    double lastRollDeg = RADToDEG(self.lastRoll);
    double lastPitchDeg = RADToDEG(self.lastPitch);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.isLock) {
            if (ABS(rollDeg) < 2 &&
                ABS(pitchDeg) < 2) {
                self.unlockConfirmCount++;
                if (self.unlockConfirmCount > 100) {
                    self.isLock = NO;
                    [self.unlockAlertController dismissViewControllerAnimated:YES completion:nil];
                    self.unlockConfirmCount = 0;
                }
            }
        } else {
            if (ABS(lastRollDeg - rollDeg) > 1) {
                [self.lightFeedback impactOccurred];
                self.lastRoll = rollValue;
            }
            if (ABS(lastPitchDeg - pitchDeg) > 1) {
                [self.lightFeedback impactOccurred];
                self.lastPitch = pitchValue;
            }
            if (ABS(lastPitchDeg - pitchDeg) > 1 &&
                ABS(lastRollDeg - rollDeg) > 1 &&
                ABS(rollDeg) < 1 &&
                ABS(pitchDeg) < 1) {
                [self.heavyFeedback impactOccurred];
                self.lastRoll = rollValue;
                self.lastPitch = pitchValue;
            }
            
            self.rollIndicateView.rollValue = @(rollValue);
            self.circleIndicateView.rollValue = @(rollValue);
            self.circleIndicateView.pitchValue = @(pitchValue);
        }
        [self setAttitudeInfoWithPitch:-pitchValue roll:rollValue];
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

