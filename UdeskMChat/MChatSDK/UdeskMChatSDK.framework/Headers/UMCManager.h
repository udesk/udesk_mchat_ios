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

/** 当未读消息发生改变时会发送通知 */
#define UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION @"UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION"
/** 登录成功 */
#define UMC_LOGIN_SUCCESS_NOTIFICATION @"UMC_LOGIN_SUCCESS_NOTIFICATION"

@interface UMCManager : NSObject

/**
 初始化方法 （建议在application:didFinishLaunchingWithOptions: 方法里调用）

 @param system 多商户系统信息
 @param customer 客户信息
 @param completion 完成回调，回调成功error为nil
 */
+ (void)initWithSystem:(UMCSystem *)system customer:(UMCCustomer *)customer completion:(void(^)(NSError *error))completion;

/// 创建用户
/// @param euid 商户euid
/// @param completion 完成回调，回调成功error为nil
+ (void)createCustomerWithMerchantEuid:(NSString *)euid completion:(void(^)(NSError *error))completion;

/**
 获取所有商户

 @param completion 完成回调
 */
+ (void)getMerchants:(void(^)(NSArray<UMCMerchant *> *merchantsArray))completion;

/**
 获取单个商户信息

 @param merchantEuid 商户ID
 @param completion 完成回调
 */
+ (void)getMerchantWithMerchantEuid:(NSString *)merchantEuid
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
                                menuId:(NSString *)menuId
                               message:(UMCMessage *)message
                            completion:(void(^)(UMCMessage *message))completion;

/**
 创建咨询对象
 
 @param euid 商户ID
 @param product 消息model
 @param completion 完成回调
 */
+ (void)createProductWithMerchantsEuid:(NSString *)euid
                                menuId:(NSString *)menuId
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
          progress:(void(^)(float percent))progress
        completion:(void(^)(NSString *address, NSError *error))completion;

/**
 *  获取满意度调查选项
 *
 *  @param completion 回调选项内容
 */
+ (void)getSurveyOptionsWithMerchantEuid:(NSString *)merchantEuid
                              completion:(void (^)(id responseObject, NSError *error))completion
                            configHandle:(void (^)(BOOL surveyEnabled,BOOL afterSession))configHandle;


/**
 提交满意度
 
 @param merchantEuid 商户id
 @param parameters 满意度参数
 @param completion 回调
 */
+ (void)submitSurveyWithMerchantEuid:(NSString *)merchantEuid
                          parameters:(NSDictionary *)parameters
                          completion:(void(^)(NSError *error))completion;

/**
 *  检查是否已经提交过满意度
 *
 *  @param merchantEuid    满意度调查的客服
 *  @param completion 回调结果
 */
+ (void)checkHasSurveyWithMerchantEuid:(NSString *)merchantEuid
                            completion:(void (^)(NSString *hasSurvey,NSError *error))completion;

/// 获取导航栏
/// @param merchantEuid 商户Euid
/// @param completion 回调
+ (void)getNavigatesWithMerchantEuid:(NSString *)merchantEuid
                          completion:(void (^)(NSString *navDescribe, NSArray<UMCNavigate *> *navigatesArray))completion;


/// 获取留言配置
/// @param merchantEuid 商户Euid
/// @param completion 回调
+ (void)fetchFeedbacksWithMerchantEuid:(NSString *)merchantEuid
                            completion:(void (^)(NSString *feedbacksURL))completion;

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

/** 更新客户在线状态排队放弃用 */
+ (void)updateCustomerStatusInQueueWithMerchantEuid:(NSString *)merchantEuid
                                        completion:(void (^)(NSError *error))completion;

/// 存储消息到本地
/// @param message 消息
+ (void)storeMessage:(UMCMessage *)message;

/// sdk版本
+ (NSString *)sdkVersion;

@end
