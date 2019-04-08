//
//  MPPackageManager.h
//  MavPPM
//
//  Created by CmST0us on 2019/1/16.
//  Copyright © 2019 eric3u. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MPMavlink/MPMavlink.h>

NS_ASSUME_NONNULL_BEGIN

extern NSNotificationName MPPackageManagerDidConnectedNotificationName;
extern NSNotificationName MPPackageManagerDisconnectedNotificationName;

typedef NS_ENUM(NSUInteger, MPPackageManagerResultHandingType) {
    MPPackageManagerResultHandingTypeCancel,      // 从监听列表中删除
    MPPackageManagerResultHandingTypeContinue,  // 继续/重试， 继续放入下一次事件处理
};

typedef void(^MPPackageManagerAckableMessageResultHandler)( MVMessage * _Nullable ackMessage,
                                                           BOOL timeout,
                                                           MPPackageManagerResultHandingType *handingType); // handingType 默认 Stop

typedef void(^MPPackageManagerCommandMessageResultHandler)( MVMessageCommandAck * _Nullable ack,
                                                           BOOL timeout,
                                                           MPPackageManagerResultHandingType *handingType); // handingType 默认 Stop

typedef void(^MPPackageManagerMessageListeningHandler)( MVMessage * _Nullable message,
                                                       MPPackageManagerResultHandingType *handingType); // handingType 默认为Continue


@interface MPPackageManager : NSObject

@property (nonatomic, assign) NSTimeInterval timeoutInterval; //超时时间

@property (nonatomic, readonly) unsigned short localPort;
@property (nonatomic, readonly) unsigned short remotePort;
@property (nonatomic, readonly) NSString *remoteDomain;
@property (nonatomic, readonly) BOOL isConnected;

+ (instancetype)sharedInstance;

// UDP
- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort
                            remoteDomain:(NSString *)remoteDomain
                              remotePort:(unsigned short)remotePort;

// TCP
- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort;

- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort
                            remoteDomain:(NSString *)remoteDomain
                              remotePort:(unsigned short)remotePort
                                 tcpLink:(BOOL)isTCP;

- (void)sendCommandMessage:(MVMessage *)aCommandMessage
              withObserver:(NSObject *)observer
                   handler:(MPPackageManagerCommandMessageResultHandler)handler;

- (void)listenMessage:(Class)messageClass
         withObserver:(NSObject *)observer
              handler:(MPPackageManagerMessageListeningHandler)handler;

- (void)sendMessageWithoutAck:(MVMessage *)message;

@end

NS_ASSUME_NONNULL_END
