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
#import "MPWeakTimer.h"
#import "MPUAVControlManager.h"

@interface MPBindThrottleChannelViewController ()
@property (nonatomic, strong) MPThrottleControlView *throttleControlView;

@property (nonatomic, strong) MPWeakTimer *sendThrottleValueTimer;
@end

@implementation MPBindThrottleChannelViewController

- (void)dealloc {
    [self cancelTimer];
}

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
    self.throttleControlView.touchArea = MPThrottleControlViewTouchAreaRight;
    
    self.sendThrottleValueTimer = [MPWeakTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(sendThrottleValue) userInfo:nil repeats:YES];
    [self.sendThrottleValueTimer fire];
    [[MPUAVControlManager sharedInstance] run];
}

- (void)sendThrottleValue {
    MPUAVControlManager *manager = [MPUAVControlManager sharedInstance];
    NSInteger t = self.throttleControlView.throttleValue.integerValue;
    t = MIN(2000, t);
    t = MAX(1000, t);
    manager.throttle = t;
    manager.yaw = 1500;
    manager.roll = 1500;
    manager.buttons = 0;
    manager.pitch = 1500;
}

- (void)cancelTimer {
    [self.sendThrottleValueTimer invalidate];
    self.sendThrottleValueTimer = nil;
}

- (void)next {
    [self cancelTimer];
    [self.bindModel bindChannelType:MPChannelTypeThrottle to:self.bindModel.currentSelectChannelNumber force:YES];
    [super next];
}

- (void)cancel {
    [self cancelTimer];
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
    
    [super channelChange];
}

@end
