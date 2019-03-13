//
//  MPBindChannelViewController.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPViewController.h"
#import "MPBindChannelModel.h"

NS_ASSUME_NONNULL_BEGIN

@class MPBindChannelSelectView;
@class MPBindChannelModel;

@interface MPBindChannelViewController : MPViewController {
@protected
    // 从上到下
    UILabel *_titleLabel;
    UILabel *_infoLabel;
    
    MPBindChannelSelectView *_selectChannelView;
    
    UIButton *_cancelButton;
    UIButton *_finishButton;
    UIButton *_nextButton;
}

@property (nonatomic, copy) NSString *bindChannelTitle;
@property (nonatomic, copy) NSString *bindInfo;
@property (nonatomic, strong) MPBindChannelModel *bindModel;

// 子类在override最后调用super方法
- (void)cancel NS_REQUIRES_SUPER;
- (void)next NS_REQUIRES_SUPER;
- (void)channelChange NS_REQUIRES_SUPER;
- (void)finish NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
