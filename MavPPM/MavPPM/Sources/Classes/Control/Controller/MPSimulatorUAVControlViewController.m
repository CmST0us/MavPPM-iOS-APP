//
//  MPSimulatorUAVControlViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/9.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <Masonry/Masonry.h>
#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPSimulatorUAVControlViewController.h"
#import "MPDeviceHeartbeatManager.h"
#import "MPUAVControlManager.h"
#import "MPPackageManager.h"
#import "UIColor+MavPPMColor.h"
#import "MPDeviceHeartbeatManager.h"
#import "MPGravityRollIndicateView.h"
#import "MPGraviryPitchRollIndicateView.h"
#import "MPThrottleControlView.h"
#import "MPYawControlView.h"
#import "MPCMMotionManager.h"
#import "MPUAVControlManager.h"
#import "MPUAVGravityControl.h"

@interface MPSimulatorUAVControlViewController () <MPGravityControlDelegate>
@property (nonatomic, strong) UITextField *targetAddressTextField;
@property (nonatomic, strong) UIButton *connectButton;
@property (nonatomic, strong) UIButton *disconnectButton;
@property (nonatomic, strong) UIButton *startManualControlButton;
@property (nonatomic, strong) UIButton *disarmButton;

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
@property (nonatomic, strong) MPControlValueLinear *throttleLinear;
@property (nonatomic, strong) MPControlValueLinear *yawLinear;

@end

@implementation MPSimulatorUAVControlViewController

- (void)setupUI {
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
    
    self.targetAddressTextField = [[UITextField alloc] init];
    [self.view addSubview:self.targetAddressTextField];
    [self.targetAddressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.equalTo(self.view).offset(32);
        make.width.mas_equalTo(170);
        make.height.mas_equalTo(30);
    }];
    self.targetAddressTextField.placeholder = NSLocalizedString(@"mavppm_simulator_address_placeholder", nil);
    self.targetAddressTextField.textColor = [UIColor whiteColor];
    [self.targetAddressTextField.layer setCornerRadius:4];
    [self.targetAddressTextField.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.targetAddressTextField.layer setBorderWidth:2];
    [self.targetAddressTextField.layer setMasksToBounds:YES];
    
    self.connectButton = [[UIButton alloc] init];
    [self.view addSubview:self.connectButton];
    [self.connectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.connectButton setTitle:NSLocalizedString(@"mavppm_simulator_connect", nil) forState:UIControlStateNormal];
    [self.connectButton setBackgroundColor:[UIColor clearColor]];
    [self.connectButton sizeToFit];
    [self.connectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.targetAddressTextField);
        make.top.equalTo(self.targetAddressTextField.mas_bottom).offset(12);
        make.width.mas_equalTo(90);
    }];
    
    [self.connectButton.layer setCornerRadius:4];
    [self.connectButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.connectButton.layer setBorderWidth:2];
    [self.connectButton.layer setMasksToBounds:YES];
    [self.connectButton addTarget:self action:@selector(connectTarget) forControlEvents:UIControlEventTouchUpInside];

    self.disconnectButton = [[UIButton alloc] init];
    [self.view addSubview:self.disconnectButton];
    [self.disconnectButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.disconnectButton setTitle:NSLocalizedString(@"mavppm_simulator_disconnect", nil) forState:UIControlStateNormal];
    [self.disconnectButton setBackgroundColor:[UIColor clearColor]];
    [self.disconnectButton sizeToFit];
    [self.disconnectButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.targetAddressTextField);
        make.top.equalTo(self.connectButton.mas_bottom).offset(12);
        make.width.mas_equalTo(90);
    }];
    
    [self.disconnectButton.layer setCornerRadius:4];
    [self.disconnectButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.disconnectButton.layer setBorderWidth:2];
    [self.disconnectButton.layer setMasksToBounds:YES];
    [self.disconnectButton addTarget:self action:@selector(disconnectTarget) forControlEvents:UIControlEventTouchUpInside];
    
    self.disarmButton = [[UIButton alloc] init];
    [self.view addSubview:self.disarmButton];
    [self.disarmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.disarmButton setTitle:NSLocalizedString(@"mavppm_simulator_disarm", nil) forState:UIControlStateNormal];
    [self.disarmButton setBackgroundColor:[UIColor clearColor]];
    [self.disarmButton sizeToFit];
    [self.disarmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.targetAddressTextField);
        make.top.equalTo(self.disconnectButton.mas_bottom).offset(12);
        make.width.mas_equalTo(90);
    }];
    
    [self.disarmButton.layer setCornerRadius:4];
    [self.disarmButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.disarmButton.layer setBorderWidth:2];
    [self.disarmButton.layer setMasksToBounds:YES];
    [self.disarmButton addTarget:self action:@selector(disarm) forControlEvents:UIControlEventTouchUpInside];
    
    self.startManualControlButton = [[UIButton alloc] init];
    [self.view addSubview:self.startManualControlButton];
    [self.startManualControlButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.startManualControlButton setTitle:NSLocalizedString(@"mavppm_simulator_start_manual_control", nil) forState:UIControlStateNormal];
    [self.startManualControlButton setBackgroundColor:[UIColor clearColor]];
    [self.startManualControlButton sizeToFit];
    [self.startManualControlButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.targetAddressTextField);
        make.top.equalTo(self.disarmButton.mas_bottom).offset(12);
        make.width.mas_equalTo(90);
    }];
    
    [self.startManualControlButton.layer setCornerRadius:4];
    [self.startManualControlButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.startManualControlButton.layer setBorderWidth:2];
    [self.startManualControlButton.layer setMasksToBounds:YES];
    [self.startManualControlButton addTarget:self action:@selector(startManualControl) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)connectTarget {
    NSString *remoteIP = [self.targetAddressTextField.text componentsSeparatedByString:@":"][0];
    short remotePort = (short)[[self.targetAddressTextField.text componentsSeparatedByString:@":"][1] intValue];
    [[MPPackageManager sharedInstance] setupPackageManagerWithLocalPort:14550 remoteDomain:remoteIP remotePort:remotePort tcpLink:NO];
    [[MPPackageManager sharedInstance] connectSignal:@selector(onAttach) forObserver:self slot:@selector(connected)];
    [self.targetAddressTextField resignFirstResponder];
}

