//
//  MPBindChannelModel.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/12.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPBindChannelModel.h"

@interface MPBindChannelModel ()
@property (nonatomic, strong) NSMutableDictionary *channelMap;
@end

@implementation MPBindChannelModel
- (instancetype)init {
    self = [super init];
    if (self) {
        
        NSDictionary *bindMap = @{
                                  @(MPChannelTypeThrottle): @(MPChannelNumberUnbind),
                                  @(MPChannelTypeRoll): @(MPChannelNumberUnbind),
                                  @(MPChannelTypePitch): @(MPChannelNumberUnbind),
                                  @(MPChannelTypeYaw): @(MPChannelNumberUnbind),
                                  @(MPChannelTypeButton1): @(MPChannelNumberUnbind),
                                  @(MPChannelTypeButton2): @(MPChannelNumberUnbind),
                                  @(MPChannelTypeButton3): @(MPChannelNumberUnbind),
                                  };
        _channelMap = [[NSMutableDictionary alloc] initWithDictionary:bindMap];
        _currentBindFlow = MPBindChannelFlowInit;
        _currentSelectChannelNumber = MPChannelNumber1;
    }
    return self;
}

- (MPChannelNumber)channelNumber:(MPChannelType)channelType {
    NSNumber *n = self.channelMap[@(channelType)];
    if (n) {
        return (MPChannelNumber)n.integerValue;
    }
    return MPChannelNumberUnbind;
}

- (BOOL)canBindChannelType:(MPChannelType)channelType {
    NSNumber *n = self.channelMap[@(channelType)];
    if (n) {
        MPChannelNumber cn = n.integerValue;
        if (cn == MPChannelNumberUnbind) {
            return YES;
        } else {
            return NO;
        }
    }
    return YES;
}


- (BOOL)isChannelTypeBind:(MPChannelType)channelType {
    NSNumber *n = self.channelMap[@(channelType)];
    if (n) {
        MPChannelNumber cn = n.integerValue;
        if (cn == MPChannelNumberUnbind) {
            return NO;
        } else {
            return YES;
        }
    }
    return NO;
}

- (BOOL)bindChannelType:(MPChannelType)channelType to:(MPChannelNumber)channelNumber force:(BOOL)forceBind {
    if (forceBind) {
        self.channelMap[@(channelType)] = @(channelNumber);
        return YES;
    } else {
        if ([self canBindChannelType:channelType]) {
            self.channelMap[@(channelType)] = @(channelNumber);
            return YES;
        }
        return NO;
    }
    return NO;
}

- (BOOL)bindChannelType:(MPChannelType)channelType to:(MPChannelNumber)channelNumber {
    return [self bindChannelType:channelType to:channelNumber force:NO];
}

- (MPChannelType)channelType:(MPChannelNumber)channelNumber {
    for (NSNumber *k in [self.channelMap allKeys]) {
        NSNumber *v = self.channelMap[k];
        if (v.integerValue == channelNumber) {
            return k.integerValue;
        }
    }
    return MPChannelTypeUnbind;
}

- (BOOL)isChannelNumberBind:(MPChannelNumber)channelNumber {
    for (NSNumber *k in [self.channelMap allKeys]) {
        NSNumber *v = self.channelMap[k];
        if (v.integerValue == channelNumber) {
            return YES;
        }
    }
    return NO;
}

- (BOOL)canBindChannelNumber:(MPChannelNumber)channelNumber {
    for (NSNumber *k in [self.channelMap allKeys]) {
        NSNumber *v = self.channelMap[k];
        if (v.integerValue == channelNumber) {
            return NO;
        }
    }
    return YES;
}

- (NSInteger)supportChannelCount {
    return (NSInteger)MPChannelNumberCount - 1;
}

- (Class)nextFlowViewControllerClass {
    static NSDictionary *staticFlowVC = NULL;
    if (staticFlowVC == NULL) {
        NSDictionary *flowViewController = @{
                                             @(MPBindChannelFlowThrottle):
                                                 @"MPBindThrottleChannelViewController",
                                             @(MPBindChannelFlowRoll):
                                                 @"MPBindRollChannelViewController",
                                             @(MPBindChannelFlowPitch):
                                                 @"MPBindPitchChannelViewController",
                                             @(MPBindChannelFlowYaw):
                                                 @"MPBindYawChannelViewController",
                                             @(MPBindChannelFlowButton):
                                                 @"MPBindButtonChannelViewController",
                                             };
        staticFlowVC = flowViewController;
    }
    return NSClassFromString(staticFlowVC[@(self.currentBindFlow)]);
}

- (MPChannelNumber)nextBindableChannelNumber {
    for (int i = MPChannelNumber1; i < MPChannelNumberCount; ++i) {
        if ([self canBindChannelNumber:i]) {
            return i;
        }
    }
    return MPChannelNumberUnbind;
}

#pragma mark - Description

- (NSString *)channelTypeDescription:(MPChannelType)type {
    switch (type) {
        case MPChannelTypeUnbind:
            return @"";
        case MPChannelTypeThrottle:
            return NSLocalizedString(@"mavppm_throttle", @"油门");
        case MPChannelTypeRoll:
            return NSLocalizedString(@"mavppm_roll", @"翻滚");
        case MPChannelTypePitch:
            return NSLocalizedString(@"mavppm_pitch", @"俯仰");
        case MPChannelTypeYaw:
            return NSLocalizedString(@"mavppm_yaw", @"偏航");
        case MPChannelTypeButton1:
            return NSLocalizedString(@"mavppm_button_1", @"按钮1");
        case MPChannelTypeButton2:
            return NSLocalizedString(@"mavppm_button_2", @"按钮2");
        case MPChannelTypeButton3:
            return NSLocalizedString(@"mavppm_button_3", @"按钮3");
        default:
            break;
    }
    return @"";
}

- (NSArray *)descriptionDictionArray {
    NSMutableArray *desc = [NSMutableArray array];
    for (int i = 1; i < MPChannelNumberCount; ++i) {
        MPChannelType type = [self channelType:i];
        NSString *descStr = [self channelTypeDescription:type];
        [desc addObject:descStr];
    }
    return desc;
}

@end
