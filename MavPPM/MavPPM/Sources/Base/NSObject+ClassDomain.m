//
//  NSObject+ClassDomain.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "NSObject+ClassDomain.h"

@implementation NSObject (ClassDomain)

- (NSString *)classDomainWithName:(NSString *)name {
    NSString *str = [[NSString alloc] initWithFormat:@"com.MavPPM.%@.%@", NSStringFromClass([self class]), name];
    return str;
}

- (NSString *)classDomain {
    NSString *str = [[NSString alloc] initWithFormat:@"com.MavPPM.%@", NSStringFromClass([self class])];
    return str;
}

@end
