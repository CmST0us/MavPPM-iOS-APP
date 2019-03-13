//
//  MPView.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPView.h"

#define kMPUIButtonDisableAlpha (0.5)
#define kMPUIButtonEnableAlpha (1)
@implementation UIButton (Disable)
- (void)disable {
    self.alpha = kMPUIButtonDisableAlpha;
    self.userInteractionEnabled = NO;
}

- (void)enable {
    self.alpha = kMPUIButtonEnableAlpha;
    self.userInteractionEnabled = YES;
}
@end

@implementation UIView (RectUtils)

- (CGFloat)boundCenterX {
    return (self.bounds.size.width / 2) + self.bounds.origin.x;
}

- (CGFloat)boundCenterY {
    return (self.bounds.size.height / 2) + self.bounds.origin.y;
}

- (CGPoint)boundOrigin {
    return self.bounds.origin;
}

- (CGFloat)boundMaxX {
    return self.bounds.origin.x + self.bounds.size.width;
}

- (CGFloat)boundMaxY {
    return self.bounds.origin.y + self.bounds.size.height;
}
@end

@implementation MPView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupView];
        [self viewDidInit];
    }
    return self;
}

- (void)setupView {
    [self setBackgroundColor:[UIColor clearColor]];
}

- (void)viewDidInit {
    
}

@end
