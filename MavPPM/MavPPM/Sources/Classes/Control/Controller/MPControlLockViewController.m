//
//  MPControlLockViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "UIColor+MavPPMColor.h"
#import "MPCMMotionManager.h"
#import "MPUnlockGravityControl.h"
#import "MPControlLockViewController.h"
#import "MPBindThrottleChannelViewController.h"
#import "MPBindChannelModel.h"
#import "MPNavigationController.h"

@interface MPControlLockViewController ()
@property (nonatomic, strong) UIImageView *lockIcon;
@property (nonatomic, strong) UIAlertController *unlockAlert;
@property (nonatomic, strong) UIButton *bindChannelButton;

@property (nonatomic, strong) MPUnlockGravityControl *lockGravityControl;
@property (nonatomic, strong) MPMotionManager *motionManager;
@end

@implementation MPControlLockViewController
NS_CLOSE_SIGNAL_WARN(onUnlock);

- (void)setupView {
    self.lockIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"control_view_lock"]];
    [self.view addSubview:self.lockIcon];
    [self.lockIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.centerY.equalTo(self.view);
    }];
    self.lockIcon.userInteractionEnabled = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startUnlock)];
    [self.lockIcon addGestureRecognizer:tap];
    
    self.bindChannelButton = [[UIButton alloc] init];
    [self.view addSubview:self.bindChannelButton];
    [self.bindChannelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bindChannelButton setTitle:NSLocalizedString(@"mavppm_control_view_bind_channel_button_title", @"绑定通道") forState:UIControlStateNormal];
    [self.bindChannelButton setBackgroundColor:[UIColor clearColor]];
    [self.bindChannelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(44);
        make.top.equalTo(self.view).offset(44);
        make.width.mas_equalTo(90);
        make.height.mas_equalTo(30);
    }];
    [self.bindChannelButton.layer setCornerRadius:4];
    [self.bindChannelButton.layer setBorderColor:[UIColor whiteColor].CGColor];
    [self.bindChannelButton.layer setBorderWidth:2];
    [self.bindChannelButton.layer setMasksToBounds:YES];
    
    [self.bindChannelButton addTarget:self action:@selector(startBindChannel) forControlEvents:UIControlEventTouchUpInside];
}

- (void)startUnlock {
    // Start Motion Manager
    self.motionManager = [[MPMotionManager alloc] initWithCMMotionManager:[MPCMMotionManager motionManager]];
    self.motionManager.deviceMotionUpdateInterval = 1.0 / 30.0;
    self.lockGravityControl = [[MPUnlockGravityControl alloc] init];
    [self.motionManager addControl:self.lockGravityControl];
    [self.motionManager startUpdate];
    [self.lockGravityControl connectSignal:@selector(onUnlock) forObserver:self slot:@selector(showUAVControlView)];
    
    // Show Alert View
    self.unlockAlert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"mavppm", nil) message:NSLocalizedString(@"mavppm_control_view_try_unlock_message", nil) preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:self.unlockAlert animated:YES completion:nil];
}

- (void)startBindChannel {
    MPBindThrottleChannelViewController *v = [[MPBindThrottleChannelViewController alloc] init];
    MPBindChannelModel *m = [[MPBindChannelModel alloc] init];
    m.currentBindFlow = MPBindChannelFlowThrottle;
    v.bindModel = m;
    
    MPNavigationController *nav = [[MPNavigationController alloc] initWithRootViewController:v];
    [self presentViewController:nav animated:YES completion:nil];
}

- (NS_SLOT)showUAVControlView {
    [[NSRunLoop mainRunLoop] performBlock:^{
        [self.unlockAlert dismissViewControllerAnimated:NO completion:nil];
        [self dismissViewControllerAnimated:NO completion:^{
            [self emitSignal:@selector(onUnlock) withParams:nil];
        }];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor controlBgBlack];
    [self setupView];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}

@end
