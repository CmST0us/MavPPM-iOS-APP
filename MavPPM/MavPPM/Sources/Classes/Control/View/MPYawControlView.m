//
//  MPYawControlView.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <MPGravityControlLogic/MPGravityControlLogic.h>
#import "MPYawControlView.h"

@interface MPYawControlView ()
@property (nonatomic, strong) NSNumber *yawValue;
@property (nonatomic, assign) CGFloat currentYawIndicateOffsetFromCenterX;

@property (nonatomic, strong) CAShapeLayer *yawIndicateShapeLayer;
@property (nonatomic, assign) CGRect currentBound;
@property (nonatomic, strong) MPControlValueLinear *linear;
@end

@implementation MPYawControlView {
    CGPoint _startTouchPoint;
}

- (void)viewDidInit {
    [super viewDidInit];
    
    self.userInteractionEnabled = YES;
    _currentBound = self.bounds;
    _touchArea = MPYawControlViewTouchAreaRight;
    self.yawValue = @(1500);
}

- (CAShapeLayer *)yawIndicateShapeLayer {
    if (_yawIndicateShapeLayer) {
        return _yawIndicateShapeLayer;
    }
    _yawIndicateShapeLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_yawIndicateShapeLayer];
    return _yawIndicateShapeLayer;
}

- (BOOL)canRespondTouchAtPoint:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointInView = [self convertPoint:point toView:self];
    CGFloat offset = pointInView.x - [self boundCenterX];
    if (self.touchArea == MPYawControlViewTouchAreaLeft &&
        offset <= 0) {
        return YES;
    } else if (self.touchArea == MPYawControlViewTouchAreaRight &&
               offset >= 0) {
        return YES;
    }
    return NO;
}

- (void)drawRect:(CGRect)rect {
    if (!CGRectEqualToRect(self.bounds, _currentBound)) {
        _currentBound = self.bounds;
        CGPoint zeroPoint = CGPointMake(0, 1500);
        CGPoint rightMax = CGPointMake(self.bounds.size.width / 2, 2000);
        self.linear = [[MPControlValueLinear alloc] initWithPoint:zeroPoint Point2:rightMax];
        self.yawValue = @([self.linear calc:_currentYawIndicateOffsetFromCenterX]);
    }
    
    CGFloat centerX = [self boundCenterX];
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    [path moveToPoint:CGPointMake(centerX + (_currentYawIndicateOffsetFromCenterX * 1.2), self.bounds.origin.y)];
    [path addLineToPoint:CGPointMake(centerX + (_currentYawIndicateOffsetFromCenterX * 1.2), [self boundMaxY])];
    
    [self.yawIndicateShapeLayer setPath:path.CGPath];
    self.yawIndicateShapeLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.yawIndicateShapeLayer.lineWidth = 2;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pointInView = [touch locationInView:self];
    _startTouchPoint = pointInView;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pointInView = [touch locationInView:self];
    CGFloat xOffset = pointInView.x - _startTouchPoint.x;
    _currentYawIndicateOffsetFromCenterX = xOffset;
    self.yawValue = @([self.linear calc:_currentYawIndicateOffsetFromCenterX]);
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    _currentYawIndicateOffsetFromCenterX = 0;
    self.yawValue = @([self.linear calc:_currentYawIndicateOffsetFromCenterX]);
    [self setNeedsDisplay];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if ([self canRespondTouchAtPoint:point withEvent:event]) {
        return self;
    }
    return nil;
}

@end
