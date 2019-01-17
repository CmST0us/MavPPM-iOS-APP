//
//  MPDebugHeartBeatViewController.h
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPViewController.h"

NS_ASSUME_NONNULL_BEGIN

/*
 包类型！ GET  |  SET             |  PUSH
 对应:   ***  |  CMD && CMD_ACK  |  Mavlink Message
 */

typedef NS_ENUM(NSUInteger, MPPackageManagerResultHandingType) {
    MPPackageManagerResultHandingTypeStop,      // 从监听列表中删除
    MPPackageManagerResultHandingTypeContinue,  // 继续/重试， 继续放入下一次事件处理
};

typedef void(^MPPackageManagerSettingResultHandler)(MAV_CMD cmd,
                                                     MAV_RESULT result,
                                                     BOOL timeout,
                                                     MPPackageManagerResultHandingType *handingType); // handingType 默认 Stop

typedef void(^MPPackageManagerGettingResultHander)(MVMessage *result,
                                                   BOOL success,
                                                   BOOL timeout,
                                                   MPPackageManagerResultHandingType *handingType); // handingType 默认Stop

typedef void(^MPPackageManagerPushingResultHandler)(MPPackageManagerResultHandingType *handingType); // handingType 默认为Continue

@interface MPDebugHeartBeatViewController : MPViewController

@end

NS_ASSUME_NONNULL_END
