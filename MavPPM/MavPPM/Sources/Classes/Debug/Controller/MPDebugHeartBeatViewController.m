//
//  MPDebugHeartBeatViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MPCommLayer/MPCommLayer.h>
#import <MPMavlink/MPMavlink.h>

#import "MPDebugHeartbeatDevice.h"
#import "MPDebugHeartBeatViewController.h"

@interface MPDebugHeartBeatViewController () <MPCommDelegate, MVMavlinkDelegate>

@property (nonatomic, strong) MVMavlink *mavlink;
@property (nonatomic, strong) MPUDPSocket *udpLink;
@property (nonatomic, strong) MPDebugHeartbeatDevice *heartbeatDevice;

@property (nonatomic, strong) NSTimer *heartbeatTimer;
@property (nonatomic, strong) NSTimer *checkConnectionTimer;
@property (nonatomic, strong) NSTimer *throttleUpTimer;

@property (nonatomic, strong) UIButton *toggleHeartBeatButton;
@property (nonatomic, strong) UIButton *takeOffButton;
@property (nonatomic, strong) UIButton *throttleUpButton;

@property (nonatomic, strong) UITextField *targetAddressTextField;
@property (nonatomic, strong) UITextView *debugOutputTextView;

@property (nonatomic, copy) NSString *currentRecvMessageDescription;

@property (nonatomic, assign) BOOL isPublish;

@property (nonatomic, assign) uint8_t targetSystem;
@property (nonatomic, assign) uint8_t targetComponent;
@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic, assign) NSUInteger heartbeatCount;
@property (nonatomic, assign) NSUInteger lastHeartbeatCount;
@property (nonatomic, assign) NSUInteger heartbeatLostCount;

@property (nonatomic, assign) MAV_MODE mode;

@end

@implementation MPDebugHeartBeatViewController

- (void)createView {
    self.targetAddressTextField = [[UITextField alloc] init];
    self.targetAddressTextField.placeholder = @"目标地址";
    [self.view addSubview:self.targetAddressTextField];
    
    self.toggleHeartBeatButton = [[UIButton alloc] init];
    [self.toggleHeartBeatButton setTitle:@"广播心跳" forState:UIControlStateNormal];
    [self.toggleHeartBeatButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.toggleHeartBeatButton addTarget:self action:@selector(toggleHeartBeat) forControlEvents:UIControlEventTouchUpInside];
    [self.toggleHeartBeatButton sizeToFit];
    [self.view addSubview:self.toggleHeartBeatButton];
    
    self.debugOutputTextView = [[UITextView alloc] init];
    self.debugOutputTextView.font = [UIFont systemFontOfSize:10];
    self.debugOutputTextView.editable = NO;
    [self.view addSubview:self.debugOutputTextView];
    
    self.takeOffButton = [[UIButton alloc] init];
    [self.takeOffButton setTitle:@"起飞" forState:UIControlStateNormal];
    [self.takeOffButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.takeOffButton addTarget:self action:@selector(disarmAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.takeOffButton];
    
    self.throttleUpButton = [[UIButton alloc] init];
    [self.throttleUpButton setTitle:@"开始输出油门信号" forState:UIControlStateNormal];
    [self.throttleUpButton setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
    [self.throttleUpButton addTarget:self action:@selector(throttleUpAction) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.throttleUpButton];
}

- (void)createConstraints {
    [self.targetAddressTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view);
        make.left.equalTo(self.view).offset(8);
        make.height.mas_equalTo(44);
        make.right.mas_equalTo(self.toggleHeartBeatButton.mas_left);
    }];
    
    [self.toggleHeartBeatButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(100);
        make.top.equalTo(self.view);
        make.right.equalTo(self.view).offset(8);
        make.height.equalTo(self.targetAddressTextField.mas_height);
    }];
    
    [self.debugOutputTextView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.targetAddressTextField.mas_bottom).offset(8);
        make.left.right.equalTo(self.view);
        make.bottom.equalTo(self.takeOffButton.mas_top);
    }];
    
    [self.takeOffButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view);
        make.right.equalTo(self.throttleUpButton.mas_left);
        make.height.mas_equalTo(36);
        make.width.equalTo(self.view).dividedBy(2);
        make.bottom.equalTo(self.view).offset(-44);
    }];
    
    [self.throttleUpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.view);
        make.left.equalTo(self.takeOffButton.mas_right);
        make.height.mas_equalTo(36);
        make.bottom.equalTo(self.view).offset(-44);
    }];
    
}
- (void)startHeartBeat {
    NSString *remoteIP = [self.targetAddressTextField.text componentsSeparatedByString:@":"][0];
    short remotePort = (short)[[self.targetAddressTextField.text componentsSeparatedByString:@":"][1] intValue];
    
    // sleep 1s for close socket
    [NSThread sleepForTimeInterval:2];
    self.udpLink = [[MPUDPSocket alloc] initWithLocalPort:14550 delegate:self];
    
    [self.udpLink connect:remoteIP port:remotePort];
    
    __weak typeof(self) weakSelf = self;
    self.heartbeatTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        MVMessage *message = [[MVMessageHeartbeat alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP type:MAV_TYPE_GCS autopilot:MAV_AUTOPILOT_GENERIC baseMode:MAV_MODE_FLAG_ENUM_END customMode:0 systemStatus:MAV_STATE_ACTIVE];
        [weakSelf.mavlink sendMessage:message];
    }];
    
    self.checkConnectionTimer = [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        if (weakSelf.heartbeatCount == weakSelf.lastHeartbeatCount) {
            weakSelf.heartbeatLostCount++;
            if (weakSelf.heartbeatLostCount > 5) {
                weakSelf.isConnected = NO;
                [weakSelf toggleHeartBeat];
            }
        } else {
            weakSelf.lastHeartbeatCount = weakSelf.heartbeatCount;
            weakSelf.heartbeatLostCount = 0;
        }
    }];
}

