//
//  MPView.h
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry/Masonry.h>
#import "UIColor+MavPPMColor.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (Disable)
- (void)disable;
- (void)enable;
@end

@interface UIView (RectUtils)
- (CGFloat)boundCenterX;
- (CGFloat)boundCenterY;
- (CGPoint)boundOrigin;
- (CGFloat)boundMaxX;
- (CGFloat)boundMaxY;
@end

@interface MPView : UIView

- (void)viewDidInit NS_REQUIRES_SUPER;

@end

NS_ASSUME_NONNULL_END
