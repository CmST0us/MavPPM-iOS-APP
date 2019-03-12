//
//  MPBindChannelViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <Masonry/Masonry.h>
#import "MPBindChannelViewController.h"
#import "MPBindChannelSelectView.h"

@interface MPBindChannelViewController ()
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) MPBindChannelSelectView *selectView;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIButton *nextButton;
@end

@implementation MPBindChannelViewController
@synthesize titleLabel = _titleLabel;
@synthesize infoLabel = _infoLabel;
@synthesize selectView = _selectView;
@synthesize cancelButton = _cancelButton;
@synthesize nextButton = _nextButton;

- (void)bindchannel_setupUI {
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController.navigationBar setHidden:YES];
    
    self.view.backgroundColor = [UIColor blackColor];
    
    _titleLabel = [[UILabel alloc] init];
    [self.view addSubview:_titleLabel];
    _titleLabel.text = NSLocalizedString(@"mavppm_bind_channel_default_title", @"绑定通道");
    _titleLabel.textColor = [UIColor whiteColor];
    _titleLabel.font = [UIFont systemFontOfSize:38.0];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.numberOfLines = 1;
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(20);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
    
    _infoLabel = [[UILabel alloc] init];
    [self.view addSubview:_infoLabel];
    _infoLabel.text = NSLocalizedString(@"mavppm_bind_channel_default_info", @"根据操作说明绑定通道");
    _infoLabel.textAlignment = NSTextAlignmentCenter;
    _infoLabel.font = [UIFont systemFontOfSize:15];
    _infoLabel.textColor = [UIColor whiteColor];
    _infoLabel.numberOfLines = 3;
    [_infoLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(20);
    }];
    
    _selectView = [[MPBindChannelSelectView alloc] init];
    [self.view addSubview:_selectView];
    _selectView.model = self.bindModel;
    [_selectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view);
        make.left.equalTo(self.view).offset(80);
        make.width.mas_equalTo(205);
        make.height.mas_equalTo(220);
    }];
    
    _cancelButton = [[UIButton alloc] init];
    [_cancelButton setBackgroundColor:[UIColor clearColor]];
    [_cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton.layer.borderWidth = 2;
    _cancelButton.layer.cornerRadius = 8;
    _cancelButton.layer.masksToBounds = YES;
    _cancelButton.layer.borderColor = [UIColor whiteColor].CGColor;
    [_cancelButton setTitle:NSLocalizedString(@"mavppm_bind_channel_button_cancel", @"取消") forState:UIControlStateNormal];
    [self.view addSubview:_cancelButton];
    [_cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(135);
        make.height.mas_equalTo(42);
        make.bottom.equalTo(self.view).offset(-45);
        make.right.mas_equalTo(self.view.mas_centerX).offset(-86);
    }];
    
    _nextButton = [[UIButton alloc] init];
    [_nextButton setBackgroundColor:[UIColor confirmGreen]];
    [_nextButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_nextButton addTarget:self action:@selector(next) forControlEvents:UIControlEventTouchUpInside];
    _nextButton.layer.cornerRadius = 8;
    _nextButton.layer.masksToBounds = YES;
    [_nextButton setTitle:NSLocalizedString(@"mavppm_bind_channel_button_next", @"下一步") forState:UIControlStateNormal];
    [self.view addSubview:_nextButton];
    [_nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(self.cancelButton.mas_width);
        make.height.mas_equalTo(self.cancelButton.mas_height);
        make.bottom.equalTo(self.cancelButton.mas_bottom);
        make.left.mas_equalTo(self.view.mas_centerX).offset(86);
    }];
    
}

#pragma mark - Setter, Getter
- (NSString *)bindChannelTitle {
    return self.titleLabel.text;
}

- (NSString *)bindInfo {
    return self.infoLabel.text;
}

- (void)setBindChannelTitle:(NSString *)bindChannelTitle {
    _titleLabel.text = bindChannelTitle;
}

- (void)setBindInfo:(NSString *)bindInfo {
    _infoLabel.text = bindInfo;
}

#pragma mark - Life Cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self bindchannel_setupUI];
    
    [self addObserver:self forKeyPath:@"bindModel.currentSelectChannelNumber" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath compare:@"bindModel.currentSelectChannelNumber"] == NSOrderedSame) {
        [self channelChange];
    }
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"bindModel.currentSelectChannelNumber"];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskLandscapeRight;
}

#pragma mark - Button Event
- (void)cancel {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)next {
    self.bindModel.currentBindFlow++;
    Class next = [self.bindModel nextFlowViewControllerClass];
    MPBindChannelViewController *vc = [(MPBindChannelViewController *)[next alloc] init];
    vc.bindModel = self.bindModel;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)channelChange {
    
}

@end
