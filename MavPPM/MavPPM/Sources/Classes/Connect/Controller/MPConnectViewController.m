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

- (void)viewDidLoad {
    [super viewDidLoad];
    
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


#pragma mark - Action

#if DEBUG
- (void)showDebugVC {
    MPDebugViewController *debugVC = [[MPDebugViewController alloc] init];
    MPNavigationController *nav = [[MPNavigationController alloc] initWithRootViewController:debugVC];
    [self presentViewController:nav animated:YES completion:nil];	
}
#endif

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

@end
