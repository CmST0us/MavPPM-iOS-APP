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
#import "MPUAVControlManager.h"
#import "MPPackageManager.h"

@interface MPBindPitchChannelViewController ()

@end

@implementation MPBindPitchChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bindChannelTitle = NSLocalizedString(@"mavppm_bind_pitch_channel_title", nil);
    self.bindInfo = NSLocalizedString(@"mavppm_bind_pitch_channel_info", nil);
    self.bindModel.currentBindFlow = MPBindChannelFlowPitch;
    
    
}

- (void)cancel {
    
    [super cancel];
}

- (void)next {
    [self.bindModel bindChannelType:MPChannelTypePitch to:self.bindModel.currentSelectChannelNumber force:YES];
    [super next];
}

- (void)channelChange {
    // [TODO] change EMB channel map
    MVMessageCommandLong *longCommand = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:MAVPPM_SYSTEM_ID_EMB targetComponent:MAVPPM_COMPONENT_ID_EMB_APP command:MAV_CMD_DO_SET_PARAMETER confirmation:1 param1:MAVPPM_DO_SET_PITCH_CHANNEL param2:self.bindModel.currentSelectChannelNumber param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    [[MPPackageManager sharedInstance] sendCommandMessage:longCommand withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        if (ack.result == MAV_RESULT_ACCEPTED) {
            *handingType = MPPackageManagerResultHandingTypeCancel;
        } else {
            *handingType = MPPackageManagerResultHandingTypeContinue;
        }
    }];
    
    [super channelChange];
}

@end
