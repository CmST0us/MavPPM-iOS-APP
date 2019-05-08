//
//  MPUAVControlManager.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPUAVControlManager.h"

@implementation MPUAVControlManager

static MPUAVControlManager *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MPUAVControlManager sharedInstance];
}

- (id)copy {
    return [MPUAVControlManager sharedInstance];
}

@end
