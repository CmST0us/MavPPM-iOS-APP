//
//  MPDebugCubeHeartbeatTestViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/7.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPCommLayer/MPCommLayer.h>
#import <MPMavlink/MPMavlink.h>
#import <Masonry/Masonry.h>

#import "MPPackageManager.h"

#import "MPDebugCubeHeartbeatTestViewController.h"

#define kDefaultUsbmuxdPort 17123

@interface MPDebugCubeHeartbeatTestViewController ()

@property (nonatomic, strong) UITextView *textView;
@property (nonatomic, strong) NSTimer *heartbeatTimer;
@end

@implementation MPDebugCubeHeartbeatTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.textView = [[UITextView alloc] init];
    self.textView.editable = NO;
    self.textView.text = @"DEBUG\n";
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.right.bottom.equalTo(self.view);
    }];
    
    typeof(self) weakSelf = self;
    [[MPPackageManager sharedInstance] setupPackageManagerWithLocalPort:kDefaultUsbmuxdPort];
    [[MPPackageManager sharedInstance] listenMessage:[MVMessageHeartbeat class] withObserver:self handler:^(MVMessage * _Nullable message, MPPackageManagerResultHandingType * _Nonnull handingType) {
        [weakSelf appendDebugString:[NSString stringWithFormat:@"[MAVLINK]: %@\n", message.description]];
        *handingType = MPPackageManagerResultHandingTypeContinue;
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onDisconnected) name:MPPackageManagerDisconnectedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onConnected) name:MPPackageManagerDidConnectedNotificationName object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)onDisconnected {
    [self.heartbeatTimer invalidate];
    self.heartbeatTimer = nil;
    [self appendDebugString:@"[MAVPPM]: Cube Disconnected, Stop Heartbeat\n"];
}

- (void)onConnected {
    self.heartbeatTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:1.0 repeats:YES block:^(NSTimer * _Nonnull timer) {
        MVMessage *message = [[MVMessageHeartbeat alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP type:MAV_TYPE_GCS autopilot:MAV_AUTOPILOT_GENERIC baseMode:MAV_MODE_FLAG_ENUM_END customMode:0 systemStatus:MAV_STATE_ACTIVE];
        [[MPPackageManager sharedInstance] sendMessageWithoutAck:message];
    }];
    
    MVMessage *message = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:0 x:1500 y:1500 z:1500 r:1500 buttons:0];
    [[MPPackageManager sharedInstance] sendMessageWithoutAck:message];

    [self appendDebugString:@"[MAVPPM]: Accept Cube, Start Heartbeat\n"];
}

- (void)appendDebugString:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = [self.textView.text stringByAppendingString:str];
    });
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *anyTouch = [touches anyObject];
    CGPoint p = [anyTouch locationInView:self.view];
    MVMessage *message = [[MVMessageManualControl alloc] initWithSystemId:MAVPPM_SYSTEM_ID_IOS componentId:MAVPPM_COMPONENT_ID_IOS_APP target:0 x:p.x y:p.y z:1500 r:1500 buttons:0];
    [[MPPackageManager sharedInstance] sendMessageWithoutAck:message];
}
@end
