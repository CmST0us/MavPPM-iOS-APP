//
//  MPControlLockViewController.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <NSObjectSignals/NSObject+SignalsSlots.h>
#import "MPViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPControlLockViewController : MPViewController
- (NS_SIGNAL)onUnlock;
@end

NS_ASSUME_NONNULL_END
