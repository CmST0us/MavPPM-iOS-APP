//
//  MPGraviryPitchRollIndicateView.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/10.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPGraviryPitchRollIndicateView.h"

#define kMPGraviryPitchRollIndicateViewCircleRadius (40)

@interface MPGraviryPitchRollIndicateView ()
@property (nonatomic, strong) CAShapeLayer *circleLayer;
@property (nonatomic, strong) MPControlValueLinear *linear;
@property (nonatomic, assign) CGRect currentBound;
@end

@implementation MPGraviryPitchRollIndicateView

- (void)viewDidInit {
    [super viewDidInit];
    
    self.userInteractionEnabled = NO;
    _currentBound = self.bounds;
}

- (CAShapeLayer *)circleLayer {
    if (_circleLayer) {
        return _circleLayer;
    }
    _circleLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_circleLayer];
    return _circleLayer;
}

- (void)setRollValue:(NSNumber *)rollValue {
    _rollValue = rollValue;
    [self setNeedsDisplay];
}

- (void)setPitchValue:(NSNumber *)pitchValue {
    _pitchValue = pitchValue;
    [self setNeedsDisplay];
}

- (void)drawCircle {
    if (CGRectIsEmpty(self.bounds)) {
        return;
    }
    
    CGFloat x = self.bounds.origin.x;
    CGFloat y = self.bounds.origin.y;
    CGFloat width = self.bounds.size.width;
    CGFloat height = self.bounds.size.height;
    
    CGFloat centerX = (x + width) / 2;
    CGFloat centerY = (y + height) / 2;
    
    CGFloat halfHeight = ABS(height / 2);
    CGFloat halfWidth = ABS(width / 2);
    
    CGFloat circleXOffsetFromCenterX = halfHeight * tan(self.rollValue.doubleValue);
    CGFloat circleX = circleXOffsetFromCenterX + centerX;
    CGFloat circleYOffsetFromCenterY = [self.linear calc:self.pitchValue.doubleValue];
    CGFloat circleY = circleYOffsetFromCenterY + centerY;
    
    UIBezierPath *circlePath = [UIBezierPath bezierPath];
    [circlePath addArcWithCenter:CGPointMake(circleX, circleY) radius:kMPGraviryPitchRollIndicateViewCircleRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    [self.circleLayer setLineWidth:0];
    [self.circleLayer setPath:circlePath.CGPath];
    [self.circleLayer setFillColor:[UIColor controlIndicateWhite].CGColor];
}


- (void)drawRect:(CGRect)rect {
    if (!CGRectEqualToRect(self.bounds, _currentBound)) {
        CGPoint centerPoint = CGPointMake(0,
                                          0);
        CGPoint topPoint = CGPointMake(DEGToRAD(30),
                                       self.bounds.size.height / 2 + self.bounds.origin.y + kMPGraviryPitchRollIndicateViewCircleRadius
                                       );
        
        self.linear = [[MPControlValueLinear alloc] initWithPoint:centerPoint Point2:topPoint];
    }
    
    [self drawCircle];
    
    _currentBound = self.bounds;
}

@end
