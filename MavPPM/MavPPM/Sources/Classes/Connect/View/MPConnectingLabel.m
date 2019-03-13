//
//  MPConnectingLabel.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPConnectingLabel.h"

#define kMPConnectingLabelCircleOffsetFromTitleLabel (8)
#define kMPConnectingCircleRaduis (8)

@interface MPConnectingLabel () <CAAnimationDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CAShapeLayer *animatingCircleShapeLayer;
@end

@implementation MPConnectingLabel

- (void)viewDidInit {
    [super viewDidInit];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:18];
    self.titleLabel.text = NSLocalizedString(@"mavppm_connect_view_connecting_title", nil);
    self.titleLabel.textColor = [UIColor whiteColor];
    [self sizeToFit];
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self);
        make.right.equalTo(self).offset(-(kMPConnectingCircleRaduis * 2 + kMPConnectingLabelCircleOffsetFromTitleLabel + 5));
    }];
    self.layer.masksToBounds = YES;
}

- (CAShapeLayer *)animatingCircleShapeLayer {
    if (_animatingCircleShapeLayer) {
        return _animatingCircleShapeLayer;
    }
    _animatingCircleShapeLayer = [[CAShapeLayer alloc] init];
    [self.layer addSublayer:_animatingCircleShapeLayer];
    return _animatingCircleShapeLayer;
}

- (void)drawRect:(CGRect)rect {
    CGFloat circleX = self.titleLabel.frame.origin.x + self.titleLabel.frame.size.width + kMPConnectingLabelCircleOffsetFromTitleLabel;
    CGFloat circleY = self.titleLabel.frame.origin.y;
    CGFloat circleH = self.titleLabel.frame.size.height;
    CGFloat circleW = circleH;
    
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(circleX + kMPConnectingCircleRaduis, [self boundCenterY]) radius:kMPConnectingCircleRaduis startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    
    [self.animatingCircleShapeLayer setPath:path.CGPath];
    [self.animatingCircleShapeLayer setStrokeColor:[UIColor whiteColor].CGColor];
    [self.animatingCircleShapeLayer setLineWidth:2];
    [self.animatingCircleShapeLayer setLineCap:kCALineCapRound];
    self.animatingCircleShapeLayer.strokeStart = 0;
    [self animateRotateStep1];
}

- (void)animateRotateStep1 {
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"strokeStart"];
    anim.fromValue = @(1);
    anim.toValue = @(0);
    anim.duration = 1;
    anim.repeatCount = INFINITY;
    anim.autoreverses = YES;
    [self.animatingCircleShapeLayer addAnimation:anim forKey:@"circleStrokeStart"];
}

@end
