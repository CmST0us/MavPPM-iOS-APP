//
//  MPBindThrottleChannelViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPPackageManager.h"
#import "MPThrottleControlView.h"
#import "MPBindThrottleChannelViewController.h"

@interface MPBindThrottleChannelViewController ()
@property (nonatomic, strong) MPThrottleControlView *throttleControlView;

@property (nonatomic, strong) NSTimer *sendThrottleValueTimer;
@end

@implementation MPBindThrottleChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.bindChannelTitle = NSLocalizedString(@"mavppm_bind_throttle_channel_title", @"绑定油门通道");
    self.bindInfo = NSLocalizedString(@"mavppm_bind_throttle_channel_info", nil);
    self.bindModel = [[MPBindChannelModel alloc] init];
    self.bindModel.currentBindFlow = MPBindChannelFlowThrottle;
    
    self.throttleControlView = [[MPThrottleControlView alloc] init];
    [self.view insertSubview:self.throttleControlView atIndex:0];
    [self.throttleControlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.sendThrottleValueTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:0.1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        MPPackageManager *packageManager = [MPPackageManager sharedInstance];
        // [TODO]: add target to package manager
        NSInteger t = self.throttleControlView.throttleValue.integerValue;
        t = MIN(2000, t);
        t = MAX(1000, t);
        
        MVMessageManualControl *control = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:MAVPPM_SYSTEM_ID_EMB x:1000 y:1000 z:t r:1000 buttons:0];
        [packageManager sendMessageWithoutAck:control];
    }];
    [[NSRunLoop mainRunLoop] addTimer:self.sendThrottleValueTimer forMode:NSRunLoopCommonModes];
    [self.sendThrottleValueTimer fire];
}

- (void)cancelTimer {
    [self.sendThrottleValueTimer invalidate];
    self.sendThrottleValueTimer = nil;
}

- (void)next {
    [self cancelTimer];
    
    [super next];
}

- (void)cancel {
    [self cancelTimer];
    
    MVMessageCommandLong *longCommand = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:MAVPPM_SYSTEM_ID_EMB targetComponent:MAVPPM_COMPONENT_ID_EMB_APP command:MAV_CMD_DO_SET_PARAMETER confirmation:1 param1:MAVPPM_DO_RESET_LAST_CHANNEL param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    
    [[MPPackageManager sharedInstance] sendCommandMessage:longCommand withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        if (ack.result == MAV_RESULT_ACCEPTED) {
            *handingType = MPPackageManagerResultHandingTypeCancel;
        } else {
            *handingType = MPPackageManagerResultHandingTypeContinue;
        }
    }];
    
    [super cancel];
}

- (void)channelChange {
    // [TODO] change EMB channel map
    MVMessageCommandLong *longCommand = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:MAVPPM_SYSTEM_ID_EMB targetComponent:MAVPPM_COMPONENT_ID_EMB_APP command:MAV_CMD_DO_SET_PARAMETER confirmation:1 param1:MAVPPM_DO_SET_THROTTLE_CHANNEL param2:self.bindModel.currentSelectChannelNumber param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    [[MPPackageManager sharedInstance] sendCommandMessage:longCommand withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        if (ack.result == MAV_RESULT_ACCEPTED) {
            *handingType = MPPackageManagerResultHandingTypeCancel;
        } else {
            *handingType = MPPackageManagerResultHandingTypeContinue;
        }
    }];
}

@end
