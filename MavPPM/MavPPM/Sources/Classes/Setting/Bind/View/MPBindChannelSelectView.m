//
//  MPBindChannelSelectView.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPBindChannelModel.h"
#import "MPBindChannelSelectView.h"

static NSString * const kMPBindChannelSelectViewCellId = @"cell";

@interface MPBindChannelSelectView () <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray *channelDescriptionArray;
@end

@implementation MPBindChannelSelectView

- (void)viewDidInit {
    [super viewDidInit];
    self.backgroundColor = [UIColor clearColor];
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.tableView];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.showsVerticalScrollIndicator = NO;
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (NSArray *)channelDescriptionArray {
    if (_channelDescriptionArray) {
        return _channelDescriptionArray;
    }
    return [self.model descriptionDictionArray];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.model.supportChannelCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMPBindChannelSelectViewCellId];
    if (cell == NULL) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kMPBindChannelSelectViewCellId];
    }
    
    cell.backgroundColor = UIColor.clearColor;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.textColor = [UIColor whiteColor];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    cell.textLabel.text = [[NSString alloc] initWithFormat:@"%@%d:%@", NSLocalizedString(@"mav_bind_channel_select_view_channel", @"通道"), (int)indexPath.row + 1, self.channelDescriptionArray[indexPath.row]];
    if (self.model.currentSelectChannelNumber == indexPath.row + 1) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (![self.model isChannelNumberBind:indexPath.row + 1]) {
        self.model.currentSelectChannelNumber = indexPath.row + 1;
        [tableView reloadData];
        if (self.delegate &&
            [self.delegate respondsToSelector:@selector(channelSelectView:didSelectChannel:)]) {
            [self.delegate channelSelectView:self didSelectChannel:self.model.currentSelectChannelNumber];
        }
    }
}

@end
