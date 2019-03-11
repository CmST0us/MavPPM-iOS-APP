//
//  MPThrottleControlView.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/11.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPThrottleControlView.h"

@interface MPThrottleControlView ()
@property (nonatomic, strong) NSNumber *throttleValue;
@property (nonatomic, assign) CGFloat currentThrottleIndicateRectHeight;

@property (nonatomic, strong) CAShapeLayer *throttleShapeLayer;
@property (nonatomic, assign) CGRect currentBound;
@property (nonatomic, strong) MPControlValueLinear *liner;
@end

@implementation MPThrottleControlView {
    CGPoint _touchBeginPoint;
    CGFloat _touchBeginThrottleRectHeight;
}

- (void)viewDidInit {
    [super viewDidInit];
    
    self.userInteractionEnabled = YES;
    _currentBound = self.bounds;
}

- (CAShapeLayer *)throttleShapeLayer {
    if (_throttleShapeLayer) {
        return _throttleShapeLayer;
    }
    _throttleShapeLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_throttleShapeLayer];
    return _throttleShapeLayer;
}

- (void)drawRect:(CGRect)rect {
    if (!CGRectEqualToRect(self.bounds, _currentBound)) {
        _currentBound = self.bounds;
        CGPoint zeroThrottle = CGPointMake(0, 1000);
        CGPoint maxThrottle = CGPointMake(self.bounds.size.height, 2000);
        self.liner = [[MPControlValueLinear alloc] initWithPoint:zeroThrottle Point2:maxThrottle];
    }
    
    CGFloat throttlePointY = self.bounds.size.height - self.currentThrottleIndicateRectHeight;
    self.throttleValue = @([self.liner calc:self.currentThrottleIndicateRectHeight]);
    
    CGRect throttleIndicateRect = CGRectMake(self.bounds.origin.x,
                                             throttlePointY,
                                             self.bounds.size.width,
                                             self.currentThrottleIndicateRectHeight);
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:throttleIndicateRect];
    [self.throttleShapeLayer setPath:path.CGPath];
    [self.throttleShapeLayer setFillColor:[UIColor controlThrottleGreen].CGColor];
}

- (void)updateConstraints {
    [super updateConstraints];
    [self setNeedsDisplay];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x > self.bounds.size.width / 2) {
        _touchBeginPoint = point;
        _touchBeginThrottleRectHeight = self.currentThrottleIndicateRectHeight;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x > self.bounds.size.width / 2) {
        CGFloat yOffset = point.y - _touchBeginPoint.y;
        CGFloat throttleAddValue = -yOffset;
        self.currentThrottleIndicateRectHeight = _touchBeginThrottleRectHeight + throttleAddValue;
        if (self.currentThrottleIndicateRectHeight < 0) {
            self.currentThrottleIndicateRectHeight = 0;
        } else if (self.currentThrottleIndicateRectHeight > self.bounds.size.height) {
            self.currentThrottleIndicateRectHeight = self.bounds.size.height;
        }
        
        [self setNeedsDisplay];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
}

@end
