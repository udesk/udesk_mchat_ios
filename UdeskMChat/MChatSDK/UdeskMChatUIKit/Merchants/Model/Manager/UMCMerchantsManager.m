//
//  UMCMerchantsManager.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCMerchantsManager.h"

@interface UMCMerchantsManager()

@property (nonatomic, strong, readwrite) NSArray *merchantsArray;

@end

@implementation UMCMerchantsManager

/** 获取商户列表 */
- (void)fetchMerchants:(void(^)(void))completion {
    
    [UMCManager getMerchants:^(NSArray<UMCMerchant *> *merchantsArray) {
        
        self.merchantsArray = merchantsArray;
        if (completion) {
            completion();
        }
    }];
}

/** 获取商户未读消息数 */
- (void)fetchMerchantUnreadCount:(NSString *)merchantEuid completion:(void (^)(NSInteger unreadCount))completion {
    
    [UMCManager merchantsUnreadCountWithEuid:merchantEuid completion:completion];
}

/** 标记商户消息为已读 */
- (void)readMerchantsWithEuid:(NSString *)euid
                   completion:(void(^)(BOOL result))completion {
    
    [UMCManager readMerchantsWithEuid:euid completion:completion];
}

/** 删除商户 */
- (void)deleteMerchantsWithModel:(UMCMerchant *)merchant
                      completion:(void(^)(BOOL result))completion {
    
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.merchantsArray];
    [UMCManager deleteMerchantsWithEuid:merchant.euid completion:^(BOOL result) {
        [array removeObject:merchant];
        self.merchantsArray = array;
        if (completion) {
            completion(result);
        }
    }];
}

/** 搜索商户 */
- (void)searchMerchants:(NSString *)text
             completion:(void(^)(NSArray *resultArray))completion {
    
    NSMutableArray *array = [NSMutableArray array];
    NSPredicate *pred = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"name LIKE '*%@*'",text]];
    [self.merchantsArray enumerateObjectsUsingBlock:^(UMCMerchant *merchant, NSUInteger idx, BOOL * _Nonnull stop) {
        BOOL result = [pred evaluateWithObject:merchant];
        if(result) {
            [array addObject:merchant];
        }
    }];
                 
    if(completion) {
        completion(array);
    }
}

@end
