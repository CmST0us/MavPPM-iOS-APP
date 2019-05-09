//
//  MPPackageManager.m
//  MavPPM
//
//  Created by CmST0us on 2019/1/16.
//  Copyright © 2019 eric3u. All rights reserved.
//
#import <MPCommLayer/MPCommLayer.h>

#import "MPPackageManager.h"

#pragma mark - MPPackageManagerTask
@interface MPPackageManagerCancelableTask : NSObject
@property (nonatomic, weak) NSObject *observer;

@property (nonatomic, strong) MVMessage *message;
@property (nonatomic, copy) NSString *messageClassString;

@property (nonatomic, strong) id handler;
@property (nonatomic, assign) NSTimeInterval lastSendTime;
@property (nonatomic, assign) MPPackageManagerResultHandingType resultHandingType;
@end

@implementation MPPackageManagerCancelableTask
- (instancetype)init {
    self = [super init];
    if (self) {
        _observer = nil;
        _message = nil;
        _handler = nil;
        _messageClassString = @"";
        _lastSendTime = [[NSDate date] timeIntervalSince1970];
        _resultHandingType = MPPackageManagerResultHandingTypeCancel;
    }
    return self;
}
@end

#pragma mark - MPPackageManager
@interface MPPackageManager ()<MPCommTCPAcceptorDelegate, MPCommDelegate, MVMavlinkDelegate> {
    dispatch_queue_t _workQueue;
}
@property (nonatomic, assign) BOOL isConnected;
@property (nonatomic, strong) NSThread *workThread;
// Read Queue
@property (nonatomic, strong) NSMutableArray<MVMessage *> *receiveMessageQueue;

// Handlers
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<MPPackageManagerCancelableTask *> *> *listeningMessageTasks;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, MPPackageManagerCancelableTask *> *commandMessageTasks;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MPPackageManagerCancelableTask *> *ackableMessageTasks;

// Comm
@property (nonatomic, readonly) BOOL isTCP;
@property (nonatomic, strong) MPUDPSocket *communicationLinkUDP;

@property (nonatomic, strong) MPTCPAcceptor *acceptor;
@property (nonatomic, strong) MPTCPSocket *communicationLink;

@property (nonatomic, strong) MVMavlink *mavlink;
@end

@implementation MPPackageManager
NS_CLOSE_SIGNAL_WARN(onAttach)
NS_CLOSE_SIGNAL_WARN(onDetattch)


#pragma mark - Init Method
- (instancetype)init {
    self = [super init];
    if (self) {
        _localPort = 0;
        _remotePort = 0;
        _remoteDomain = @"127.0.0.1";
        _timeoutInterval = 3;
        
        _mavlink = [[MVMavlink alloc] init];
        _mavlink.delegate = self;
        
        _workQueue = dispatch_queue_create("com.MavPPM.MPPackageManager.workQueue", DISPATCH_QUEUE_SERIAL);
        
        _receiveMessageQueue = [NSMutableArray array];
        _listeningMessageTasks = [NSMutableDictionary dictionary];
        _commandMessageTasks = [NSMutableDictionary dictionary];
        _ackableMessageTasks = [NSMutableDictionary dictionary];
        _isTCP = YES;
        _isConnected = NO;
    }
    return self;
}

static MPPackageManager *instance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[super allocWithZone:NULL] init];
    });
    return instance;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return [MPPackageManager sharedInstance];
}

- (id)copy {
    return [MPPackageManager sharedInstance];
}

