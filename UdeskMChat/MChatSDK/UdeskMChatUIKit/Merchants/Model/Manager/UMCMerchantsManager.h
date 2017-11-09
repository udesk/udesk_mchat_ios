//
//  UMCMerchantsManager.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UdeskMChatSDK/UdeskMChatSDK.h>

@interface UMCMerchantsManager : NSObject

@property (nonatomic, strong, readonly) NSArray *merchantsArray;

/** 获取商户列表 */
- (void)fetchMerchants:(void(^)(void))completion;

/** 标记商户消息为已读 */
- (void)readMerchantsWithEuid:(NSString *)euid
                   completion:(void(^)(BOOL result))completion;

/** 删除商户 */
- (void)deleteMerchantsWithModel:(UMCMerchant *)merchant
                      completion:(void(^)(BOOL result))completion;

/** 搜索商户 */
- (void)searchMerchants:(NSString *)text
             completion:(void(^)(NSArray *resultArray))completion;


@end