- (NS_SLOT)connected {
    [[MPDeviceHeartbeatManager sharedInstance] run];
}

- (NS_SLOT)disconnectTarget {
    [self.targetAddressTextField resignFirstResponder];
    [[MPDeviceHeartbeatManager sharedInstance] stop];
    [[MPUAVControlManager sharedInstance] stop];
    [[NSRunLoop mainRunLoop] performBlock:^{
        [self dismissViewControllerAnimated:YES completion:nil];
    }];
}

- (NS_SLOT)disarm {
    MVMessageCommandLong *message = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:[[MPDeviceHeartbeatManager sharedInstance] targetSystem] targetComponent:[[MPDeviceHeartbeatManager sharedInstance] targetComponent] command:MAV_CMD_COMPONENT_ARM_DISARM confirmation:1 param1:1 param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    
    __weak typeof(self) weakSelf = self;
    [[MPPackageManager sharedInstance] sendCommandMessage:message withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        *handingType = MPPackageManagerResultHandingTypeContinue;
        if (ack.result == MAV_RESULT_ACCEPTED) {
            NSLog(@"Disarm OK");
            [weakSelf switchToManualMode];
        }
    }];
}

- (NS_SLOT)switchToManualMode {
    MVMessageCommandLong *message = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:[[MPDeviceHeartbeatManager sharedInstance] targetSystem] targetComponent:[[MPDeviceHeartbeatManager sharedInstance] targetComponent] command:MAV_CMD_DO_SET_MODE confirmation:1 param1:MAV_MODE_MANUAL_DISARMED param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    [[MPPackageManager sharedInstance] sendCommandMessage:message withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        *handingType = MPPackageManagerResultHandingTypeContinue;
        if (ack.result == MAV_RESULT_ACCEPTED) {
            NSLog(@"switch to manual");
        }
    }];
}

- (NS_SLOT)startManualControl {
    [[MPUAVControlManager sharedInstance] run];
}

- (void)setAttitudeInfoWithPitch:(CGFloat)pitch
                            roll:(CGFloat)roll {
    [[NSRunLoop mainRunLoop] performBlock:^{
        self.attitudeInfoLabel.text = [NSString stringWithFormat:NSLocalizedString(@"mavppm_control_view_attitude_info", @"姿态信息"), RADToDEG(roll), RADToDEG(pitch)];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor controlBgBlack];
    [self setupUI];
    
    self.rollLinear = [[MPControlValueLinear alloc] initWithOutputMax:1000 outputMin:-1000 inputMax:M_PI_2 inputMin:-M_PI_2];
    self.pitchLinear = [[MPControlValueLinear alloc] initWithOutputMax:1000 outputMin:-1000 inputMax:M_PI_2 inputMin:-M_PI_2];
    self.yawLinear = [[MPControlValueLinear alloc] initWithOutputMax:1000 outputMin:-1000 inputMax:2000 inputMin:1000];
    self.throttleLinear = [[MPControlValueLinear alloc] initWithOutputMax:1000 outputMin:0 inputMax:2000 inputMin:1000];
    
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 60.0;
    self.deviceMotionControl = [[MPUAVGravityControl alloc] init];
    self.deviceMotionControl.delegate = self;
    [self.deviceMotionControl connectSignal:@selector(onFeedback) forObserver:self slot:@selector(deviceMotionFeedback)];
    [self.motionManager addControl:self.deviceMotionControl];
    [self.motionManager startUpdate];
    
    // Do any additional setup after loading the view.
}

- (NS_SLOT)deviceMotionFeedback {
    [[NSRunLoop mainRunLoop] performBlock:^{
        [self.lightFeedback impactOccurred];
    }];
}

- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.rollIndicateView.rollValue = @(self.deviceMotionControl.rollValue);
        self.circleIndicateView.rollValue = @(self.deviceMotionControl.rollValue);
        self.circleIndicateView.pitchValue = @(self.deviceMotionControl.pitchValue);
        [self setAttitudeInfoWithPitch:-self.deviceMotionControl.pitchValue roll:self.deviceMotionControl.rollValue];
        MPUAVControlManager *manager = [MPUAVControlManager sharedInstance];
        manager.throttle = [self.throttleLinear calc:self.throttleControlView.throttleValue.integerValue];
        manager.yaw = [self.yawLinear calc:self.yawControlView.yawValue.integerValue];
        manager.roll = [self.rollLinear calc:self.deviceMotionControl.rollValue];
        manager.pitch = [self.pitchLinear calc:self.deviceMotionControl.pitchValue];
    });
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