- (void)stopHeartBeat {
    [self.udpLink close];
    self.udpLink = nil;
    
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
    
    [self.checkConnectionTimer invalidate];
    self.checkConnectionTimer = nil;
    
    self.heartbeatLostCount = 0;
    self.isConnected = NO;
}

#pragma mark - Setter Getter

- (void)setMode:(MAV_MODE)mode {
    MVMessageCommandLong *message = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:self.targetSystem targetComponent:self.targetComponent command:MAV_CMD_DO_SET_MODE confirmation:1 param1:mode param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    [self.mavlink sendMessage:message];
    _mode = mode;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createView];
    [self createConstraints];

//    _heartbeatDevice = [[MPDebugHeartbeatDevice alloc] initWithLocalPort:14550 RemotePort:14560];
//    [_heartbeatDevice start];
    
    _heartbeatCount = 0;
    _lastHeartbeatCount = 0;
    _heartbeatLostCount = 0;
    _isConnected = NO;
    _isPublish = NO;
    _mavlink = [[MVMavlink alloc] init];
    _mavlink.delegate = self;
    
}



#pragma mark - Action
- (void)toggleHeartBeat {
    if (self.isPublish) {
        [self.toggleHeartBeatButton setTitle:@"广播心跳" forState:UIControlStateNormal];
        [self stopHeartBeat];
        _isPublish = NO;
    } else {
        [self.toggleHeartBeatButton setTitle:@"停止心跳" forState:UIControlStateNormal];
        [self startHeartBeat];
        _isPublish = YES;
        
    }
}

- (void)sendThrottleMessage {
    MVMessageManualControl *message = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:self.targetSystem x:0 y:0 z:800 r:20 buttons:0];
    [self.mavlink sendMessage:message];
}
- (void)takeOffAction {
    MVMessageCommandLong *message = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:self.targetSystem targetComponent:self.targetComponent command:MAV_CMD_COMPONENT_ARM_DISARM confirmation:2 param1:1 param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    
    [self.mavlink sendMessage:message];
    
    message = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:self.targetSystem targetComponent:self.targetComponent command:MAV_CMD_NAV_TAKEOFF confirmation:3 param1:NAN param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    
    [self.mavlink sendMessage:message];
}

- (void)useManualMode {
    [self takeOffAction];
}

- (void)throttleUpAction {
    self.mode = MAV_MODE_MANUAL_DISARMED;
    __weak typeof(self) weakSelf = self;
    self.throttleUpTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        [weakSelf sendThrottleMessage];
    }];
}

- (void)disarmAction {
    MVMessageCommandLong *message = [[MVMessageCommandLong alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP targetSystem:self.targetSystem targetComponent:self.targetComponent command:MAV_CMD_COMPONENT_ARM_DISARM confirmation:1 param1:1 param2:NAN param3:NAN param4:NAN param5:NAN param6:NAN param7:NAN];
    
    [self.mavlink sendMessage:message];
}


#pragma mark - Delegate
- (void)communicator:(id)aCommunicator didReadData:(NSData *)data {
    [self.mavlink parseData:data];
}

- (void)communicator:(id)aCommunicator handleEvent:(MPCommEvent)event {
    if (event == MPCommEventHasBytesAvailable) {
        [aCommunicator read];
    }
}

- (void)mavlink:(MVMavlink *)mavlink didGetMessage:(id<MVMessage>)message {
    
    if ([message isKindOfClass:[MVMessageHeartbeat class]]) {
        MVMessageHeartbeat *heartBeat = (MVMessageHeartbeat *)message;
        _targetSystem = [heartBeat systemId];
        _targetComponent = [heartBeat componentId];
        
        MAV_MODE_FLAG modeFlag = [heartBeat baseMode];
        MAV_MODE_FLAG mask = 1;
        
        BOOL isArmed = modeFlag & MAV_MODE_FLAG_SAFETY_ARMED;;
        
        for (int i = 0; i < 8; ++i) {
            int bit = modeFlag & (mask << i);
            if (bit == MAV_MODE_FLAG_AUTO_ENABLED) {
                _mode = isArmed ? MAV_MODE_AUTO_ARMED : MAV_MODE_AUTO_DISARMED;
            } else if (bit == MAV_MODE_FLAG_STABILIZE_ENABLED) {
                _mode = isArmed ? MAV_MODE_STABILIZE_ARMED : MAV_MODE_STABILIZE_DISARMED;
            } else if (bit == MAV_MODE_FLAG_MANUAL_INPUT_ENABLED) {
                _mode = isArmed ? MAV_MODE_MANUAL_ARMED : MAV_MODE_MANUAL_DISARMED;
            } else if (bit == MAV_MODE_FLAG_GUIDED_ENABLED) {
                _mode = isArmed ? MAV_MODE_MANUAL_ARMED : MAV_MODE_MANUAL_DISARMED;
            }
        }
        
        _heartbeatCount++;
        _isConnected = YES;
    }
    
    if ([message isKindOfClass:[MVMessageCommandAck class]]) {
        
    }
    
    
    NSString *recvMessage = [message description];
    self.currentRecvMessageDescription = recvMessage;
    NSLog(@"%@", message);
}

- (BOOL)mavlink:(MVMavlink *)mavlink shouldWriteData:(NSData *)data {
    if (self.udpLink) {
        [self.udpLink write:data];
        return YES;
    }
    return NO;
}

@end
