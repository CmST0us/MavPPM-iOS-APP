//
//  MPBindYawChannelViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPPackageManager.h"
#import "MPBindYawChannelViewController.h"
#import "MPYawControlView.h"

@interface MPBindYawChannelViewController ()
@property (nonatomic, strong) MPYawControlView *yawControlView;
@property (nonatomic, strong) NSTimer *sendYawValueTimer;
@end

@implementation MPBindYawChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.bindChannelTitle = NSLocalizedString(@"mavppm_bind_yaw_channel_title", @"");
    self.bindInfo = NSLocalizedString(@"mavppm_bind_yaw_channel_info", nil);
    self.bindModel.currentBindFlow = MPBindChannelFlowYaw;
    
    self.yawControlView = [[MPYawControlView alloc] init];
    [self.view insertSubview:self.yawControlView atIndex:0];
    [self.yawControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    self.yawControlView.touchArea = MPYawControlViewTouchAreaRight;
    
    self.sendYawValueTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        MPPackageManager *packageManager = [MPPackageManager sharedInstance];
        // [TODO]: add target to package manager
        NSInteger y = self.yawControlView.yawValue.integerValue;
        y = MIN(2000, y);
        y = MAX(1000, y);
        
        MVMessageManualControl *control = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:MAVPPM_SYSTEM_ID_EMB x:1000 y:1000 z:1000 r:y buttons:0];
        [packageManager sendMessageWithoutAck:control];
    }];
    
    [[NSRunLoop mainRunLoop] addTimer:self.sendYawValueTimer forMode:NSRunLoopCommonModes];
    [self.sendYawValueTimer fire];
}

- (void)cancelTimer {
    [self.sendYawValueTimer invalidate];
    self.sendYawValueTimer = nil;
}

- (void)next {
    [self cancelTimer];
    [self.bindModel bindChannelType:MPChannelTypeYaw to:self.bindModel.currentSelectChannelNumber force:YES];
    
    [super next];
}

- (void)cancel {
    [self cancelTimer];
    
    [super cancel];
}

- (void)channelChange {
    // [TODO] change EMB channel map
    MVMessageCommandLong *longCommand = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:MAVPPM_SYSTEM_ID_EMB targetComponent:MAVPPM_COMPONENT_ID_EMB_APP command:MAV_CMD_DO_SET_PARAMETER confirmation:1 param1:MAVPPM_DO_SET_YAW_CHANNEL param2:self.bindModel.currentSelectChannelNumber param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    [[MPPackageManager sharedInstance] sendCommandMessage:longCommand withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        if (ack.result == MAV_RESULT_ACCEPTED) {
            *handingType = MPPackageManagerResultHandingTypeCancel;
        } else {
            *handingType = MPPackageManagerResultHandingTypeContinue;
        }
    }];
    _finishButton.hidden = NO;
    
    [super channelChange];
}

@end
