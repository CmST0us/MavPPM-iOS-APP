//
//  MPDebugViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Masonry/Masonry.h>

#import "MPDebugViewController.h"
#import "NSObject+ClassDomain.h"

@interface MPDebugViewController () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *debugListTableView;
@end

@implementation MPDebugViewController

- (NSArray *)debugList {
    static NSArray *debugList;
    if (debugList != NULL) return debugList;
    debugList = @[
                  @[@"HeatBeat", @"MPDebugHeartBeatViewController"],
                  @[@"PackageManager", @"MPDebugPackageManagerViewController"],
                  @[@"GravityControl", @"MPDebugGravityViewController"],
                  @[@"TCP监听，usbmuxd接入", @"MPDebugTCPServerTestViewController"],
                  @[@"MavPPM Cube, mavlink 心跳", @"MPDebugCubeHeartbeatTestViewController"],
                  @[@"控制页UI测试", @"MPDebugUAVControlUITestViewController"],
                  @[@"绑定页UI", @"MPBindChannelViewController"],
                  ];
    
    return debugList;
}

- (void)createView {
    self.debugListTableView = [[UITableView alloc] init];
    self.debugListTableView.delegate = self;
    self.debugListTableView.dataSource = self;
    [self.debugListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:[self classDomainWithName:@"cell"]];
    [self.view addSubview:self.debugListTableView];
    
}

- (void)createConstraints {
    [self.debugListTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"调试";
    
    [self createView];
    [self createConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    self.navigationController.navigationBarHidden = NO;
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.barStyle = UIBarStyleDefault;
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithTitle:@"退出调试" style:UIBarButtonItemStylePlain target:self action:@selector(exitDebugVC)];
    [self.navigationItem setLeftBarButtonItem:barButton animated:YES];
}

#pragma mark - Action
- (void)exitDebugVC {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Table View Data Source & Delegate
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:[self classDomainWithName:@"cell"] forIndexPath:indexPath];
    NSArray *debugContent = [self debugList][indexPath.row];
    cell.textLabel.text = debugContent[0];
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [self debugList].count;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSArray *debugContent = [self debugList][indexPath.row];
    NSString *debugClassString = debugContent[1];
    Class targetClass = NSClassFromString(debugClassString);
    UIViewController *vc = [[targetClass alloc] init];
    if (vc != nil) {
        [self.navigationController pushViewController:vc animated:YES];
    }
}

@end