- (void)work {
    // 100Hz Runloop
    while (![[NSThread currentThread] isCancelled]) {
        @autoreleasepool {
            dispatch_sync(_workQueue, ^{
                NSTimeInterval workQueueStartTime = [[NSDate date] timeIntervalSince1970];
                // 处理，分发消息
                for (MVMessage *recvMessage in self.receiveMessageQueue) {
                    // 处理监听的消息
                    NSString *recvMesssageClassString = NSStringFromClass([recvMessage class]);
                    NSMutableArray *listeningTasks = [self.listeningMessageTasks objectForKey:recvMesssageClassString];
                    NSMutableArray *removeTasks = [NSMutableArray array];
                    for (MPPackageManagerCancelableTask *task in listeningTasks) {
                        if (task) {
                            if (task.observer != nil && task.handler != nil) {
                                MPPackageManagerMessageListeningHandler h = (MPPackageManagerMessageListeningHandler)task.handler;
                                MPPackageManagerResultHandingType handingType = task.resultHandingType;
                                h(recvMessage, &handingType);
                                task.resultHandingType = handingType;
                                if (handingType == MPPackageManagerResultHandingTypeCancel) {
                                    [removeTasks addObject:task];
                                }
                            } else {
                                [removeTasks addObject:task];
                            }
                        }
                    }
                    [listeningTasks removeObjectsInArray:removeTasks];
                    [removeTasks removeAllObjects];
                    
                    // 处理commannd ack
                    if ([recvMessage isKindOfClass:[MVMessageCommandAck class]]) {
                        MVMessageCommandAck *ackMessage = (MVMessageCommandAck *)recvMessage;
                        NSNumber *commandNumber = [NSNumber numberWithInt:ackMessage.command];
                        MPPackageManagerCancelableTask *task = [self.commandMessageTasks objectForKey:commandNumber];
                        if (task) {
                            if (task.observer && task.handler) {
                                MPPackageManagerCommandMessageResultHandler h = (MPPackageManagerCommandMessageResultHandler)task.handler;
                                MPPackageManagerResultHandingType type = MPPackageManagerResultHandingTypeCancel;
                                h(ackMessage, NO, &type);
                                // ack 成功，删除任务
                                [self.commandMessageTasks removeObjectForKey:commandNumber];
                            } else {
                                [self.commandMessageTasks removeObjectForKey:commandNumber];
                            }
                        }
                    }
                    
                    
                    // [TODO] 处理ackable
                    /*
                    NSMutableArray *ackableTasks = [self.ackableMessageTasks objectForKey:recvMesssageClassString];
                    if (ackableTasks) {
                        for (MPPackageManagerCancelableTask *task in ackableTasks) {
                            if (task) {
                                if (task.handler) {
                                    MPPackageManagerAckableMessageResultHandler h = (MPPackageManagerAckableMessageResultHandler)task.handler;
                                    MPPackageManagerResultHandingType type = MPPackageManagerResultHandingTypeCancel;
                                    h(recvMessage, NO, &type);
                                    // ack成功，删除任务
                                    [removeTasks addObject:task];
                                } else {
                                    [removeTasks addObject:task];
                                }
                            }
                        }
                        [ackableTasks removeObjectsInArray:removeTasks];
                        [removeTasks removeAllObjects];
                    }
                    */
                    
                    // 处理超时
                    NSTimeInterval currentTimeInterval = [[NSDate date] timeIntervalSince1970];
                    
                    // command
                    for (NSNumber *commandNumber in [self.commandMessageTasks allKeys]) {
                        MPPackageManagerCancelableTask *task = [self.commandMessageTasks objectForKey:commandNumber];
                        if (task) {
                            if (ABS(task.lastSendTime - currentTimeInterval) > self.timeoutInterval) {
                                // timeout
                                if (task.observer && task.handler) {
                                    MPPackageManagerCommandMessageResultHandler h = (MPPackageManagerCommandMessageResultHandler)task.handler;
                                    MPPackageManagerResultHandingType type = task.resultHandingType;
                                    h(nil, YES, &type);
                                    task.resultHandingType = type;
                                    if (type == MPPackageManagerResultHandingTypeCancel) {
                                        [self.commandMessageTasks removeObjectForKey:commandNumber];
                                    } else {
                                        task.lastSendTime = currentTimeInterval;
                                        MVMessageCommandLong *msg = (MVMessageCommandLong *)task.message;
                                        MVMessageCommandLong *resendMsg = [[MVMessageCommandLong alloc] initWithSystemId:msg.systemId componentId:msg.componentId targetSystem:msg.targetSystem targetComponent:msg.targetComponent command:msg.command confirmation:msg.confirmation+1 param1:msg.param1 param2:msg.param2 param3:msg.param3  param4:msg.param4 param5:msg.param5 param6:msg.param6 param7:msg.param7];
                                        task.message = resendMsg;
                                        
                                        [self.mavlink sendMessage:resendMsg];
                                    }
                                } else {
                                    [self.commandMessageTasks removeObjectForKey:commandNumber];
                                }
                            } else {
                                // 未超时，等待
                            }
                        }
                    }
                    
                    // [TODO] ackable
                    
                }
                [self.receiveMessageQueue removeAllObjects];
                
                NSTimeInterval workQueueEndTime = [[NSDate date] timeIntervalSince1970];
                NSTimeInterval workTime = workQueueEndTime - workQueueStartTime;
                if (workTime < 0.01) {
                    [NSThread sleepForTimeInterval:0.01 - workTime];
                }
            });
        }
    }
}

#pragma mark - Setter Getter Method
- (void)setIsConnected:(BOOL)isConnected {
    if (isConnected) {
        _isConnected = YES;
        [self emitSignal:@selector(onAttach) withParams:nil];
    } else {
        _isConnected = NO;
        [self emitSignal:@selector(onDetattch) withParams:nil];
    }
}

#pragma mark - Setup Method
- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort
                            remoteDomain:(NSString *)remoteDomain
                              remotePort:(unsigned short)remotePort {
    [self setupPackageManagerWithLocalPort:localPort remoteDomain:remoteDomain remotePort:remotePort tcpLink:NO];
}

- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort {
    [self setupPackageManagerWithLocalPort:localPort remoteDomain:@"" remotePort:0 tcpLink:YES];
}

- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort remoteDomain:(NSString *)remoteDomain remotePort:(unsigned short)remotePort tcpLink:(BOOL)isTCP {
    _isTCP = isTCP;
    [self makeDisconnected];
    if (_communicationLink != nil) {
        [_communicationLink close];
        _communicationLink = nil;
    }
    
    if (_communicationLinkUDP != nil) {
        [_communicationLinkUDP close];
        _communicationLinkUDP = nil;
    }
    
    [self.workThread cancel];
    self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(work) object:nil];
    [self.workThread start];
    
    _localPort = localPort;
    _remoteDomain = [remoteDomain copy];
    _remotePort = remotePort;
    
    if (isTCP) {
        _acceptor = [[MPTCPAcceptor alloc] initWithDelegate:self];
        [_acceptor bindToPort:localPort];
        [_acceptor listen:1];
    } else {
        _communicationLinkUDP = [[MPUDPSocket alloc] initWithLocalPort:localPort delegate:self];
        [_communicationLinkUDP connect:[remoteDomain copy] port:remotePort];
        [self makeConnected];
    }
}

- (void)makeConnected {
    self.isConnected = YES;
}

- (void)makeDisconnected {
    self.isConnected = NO;
    [self.receiveMessageQueue removeAllObjects];
}

#pragma mark - Package Manager Method
- (void)sendMessageWithoutAck:(MVMessage *)message {
    dispatch_async(_workQueue, ^{
        MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
        task.message = message;
        [self.mavlink sendMessage:task.message];
    });
}

- (void)sendCommandMessage:(MVMessage *)aCommandMessage
              withObserver:(NSObject *)observer
                   handler:(MPPackageManagerCommandMessageResultHandler)handler {
    dispatch_async(_workQueue, ^{
        if ([aCommandMessage isKindOfClass:[MVMessageCommandLong class]]) {
            MVMessageCommandLong *commandMesssage = (MVMessageCommandLong *)aCommandMessage;
            NSNumber *commandNumber = [NSNumber numberWithInt:commandMesssage.command];
            MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
            task.message = commandMesssage;
            task.handler = handler;
            task.observer = observer;
            [self.mavlink sendMessage:commandMesssage];
            [self.commandMessageTasks setObject:task forKey:commandNumber];
        }
    });
}

- (void)sendMessageWithAck:(MVMessage *)message
           ackMessageClass:(Class)ackClass
              withObserver:(NSObject *)observer
                   handler:(MPPackageManagerAckableMessageResultHandler)handler {
    // [TODO]
    /*
    [self.lock lock];
    
    MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
    task.handler = handler;
    task.message = message;
    
    [self.sendMesssageQueue addObject:task];
    NSMutableArray *tasks = [self.ackableMessageTasks objectForKey:NSStringFromClass(ackClass)];
    if (tasks == nil) {
        tasks = [[NSMutableArray alloc] init];
    }
    [tasks addObject:task];
    [self.ackableMessageTasks setObject:tasks forKey:NSStringFromClass(ackClass)];
    
    [self.lock unlock];
    */
}

- (void)listenMessage:(Class)messageClass
         withObserver:(NSObject *)observer
          handler:(MPPackageManagerMessageListeningHandler)handler {
    dispatch_async(_workQueue, ^{
        MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
        task.handler = handler;
        task.observer = observer;
        task.messageClassString = NSStringFromClass(messageClass);
        NSMutableArray *tasks = [self.listeningMessageTasks objectForKey:NSStringFromClass(messageClass)];
        if (tasks == nil) {
            tasks = [[NSMutableArray alloc] init];
        }
        [tasks addObject:task];
        [self.listeningMessageTasks setObject:tasks forKey:NSStringFromClass(messageClass)];

    });
}

#pragma mark - Delegate Method
- (void)communicator:(id)aCommunicator didReadData:(NSData *)data {
    [self.mavlink parseData:data];
}

- (void)communicator:(id)aCommunicator handleEvent:(MPCommEvent)event {
    if (event == MPCommEventHasBytesAvailable) {
        [aCommunicator read];
    } else if (event == MPCommEventErrorOccurred) {
        [aCommunicator close];
        [self makeDisconnected];
    } else if (event == MPCommEventEndEncountered) {
        [aCommunicator close];
        [self makeDisconnected];
    }
}

- (void)acceptor:(MPTCPAcceptor *)aAcceptor handleEvent:(MPCommTCPAcceptorEvent)aEvent {
    if (aEvent == MPCommTCPAcceptorEventCanAccept) {
        [aAcceptor accept];
    }
}

- (void)acceptor:(MPTCPAcceptor *)aAcceptor didAcceptSocket:(MPTCPSocket *)aSocket {
    self.communicationLink = aSocket;
    [self.communicationLink open];
    [self.communicationLink continueFinished];
    self.communicationLink.delegate = self;
    [self makeConnected];
}

- (void)mavlink:(MVMavlink *)mavlink didGetMessage:(id<MVMessage>)message {
    dispatch_async(_workQueue, ^{
        [self.receiveMessageQueue addObject:message];
    });
}

- (BOOL)mavlink:(MVMavlink *)mavlink shouldWriteData:(NSData *)data {
    if (self.isTCP) {
        [self.communicationLink write:data];
    } else {
        [self.communicationLinkUDP write:data];
    }
    return YES;
}

@end
