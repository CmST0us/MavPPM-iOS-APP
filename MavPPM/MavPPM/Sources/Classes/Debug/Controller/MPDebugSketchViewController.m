//
//  MPDebugSketchViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/5/8.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPDebugSketchViewController.h"
#import "MPWeakTimer.h"

@interface MPDebugSketchViewController ()
@property (nonatomic, strong) MPWeakTimer *timer1;
@property (nonatomic, strong) MPWeakTimer *timer2;
@property (nonatomic, assign) NSInteger timerCount;
@property (nonatomic, assign) NSInteger timerCount2;
@end

@implementation MPDebugSketchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.timerCount = 0;
    self.timerCount2 = 0;
    self.timer1 = [MPWeakTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    __weak typeof(self) weakSelf = self;
    self.timer2 = [MPWeakTimer scheduledTimerWithTimeInterval:1.0 repeats:YES block:^{
        NSLog(@"[Timer]: Block Output %ld", (long)weakSelf.timerCount2++);
    }];
    // Do any additional setup after loading the view.
}

- (void)onTimer {
    NSLog(@"[Timer]: Output %ld", (long)self.timerCount++);
}

@end
