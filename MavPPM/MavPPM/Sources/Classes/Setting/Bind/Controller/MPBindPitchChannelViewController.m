//
//  MPBindPitchChannelViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPBindPitchChannelViewController.h"
#import "MPGraviryPitchRollIndicateView.h"
#import "MPCMMotionManager.h"
#import "MPPackageManager.h"

@interface MPBindPitchChannelViewController ()<MPGravityControlDelegate>
@property (nonatomic, strong) MPGraviryPitchRollIndicateView *pitchRollIndicateView;
@property (nonatomic, strong) MPGravityDeviceMotionControl *deviceMotionControl;
@property (nonatomic, strong) MPMotionManager *manager;

@property (nonatomic, strong) MPControlValueLinear *pitchLinear;
@end

@implementation MPBindPitchChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bindChannelTitle = NSLocalizedString(@"mavppm_bind_pitch_channel_title", nil);
    self.bindInfo = NSLocalizedString(@"mavppm_bind_pitch_channel_info", nil);
    self.bindModel.currentBindFlow = MPBindChannelFlowPitch;
    
    self.pitchRollIndicateView = [[MPGraviryPitchRollIndicateView alloc] init];
    [self.view insertSubview:self.pitchRollIndicateView atIndex:0];
    [self.pitchRollIndicateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.deviceMotionControl = [[MPGravityDeviceMotionControl alloc] init];
    self.deviceMotionControl.delegate = self;
    
    self.manager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.manager.deviceMotionUpdateInterval = 1 / 60.0;
    [self.manager addControl:self.deviceMotionControl];
    [self.manager startUpdate];
    
    self.pitchLinear = [[MPControlValueLinear alloc] initWithOutputMax:2000 outputMin:1000 inputMax:M_PI_2 inputMin:-M_PI_2];
}

- (void)cancel {
    
    [super cancel];
}

- (void)next {
    [self.bindModel bindChannelType:MPChannelTypePitch to:self.bindModel.currentSelectChannelNumber force:YES];
    [super next];
}

- (void)channelChange {
    
}

#pragma mark - Delegate
- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    CGFloat p = self.deviceMotionControl.data.attitude.roll;
    [[NSRunLoop mainRunLoop] performBlock:^{
        self.pitchRollIndicateView.pitchValue = @(p);
    }];
    
    MVMessageManualControl *controlMessage = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:MAVPPM_SYSTEM_ID_EMB x:[self.pitchLinear calc:p] y:1000 z:1000 r:1000 buttons:0];
    [[MPPackageManager sharedInstance] sendMessageWithoutAck:controlMessage];
}


@end
