//
//  MPGravityRollIndicateView.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPGravityRollIndicateView.h"

@interface MPGravityRollIndicateView ()

@property (nonatomic, strong) CAShapeLayer *indicateLayer;

@end

@implementation MPGravityRollIndicateView

- (void)viewDidInit {
    [super viewDidInit];
    self.userInteractionEnabled = NO;
}

- (CAShapeLayer *)indicateLayer {
    if (_indicateLayer) {
        return _indicateLayer;
    }
    _indicateLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_indicateLayer];
    return _indicateLayer;
}

- (void)setRollValue:(NSNumber *)rollValue {
    _rollValue = rollValue;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    CGFloat x = self.bounds.origin.x;
    CGFloat y = self.bounds.origin.y;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat centerX = [self boundCenterX];
    CGFloat centerY = [self boundCenterY];
    
    CGFloat halfHeight = ABS(height / 2);
    CGFloat halfWidth = ABS(width / 2);
    
    CGFloat rollLineStartXOffsetFromCenterX = halfHeight * tan(self.rollValue.doubleValue);
    CGFloat rollLineStartX = rollLineStartXOffsetFromCenterX + centerX;
    CGFloat rollLineStartY = y;
    
    CGFloat rollLineEndX = rollLineStartX - (2 * rollLineStartXOffsetFromCenterX);
    CGFloat rollLineEndY = rollLineStartY + height;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    // Start From Center X
    [path moveToPoint:CGPointMake(centerX, rollLineStartY)];
    [path addLineToPoint:CGPointMake(rollLineStartX, rollLineStartY)];
    [path addLineToPoint:CGPointMake(rollLineEndX, rollLineEndY)];
    [path addLineToPoint:CGPointMake(centerX, rollLineEndY)];
    [path addLineToPoint:CGPointMake(centerX, rollLineStartY)];
    
    [path closePath];
    [self.indicateLayer setPath:path.CGPath];
    [self.indicateLayer setFillColor:[UIColor controlRollRed].CGColor];
}


@end
