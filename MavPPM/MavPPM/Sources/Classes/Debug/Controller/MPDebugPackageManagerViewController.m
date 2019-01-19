//
//  MPDebugPackageManagerViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/18.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <MPMavlink/MPMavlink.h>
#import "MPDebugPackageManagerViewController.h"
#import "MPPackageManager.h"
#import "MPDebugHeartbeatDevice.h"

@interface MPDebugPackageManagerViewController ()
@property (nonatomic, strong) MPDebugHeartbeatDevice *heartbeatDevice;
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) MVMessageHeartbeat *hb;
@end

@implementation MPDebugPackageManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakSelf = self;
//    self.heartbeatDevice = [[MPDebugHeartbeatDevice alloc] initWithLocalPort:14556 RemotePort:14550];
//    [self.heartbeatDevice start];
    
    [[MPPackageManager sharedInstance] setupPackageManagerWithLocalPort:14550 remoteDomain:@"192.168.31.150" remotePort:14556];
    
    [[MPPackageManager sharedInstance] listenMessage:[MVMessageHeartbeat class] withObserver:self handler:^(MVMessage * _Nullable message, MPPackageManagerResultHandingType * _Nonnull handingType) {
        NSLog(@"%@", message);
        *handingType = MPPackageManagerResultHandingTypeContinue;
        weakSelf.hb = (MVMessageHeartbeat *)message;
    }];
    
    _heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        MVMessageHeartbeat *mesg = [[MVMessageHeartbeat alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP type:MAV_TYPE_GCS autopilot:MAV_AUTOPILOT_GENERIC baseMode:0 customMode:0 systemStatus:MAV_STATE_STANDBY];
        [[MPPackageManager sharedInstance] sendMessageWithoutAck:mesg];
    }];
    
    [[MPPackageManager sharedInstance] listenMessage:[MVMessageHighresImu class] withObserver:self handler:^(MVMessage * _Nullable message, MPPackageManagerResultHandingType * _Nonnull handingType) {
        *handingType = MPPackageManagerResultHandingTypeContinue;
    }];
    
}

- (void)viewDidDisappear:(BOOL)animated {
    [_heartbeatTimer invalidate];
    _heartbeatTimer = nil;
}
    
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    __weak typeof(self) weakSelf = self;
    MVMessageCommandLong *cmd = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_SYSTEM_ID_EMB targetSystem:self.hb.systemId targetComponent:self.hb.componentId command:MAV_CMD_COMPONENT_ARM_DISARM confirmation:1 param1:1 param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    
    [[MPPackageManager sharedInstance] sendCommandMessage:cmd withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
        if (ack && !timeout) {
            if (ack.result == MAV_RESULT_ACCEPTED) {
                
                MVMessage *t = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:weakSelf.hb.systemId targetComponent:weakSelf.hb.componentId command:MAV_CMD_NAV_TAKEOFF confirmation:1 param1:NAN param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
                
                
                [[MPPackageManager sharedInstance] sendCommandMessage:t withObserver:self handler:^(MVMessageCommandAck * _Nullable ack, BOOL timeout, MPPackageManagerResultHandingType * _Nonnull handingType) {
                    *handingType = MPPackageManagerResultHandingTypeCancel;
                }];
                
            } else {
                *handingType = MPPackageManagerResultHandingTypeCancel;
            }
        } else {
            *handingType = MPPackageManagerResultHandingTypeContinue;
        }
    }];
}
- (void)dealloc {
    NSLog(@"Release");
}

@end
