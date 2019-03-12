//
//  UIColor+MavPPMColor.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/11.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "UIColor+MavPPMColor.h"

@implementation UIColor (MavPPMColor)

+ (UIColor *)controlBgBlack {
    return [UIColor blackColor];
}

+ (UIColor *)controlIndicateWhite {
    return [UIColor whiteColor];
}

+ (UIColor *)controlRollRed {
    return [UIColor colorWithRed:1 green:64.0 / 255.0 blue:64.0 / 255.0 alpha:1];
}

+ (UIColor *)controlThrottleGreen {
    return [UIColor colorWithRed:99.0 / 255.0 green:221.0 / 255.0 blue:141.0 / 255.0 alpha:1];
}

+ (UIColor *)confirmGreen {
    return [UIColor colorWithRed:99.0 / 255.0 green:221.0 / 255.0 blue:141.0 / 255.0 alpha:1];
}

@end
