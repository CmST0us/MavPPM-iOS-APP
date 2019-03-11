//
//  MPView.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/3.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPView.h"

@implementation MPView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self setupView];
        [self viewDidInit];
    }
    return self;
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
