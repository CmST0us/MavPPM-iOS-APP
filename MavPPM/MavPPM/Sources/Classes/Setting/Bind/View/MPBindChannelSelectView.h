//
//  MPBindChannelSelectView.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPView.h"
#import "MPBindChannelModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MPBindChannelSelectView;
@protocol MPBindChannelSelectViewDelegate <NSObject>
- (void)channelSelectView:(MPBindChannelSelectView *)view didSelectChannel:(MPChannelNumber)channelNumber;

@end

@class MPBindChannelModel;
@interface MPBindChannelSelectView : MPView
@property (nonatomic, strong) MPBindChannelModel *model;
@property (nonatomic, weak) id<MPBindChannelSelectViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
