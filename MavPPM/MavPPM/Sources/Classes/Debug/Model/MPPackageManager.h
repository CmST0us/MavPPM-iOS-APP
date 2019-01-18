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

typedef NS_ENUM(NSUInteger, MPPackageManagerResultHandingType) {
    MPPackageManagerResultHandingTypeCancel,      // 从监听列表中删除
    MPPackageManagerResultHandingTypeContinue,  // 继续/重试， 继续放入下一次事件处理
};

typedef void(^MPPackageManagerAckableMessageResultHandler)(MVMessage *ackMessage,
                                                           BOOL timeout,
                                                           MPPackageManagerResultHandingType *handingType); // handingType 默认 Stop

typedef void(^MPPackageManagerCommandMessageResultHandler)(MVMessageCommandAck *ack,
                                                           BOOL timeout,
                                                           MPPackageManagerResultHandingType *handingType); // handingType 默认 Stop

typedef void(^MPPackageManagerMessageListeningHandler)(MVMessage *message,
                                                       MPPackageManagerResultHandingType *handingType); // handingType 默认为Continue


@interface MPPackageManager : NSObject

@property (nonatomic, readonly) unsigned short localPort;
@property (nonatomic, readonly) unsigned short remotePort;
@property (nonatomic, readonly) NSString *remoteDomain;

+ (instancetype)sharedInstance;

- (void)setupPackageManagerWithLocalPort:(unsigned short)localPort
                            remoteDomain:(NSString *)remoteDomain
                              remotePort:(unsigned short)remotePort;

- (void)sendCommandMessage:(MVMessage *)aCommandMessage
               withHandler:(MPPackageManagerCommandMessageResultHandler)handler;

- (void)listenMessage:(Class)messageClass
          withHandler:(MPPackageManagerMessageListeningHandler)handler;

- (void)sendMessageWithoutAck:(MVMessage *)message;

- (void)sendMessageWithAck:(MVMessage *)message
           ackMessageClass:(Class)ackClass
                   handler:(MPPackageManagerAckableMessageResultHandler)handler;
@end

NS_ASSUME_NONNULL_END
