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
@property (nonatomic, assign) NSInteger retryTimes;
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
        _retryTimes = 0;
        _resultHandingType = MPPackageManagerResultHandingTypeCancel;
    }
    return self;
}


@end

#pragma mark - MPPackageManager
@interface MPPackageManager ()<MPCommDelegate, MVMavlinkDelegate> {
    
}
@property (nonatomic, strong) NSRecursiveLock *lock;
@property (nonatomic, strong) NSLock *receiveMessageQueueLock;
@property (nonatomic, strong) NSThread *workThread;
// Read Queue
@property (nonatomic, strong) NSMutableArray<MVMessage *> *receiveMessageQueue;
// Write Queue
@property (nonatomic, strong) NSMutableArray<MPPackageManagerCancelableTask *> *sendMesssageQueue;

// Handlers
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<MPPackageManagerCancelableTask *> *> *listeningMessageTasks;

@property (nonatomic, strong) NSMutableDictionary<NSNumber *, MPPackageManagerCancelableTask *> *commandMessageTasks;

@property (nonatomic, strong) NSMutableDictionary<NSString *, NSMutableArray<MPPackageManagerCancelableTask *> *> *ackableMessageResultHandlers;

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
        
        _lock = [[NSRecursiveLock alloc] init];
        
        _receiveMessageQueue = [NSMutableArray array];
        _sendMesssageQueue = [NSMutableArray array];
        _listeningMessageTasks = [NSMutableDictionary dictionary];
        _commandMessageTasks = [NSMutableDictionary dictionary];
        _ackableMessageResultHandlers = [NSMutableDictionary dictionary];
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
        while (![[NSThread currentThread] isCancelled]) {
            // 先发送消息
            
            //// 遍历发送sendMessageQueue
            
            // 再处理，分发消息
            
            //// 遍历 receiveMessageQueue
            ////// 处理监听对象
            ////// 处理ack
            //////// 处理ack超时
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
    [self.lock lock];
    MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
    task.message = message;
    [self.sendMesssageQueue addObject:task];
    [self.lock unlock];
}

- (void)sendCommandMessage:(MVMessage *)aCommandMessage
               withHandler:(MPPackageManagerCommandMessageResultHandler)handler {
    [self.lock lock];
    
    if ([aCommandMessage isKindOfClass:[MVMessageCommandLong class]]) {
        MVMessageCommandLong *commandMesssage = (MVMessageCommandLong *)aCommandMessage;
        NSNumber *commandNumber = [NSNumber numberWithInt:commandMesssage.command];
        MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
        task.message = commandMesssage;
        task.handler = handler;
        [self.sendMesssageQueue addObject:task];
        [self.commandMessageTasks setObject:task forKey:commandNumber];
    }
    
    [self.lock unlock];
}

- (void)sendMessageWithAck:(MVMessage *)message
           ackMessageClass:(Class)ackClass
                   handler:(MPPackageManagerAckableMessageResultHandler)handler {
    [self.lock lock];
    
    MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
    task.handler = handler;
    task.message = message;
    
    [self.sendMesssageQueue addObject:task];
    NSMutableArray *tasks = [self.ackableMessageResultHandlers objectForKey:NSStringFromClass(ackClass)];
    if (tasks == nil) {
        tasks = [[NSMutableArray alloc] init];
    }
    [tasks addObject:task];
    [self.ackableMessageResultHandlers setObject:tasks forKey:NSStringFromClass(ackClass)];
    
    [self.lock unlock];
}

- (void)listenMessage:(Class)messageClass
          withHandler:(MPPackageManagerMessageListeningHandler)handler {
    [self.lock lock];
    
    MPPackageManagerCancelableTask *task = [[MPPackageManagerCancelableTask alloc] init];
    task.handler = handler;
    task.messageClassString = NSStringFromClass(messageClass);
    NSMutableArray *tasks = [self.listeningMessageTasks objectForKey:NSStringFromClass(messageClass)];
    if (tasks == nil) {
        tasks = [[NSMutableArray alloc] init];
    }
    [tasks addObject:task];
    [self.listeningMessageTasks setObject:tasks forKey:NSStringFromClass(messageClass)];

    [self.lock unlock];
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
    [self.receiveMessageQueueLock lock];
    [self.receiveMessageQueue addObject:message];
    [self.receiveMessageQueueLock unlock];
}

- (BOOL)mavlink:(MVMavlink *)mavlink shouldWriteData:(NSData *)data {
    [self.communicationLink write:data];
    return YES;
}

@end
