//
//  NSObject+ClassDomain.h
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (ClassDomain)
- (NSString *)classDomainWithName:(NSString *)name;
- (NSString *)classDomain;
@end

NS_ASSUME_NONNULL_END
