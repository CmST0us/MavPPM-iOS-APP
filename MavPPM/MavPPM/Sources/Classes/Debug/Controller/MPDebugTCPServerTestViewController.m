//
//  MPDebugTCPServerTestViewController.m
//  MavPPM
//
//  Created by CmST0us on 2019/2/11.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Masonry/Masonry.h>
#import <MPCommLayer/MPCommLayer.h>
#import "MPDebugTCPServerTestViewController.h"

#define kDefaultUsbmuxdPort 17123

@interface MPDebugTCPServerTestViewController ()<MPCommTCPAcceptorDelegate, MPCommDelegate>
@property (nonatomic, strong) MPTCPAcceptor *acceptor;
@property (nonatomic, strong) MPTCPSocket *socket;

@property (nonatomic, strong) UITextView *textView;
@end

@implementation MPDebugTCPServerTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.acceptor = [[MPTCPAcceptor alloc] initWithDelegate:self];
    [self.acceptor bindToPort:kDefaultUsbmuxdPort];
    [self.acceptor listen:5];
    
    self.textView = [[UITextView alloc] init];
    self.textView.editable = NO;
    self.textView.text = @"DEBUG\n";
    [self.view addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(44);
        make.left.right.bottom.equalTo(self.view);
    }];
}

- (void)appendDebugString:(NSString *)str {
    dispatch_async(dispatch_get_main_queue(), ^{
        self.textView.text = [self.textView.text stringByAppendingString:str];
    });
}
- (void)acceptor:(MPTCPAcceptor *)aAcceptor handleEvent:(MPCommTCPAcceptorEvent)aEvent {
    if (aEvent == MPCommTCPAcceptorEventCanAccept) {
        [aAcceptor accept];
        [self appendDebugString:@"[ACCEPTOR]: Did Accept\n"];
    } else {
        [self appendDebugString:@"[ACCEPTOR]: Error\n"];
    }
}

- (void)acceptor:(MPTCPAcceptor *)aAcceptor didAcceptSocket:(MPTCPSocket *)aSocket {
    self.socket = aSocket;
    [self.socket open];
    [self.socket continueFinished];
    self.socket.delegate = self;
}

- (void)communicator:(id)aCommunicator didReadData:(NSData *)data {
    NSString *str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [self appendDebugString:str];
}

- (void)communicator:(id)aCommunicator handleEvent:(MPCommEvent)event {
    if (event == MPCommEventHasBytesAvailable) {
        [aCommunicator read];
    } else if (event == MPCommEventEndEncountered) {
        [self appendDebugString:@"[SOCKET]: EOF\n"];
        [aCommunicator close];
    } else if (event == MPCommEventErrorOccurred) {
        [self appendDebugString:@"[SOCKET]: Error\n"];
        [aCommunicator close];
    }
}

@end
