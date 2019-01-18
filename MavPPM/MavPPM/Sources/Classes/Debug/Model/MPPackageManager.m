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
@interface MPPackageManager ()<MPCommDelegate, MVMavlinkDelegate> {
    dispatch_queue_t _workQueue;
}

@property (nonatomic, strong) NSThread *workThread;
// Read Queue
@property (nonatomic, strong) NSMutableArray<MVMessage *> *receiveMessageQueue;
// Write Queue
@property (nonatomic, strong) NSMutableArray<MPPackageManagerCancelableTask *> *sendMesssageQueue;

// Handlers
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<MPPackageManagerCancelableTask *> *> *listeningMessageTasks;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, MPPackageManagerCancelableTask *> *commandMessageTasks;

@property (nonatomic, strong) NSMutableDictionary<NSString *, MPPackageManagerCancelableTask *> *ackableMessageTasks;

// Comm
@property (nonatomic, strong) MPUDPSocket *communicationLink;
@property (nonatomic, strong) MVMavlink *mavlink;
@end

@implementation MPPackageManager

#pragma mark - Init Method
- (instancetype)init {
    self = [super init];
    if (self) {
        _localPort = 0;
        _remotePort = 0;
        _remoteDomain = @"127.0.0.1";
        
        _mavlink = [[MVMavlink alloc] init];
        _mavlink.delegate = self;
        
        _workQueue = dispatch_queue_create("com.MavPPM.MPPackageManager.workQueue", DISPATCH_QUEUE_SERIAL);
        
        _receiveMessageQueue = [NSMutableArray array];
        _sendMesssageQueue = [NSMutableArray array];
        _listeningMessageTasks = [NSMutableDictionary dictionary];
        _commandMessageTasks = [NSMutableDictionary dictionary];
        _ackableMessageTasks = [NSMutableDictionary dictionary];
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
    @autoreleasepool {
        // 100Hz Runloop
        while (![[NSThread currentThread] isCancelled]) {
            dispatch_sync(_workQueue, ^{
                NSTimeInterval workQueueStartTime = [[NSDate date] timeIntervalSince1970];
                //// 遍历发送sendMessageQueue
                for (MPPackageManagerCancelableTask *task in self.sendMesssageQueue) {
                    if (task.message != nil) {
                        [self.mavlink sendMessage:task.message];
                    }
                }
                [self.sendMesssageQueue removeAllObjects];
                
                // 再处理，分发消息
                for (MVMessage *recvMessage in self.receiveMessageQueue) {
                    // 处理监听的消息
                    NSString *recvMesssageClassString = NSStringFromClass([recvMessage class]);
                    NSMutableArray *listeningTasks = [self.listeningMessageTasks objectForKey:recvMesssageClassString];
                    NSMutableArray *removeTasks = [NSMutableArray array];
                    for (MPPackageManagerCancelableTask *tasks in listeningTasks) {
                        if (tasks.handler != nil) {
                            MPPackageManagerMessageListeningHandler h = (MPPackageManagerMessageListeningHandler)tasks.handler;
                            MPPackageManagerResultHandingType handingType = tasks.resultHandingType;
                            h(recvMessage, &handingType);
                            tasks.resultHandingType = handingType;
                            if (handingType == MPPackageManagerResultHandingTypeCancel) {
                                [removeTasks addObject:tasks];
                            }
                        } else {
                            [removeTasks addObject:tasks];
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
                            if (task.handler) {
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
                                if (task.handler) {
                                    MPPackageManagerCommandMessageResultHandler h = (MPPackageManagerCommandMessageResultHandler)task.handler;
                                    MPPackageManagerResultHandingType type = task.resultHandingType;
                                    h(nil, YES, &type);
                                    task.resultHandingType = type;
                                    if (type == MPPackageManagerResultHandingTypeCancel) {
                                        [self.commandMessageTasks removeObjectForKey:commandNumber];
                                    } else {
                                        task.lastSendTime = currentTimeInterval;
                                        [self.sendMesssageQueue addObject:task];
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
- (MPUDPSocket *)communicationLink {
    if (_communicationLink == nil) {
        _communicationLink = [[MPUDPSocket alloc] initWithLocalPort:_localPort delegate:self];
    }
    return _communicationLink;
}

#pragma mark - Setup Method
- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort
                            remoteDomain:(NSString *)remoteDomain
                              remotePort:(unsigned short)remotePort {
    if (_communicationLink != nil) {
        [_communicationLink close];
        _communicationLink = nil;
    }

    [self.workThread cancel];
    self.workThread = [[NSThread alloc] initWithTarget:self selector:@selector(work) object:nil];
    [self.workThread start];
    
    _localPort = localPort;
    _remoteDomain = [remoteDomain copy];
    _remotePort = remotePort;
    
    _communicationLink = [[MPUDPSocket alloc] initWithLocalPort:localPort delegate:self];
    [_communicationLink connect:[remoteDomain copy] port:remotePort];
}

#pragma mark - Package Manager Method
- (void)sendMessageWithoutAck:(MVMessage *)message {
    dispatch_sync(_workQueue, ^{
        MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
        task.message = message;
        [self.sendMesssageQueue addObject:task];
    });
}

- (void)sendCommandMessage:(MVMessage *)aCommandMessage
               withHandler:(MPPackageManagerCommandMessageResultHandler)handler {
    dispatch_sync(_workQueue, ^{
        if ([aCommandMessage isKindOfClass:[MVMessageCommandLong class]]) {
            MVMessageCommandLong *commandMesssage = (MVMessageCommandLong *)aCommandMessage;
            NSNumber *commandNumber = [NSNumber numberWithInt:commandMesssage.command];
            MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
            task.message = commandMesssage;
            task.handler = handler;
            [self.sendMesssageQueue addObject:task];
            [self.commandMessageTasks setObject:task forKey:commandNumber];
        }
    });
}

- (void)sendMessageWithAck:(MVMessage *)message
           ackMessageClass:(Class)ackClass
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
          withHandler:(MPPackageManagerMessageListeningHandler)handler {
    dispatch_sync(_workQueue, ^{
        MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
        task.handler = handler;
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
    }
}

- (void)mavlink:(MVMavlink *)mavlink didGetMessage:(id<MVMessage>)message {
    dispatch_sync(_workQueue, ^{
        [self.receiveMessageQueue addObject:message];
    });
}

- (BOOL)mavlink:(MVMavlink *)mavlink shouldWriteData:(NSData *)data {
    [self.communicationLink write:data];
    return YES;
}

@end
