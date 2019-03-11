//
//  MPGraviryPitchRollIndicateView.h
//  MavPPM
//
//  Created by CmST0us on 2019/3/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPGraviryPitchRollIndicateView : MPView
@property (nonatomic, strong) NSNumber *rollValue;
@property (nonatomic, strong) NSNumber *pitchValue;
@end

NS_ASSUME_NONNULL_END
