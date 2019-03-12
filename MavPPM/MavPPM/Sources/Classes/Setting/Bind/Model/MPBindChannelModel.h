//
//  MPBindChannelModel.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, MPBindChannelFlow) {
    MPBindChannelFlowInit,
    MPBindChannelFlowThrottle,
    MPBindChannelFlowRoll,
    MPBindChannelFlowPitch,
    MPBindChannelFlowYaw,
    MPBindChannelFlowButton,
    MPBindChannelFlowFinish,
    
    MPBindChannelFlowCount,
};

typedef NS_ENUM(NSInteger, MPChannelType) {
    MPChannelTypeThrottle = 1,
    MPChannelTypeRoll,
    MPChannelTypePitch,
    MPChannelTypeYaw,
    
    MPChannelTypeButton1,
    MPChannelTypeButton2,
    MPChannelTypeButton3,
    
    MPChannelTypeUnbind = -1,
};

typedef NS_ENUM(NSInteger, MPChannelNumber) {
    MPChannelNumber1 = 1,
    MPChannelNumber2,
    MPChannelNumber3,
    MPChannelNumber4,
    MPChannelNumber5,
    MPChannelNumber6,
    MPChannelNumber7,
    
    MPChannelNumberCount,
    MPChannelNumberUnbind = -1,
};


@class MPBindChannelViewController;
@interface MPBindChannelModel : NSObject
@property (nonatomic, assign) MPBindChannelFlow currentBindFlow;
@property (nonatomic, readonly) NSInteger supportChannelCount;
@property (nonatomic, assign) MPChannelNumber currentSelectChannelNumber;

// (油门)绑第几通道
- (MPChannelNumber)channelNumber:(MPChannelType)channelType;
// (油门)可以绑定吗
- (BOOL)canBindChannelType:(MPChannelType)channelType;
// (油门)被绑定了没有
- (BOOL)isChannelTypeBind:(MPChannelType)channelType;

// 第几通道绑定了什么
- (MPChannelType)channelType:(MPChannelNumber)channelNumber;
// 第几通道是否绑定了
- (BOOL)isChannelNumberBind:(MPChannelNumber)channelNumber;
// 能否绑定第几通道
- (BOOL)canBindChannelNumber:(MPChannelNumber)channelNumber;

// 绑定通道几到(油门)
- (BOOL)bindChannelType:(MPChannelType)channelType
                     to:(MPChannelNumber)channelNumber;

- (BOOL)bindChannelType:(MPChannelType)channelType
                     to:(MPChannelNumber)channelNumber
                  force:(BOOL)forceBind;

- (NSArray *)descriptionDictionArray;
- (Class)nextFlowViewControllerClass;

@end

NS_ASSUME_NONNULL_END
