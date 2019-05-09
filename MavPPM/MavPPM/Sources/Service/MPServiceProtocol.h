//
//  MPServiceProtocol.h
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol MPServiceProtocol <NSObject>
- (void)run;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
