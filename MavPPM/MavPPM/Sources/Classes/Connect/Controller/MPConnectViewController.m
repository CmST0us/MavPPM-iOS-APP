//
//  MPConnectViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPConnectViewController.h"
#import "MPNavigationController.h"

#if DEBUG
#import "MPDebugViewController.h"
#endif

@interface MPConnectViewController ()

#if DEBUG
@property (nonatomic, strong) UITapGestureRecognizer *debugViewControllerVCGesture;
#endif

@end

@implementation MPConnectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
