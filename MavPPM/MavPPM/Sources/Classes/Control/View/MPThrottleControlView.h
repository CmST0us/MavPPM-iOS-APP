//
//  MPThrottleControlView.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/11.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MPThrottleControlViewTouchArea) {
    MPThrottleControlViewTouchAreaLeft,
    MPThrottleControlViewTouchAreaRight,
};

@interface MPThrottleControlView : MPView
@property (nonatomic, readonly) NSNumber *throttleValue;
@property (nonatomic, assign) MPThrottleControlViewTouchArea touchArea;
@end

NS_ASSUME_NONNULL_END
