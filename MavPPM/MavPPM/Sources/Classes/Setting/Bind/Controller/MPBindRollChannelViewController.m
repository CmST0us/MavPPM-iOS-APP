//
//  MPBindRollChannelViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPBindRollChannelViewController.h"
#import "MPGravityRollIndicateView.h"
#import "MPCMMotionManager.h"
#import "MPPackageManager.h"


@interface MPBindRollChannelViewController () <MPGravityControlDelegate>
@property (nonatomic, strong) MPGravityRollIndicateView *rollIndicateView;
@property (nonatomic, strong) MPGravityDeviceMotionControl *deviceMotionControl;
@property (nonatomic, strong) MPMotionManager *manager;

@property (nonatomic, strong) MPControlValueLinear *rollLinear;
@end

@implementation MPBindRollChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bindChannelTitle = NSLocalizedString(@"mavppm_bind_roll_channel_title", nil);
    self.bindInfo = NSLocalizedString(@"mavppm_bind_roll_channel_info", nil);
    self.bindModel.currentBindFlow = MPBindChannelFlowRoll;
    
    self.rollIndicateView = [[MPGravityRollIndicateView alloc] init];
    [self.view insertSubview:self.rollIndicateView atIndex:0];
    [self.rollIndicateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.deviceMotionControl = [[MPGravityDeviceMotionControl alloc] init];
    self.deviceMotionControl.delegate = self;
    
    self.manager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.manager.deviceMotionUpdateInterval = 1 / 60.0;
    [self.manager addControl:self.deviceMotionControl];
    [self.manager startUpdate];
    
    self.rollLinear = [[MPControlValueLinear alloc] initWithOutputMax:2000 outputMin:1000 inputMax:M_PI_2 inputMin:-M_PI_2];
    
}

- (void)cancel {

    [super cancel];
}

- (void)next {
    
    [super next];
}

- (void)channelChange {
    
}

#pragma mark - Delegate
- (void)gravityControlDidUpdateData:(MPGravityControl *)control {
    CGFloat r = self.deviceMotionControl.data.attitude.pitch;
    [[NSRunLoop mainRunLoop] performBlock:^{
        self.rollIndicateView.rollValue = @(r);
    }];
    MVMessageManualControl *controlMessage = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:MAVPPM_SYSTEM_ID_EMB x:1000 y:[self.rollLinear calc:r] z:1000 r:1000 buttons:0];
    [[MPPackageManager sharedInstance] sendMessageWithoutAck:controlMessage];
}


@end
