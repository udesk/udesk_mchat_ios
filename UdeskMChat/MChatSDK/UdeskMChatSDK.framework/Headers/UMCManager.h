//
//  UMCManager.h
//  UdeskMChatSDK
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMCSystem.h"
#import "UMCCustomer.h"
#import "UMCMessage.h"
#import "UMCMerchant.h"

/**
 *  当未读消息发生改变时会发送通知
 */
#define UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION @"UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION"

@interface UMCManager : NSObject

/**
 初始化方法 （建议在application:didFinishLaunchingWithOptions: 方法里调用）

 @param system 多商户系统信息
 @param customer 客户信息
 @param completion 完成回调，回调成功error为nil
 */
+ (void)initWithSystem:(UMCSystem *)system customer:(UMCCustomer *)customer completion:(void(^)(NSError *error))completion;

/**
 获取所有商户

 @param completion 完成回调
 */
+ (void)getMerchants:(void(^)(NSArray<UMCMerchant *> *merchantsArray))completion;

/**
 获取单个商户信息

 @param merchantId 商户ID
 @param completion 完成回调
 */
+ (void)getMerchantWithMerchantId:(NSString *)merchantId
                       completion:(void(^)(UMCMerchant *merchant))completion;

/**
 标记商户消息为已读

 @param euid 商户ID
 @param completion 完成回调
 */
+ (void)readMerchantsWithEuid:(NSString *)euid
                   completion:(void(^)(BOOL result))completion;

/**
 删除商户
 
 @param euid 商户ID
 @param completion 完成回调
 */
+ (void)deleteMerchantsWithEuid:(NSString *)euid
                     completion:(void(^)(BOOL result))completion;

/**
 获取商户消息列表

 @param euid 商户ID
 @param messageUUID 消息ID（可以为空）
 @param completion 完成回调
 */
+ (void)getMessagesWithMerchantsEuid:(NSString *)euid
                         messageUUID:(NSString *)messageUUID
                          completion:(void(^)(NSArray<UMCMessage *> *merchantsArray))completion;

/**
 创建消息

 @param euid 商户ID
 @param message 消息model
 @param completion 完成回调
 */
+ (void)createMessageWithMerchantsEuid:(NSString *)euid
                               message:(UMCMessage *)message
                            completion:(void(^)(UMCMessage *message))completion;

/**
 创建咨询对象
 
 @param euid 商户ID
 @param product 消息model
 @param completion 完成回调
 */
+ (void)createProductWithMerchantsEuid:(NSString *)euid
                               product:(UMCProduct *)product
                            completion:(void(^)(BOOL result))completion;

/**
 商户未读消息（传nil，获取所有未读消息总数）
 
 @param euid 商户ID
 @param completion 完成回调
 */
+ (void)merchantsUnreadCountWithEuid:(NSString *)euid
                          completion:(void(^)(NSInteger unreadCount))completion;

/**
 上传文件
 
 @param completion 完成回调
 */
+ (void)uploadFile:(NSData *)fieldData
          fileName:(NSString *)fileName
        completion:(void(^)(NSString *address, NSError *error))completion;

/**
 开始推送
 */
+ (void)startUdeskMChatPush;

/**
 结束推送
 */
+ (void)endUdeskMChatPush;

/**
 设置用户的设备唯一标识
 */
+ (void)registerDeviceToken:(id)deviceToken;

/** 断开链接（app进入后台时调用） */
+ (void)disconnect;

/** 链接（app进入前台时调用） */
+ (void)connect;

/** 进入聊天页面调用 */
+ (void)enterChatViewController;

/** 离开聊天页面调用 */
+ (void)leaveChatViewController;

/** 设置是否为开发环境（用于sdk开发测试，用户无需使用这个接口） */
+ (void)setIsDeveloper:(BOOL)isDeveloper;

@end
