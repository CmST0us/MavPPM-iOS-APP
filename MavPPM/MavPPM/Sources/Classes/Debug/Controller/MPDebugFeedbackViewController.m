//
//  MPDebugFeedbackViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/3/13.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import "MPDebugFeedbackViewController.h"

@interface MPDebugFeedbackViewController ()
@property (nonatomic, strong) UIImpactFeedbackGenerator *feedback;
@end

@implementation MPDebugFeedbackViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleHeavy];
    [self.feedback prepare];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.feedback impactOccurred];
}



@end
