//
//  MPYawControlView.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, MPYawControlViewTouchArea) {
    MPYawControlViewTouchAreaLeft,
    MPYawControlViewTouchAreaRight,
};

@interface MPYawControlView : MPView
@property (nonatomic, readonly) NSNumber *yawValue;
@property (nonatomic, assign) MPYawControlViewTouchArea touchArea;
@end

NS_ASSUME_NONNULL_END
