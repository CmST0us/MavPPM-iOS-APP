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
@end

@implementation MPDebugPackageManagerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.heartbeatDevice = [[MPDebugHeartbeatDevice alloc] initWithLocalPort:14556 RemotePort:14550];
    [self.heartbeatDevice start];
    
    [[MPPackageManager sharedInstance] setupPackageManagerWithLocalPort:14550 remoteDomain:@"127.0.0.1" remotePort:14556];
    
    [[MPPackageManager sharedInstance] listenMessage:[MVMessageHeartbeat class] withHandler:^(MVMessage * _Nullable message, MPPackageManagerResultHandingType * _Nonnull handingType) {
        NSLog(@"%@", message);
        *handingType = MPPackageManagerResultHandingTypeContinue;
    }];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
