//
//  MPConnectViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPPackageManager.h"
#import "MPConnectViewController.h"
#import "MPNavigationController.h"
#import "MPConnectingLabel.h"
#import "MPDeviceHeartbeat.h"
#import "MPMainUAVControlViewController.h"
#import "MPControlLockViewController.h"
#import "MPDeviceHeartbeatManager.h"

#if DEBUG
#import "MPDebugViewController.h"
#endif

@interface MPConnectViewController ()
@property (nonatomic, strong) MPConnectingLabel *connectingLabel;
#if DEBUG
@property (nonatomic, strong) UITapGestureRecognizer *debugViewControllerVCGesture;
#endif

@end

@implementation MPConnectViewController

- (void)setupUI {
    self.view.backgroundColor = [UIColor blackColor];
    self.connectingLabel = [[MPConnectingLabel alloc] init];
    [self.view addSubview:self.connectingLabel];
    [self.connectingLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-40);
    }];
    
#if DEBUG
    _debugViewControllerVCGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(showDebugVC)];
    _debugViewControllerVCGesture.numberOfTapsRequired = 2;
    _debugViewControllerVCGesture.numberOfTouchesRequired = 2;
    [self.view addGestureRecognizer:_debugViewControllerVCGesture];
#endif
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[MPPackageManager sharedInstance] connectSignal:@selector(onAttach) forObserver:self slot:@selector(deviceAttach)];
    [[MPPackageManager sharedInstance] connectSignal:@selector(onDetattch) forObserver:self slot:@selector(deviceDetattch)];
    [[MPDeviceHeartbeatManager sharedInstance] connectSignal:@selector(onRecvRemoteDeviceHeartbeat) forObserver:self slot:@selector(deviceConnectionNormal)];
    [[MPDeviceHeartbeatManager sharedInstance] connectSignal:@selector(onLostRemoteDeviceHeartbeat) forObserver:self slot:@selector(deviceConnectionLost)];
    
    [self setupUI];
}

- (void)dealloc {
    
}

#pragma mark - Action

#if DEBUG
- (void)showDebugVC {
    MPDebugViewController *debugVC = [[MPDebugViewController alloc] init];
    MPNavigationController *nav = [[MPNavigationController alloc] initWithRootViewController:debugVC];
    [self presentViewController:nav animated:YES completion:nil];	
}
#endif

#pragma mark - Slot
- (NS_SLOT)enterUAVControlView {
    [[NSRunLoop mainRunLoop] performBlock:^{
        MPMainUAVControlViewController *mainUAVControlView = [[MPMainUAVControlViewController alloc] init];
        [self presentViewController:mainUAVControlView animated:NO completion:nil];
    }];
}

- (NS_SLOT)deviceConnectionNormal {
    [[NSRunLoop mainRunLoop] performBlock:^{
        MPControlLockViewController *controlLockVC = [[MPControlLockViewController alloc] init];
        [controlLockVC connectSignal:@selector(onUnlock) forObserver:self slot:@selector(enterUAVControlView)];
        [self presentViewController:controlLockVC animated:YES completion:nil];
    }];
}

- (NS_SLOT)deviceConnectionLost {
    
}

- (void)deviceAttach {
    [[MPDeviceHeartbeatManager sharedInstance] run];
}

- (void)deviceDetattch {
    [[MPDeviceHeartbeatManager sharedInstance] stop];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
