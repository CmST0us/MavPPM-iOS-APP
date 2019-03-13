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

#if DEBUG
#import "MPDebugViewController.h"
#endif

@interface MPConnectViewController ()
@property (nonatomic, strong) MPConnectingLabel *connectingLabel;
@property (nonatomic, strong) MPDeviceHeartbeat *heartbeatListener;
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
    
    self.heartbeatListener = [[MPDeviceHeartbeat alloc] init];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnectionNormal) name:MPDeviceHeartbeatNormalNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceConnectionLost) name:MPDeviceHeartbeatLostNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceAttach) name:MPPackageManagerDidConnectedNotificationName object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDetattch) name:MPPackageManagerDisconnectedNotificationName object:nil];
    
    
    [self setupUI];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Action

#if DEBUG
- (void)showDebugVC {
    MPDebugViewController *debugVC = [[MPDebugViewController alloc] init];
    MPNavigationController *nav = [[MPNavigationController alloc] initWithRootViewController:debugVC];
    [self presentViewController:nav animated:YES completion:nil];	
}
#endif

#pragma mark - Notification
- (void)deviceConnectionNormal {
    [[NSRunLoop mainRunLoop] performBlock:^{
        MPMainUAVControlViewController *mainControlVC = [[MPMainUAVControlViewController alloc] init];
        mainControlVC.heartbeatListener = self.heartbeatListener;
        [self presentViewController:mainControlVC animated:YES completion:nil];
    }];
}

- (void)deviceConnectionLost {
    
}

- (void)deviceAttach {
    [self.heartbeatListener startListenAndSendHeartbeat];
}

- (void)deviceDetattch {
    [self.heartbeatListener stop];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
