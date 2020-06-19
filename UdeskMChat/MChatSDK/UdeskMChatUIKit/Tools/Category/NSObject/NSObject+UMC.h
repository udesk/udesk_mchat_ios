//
//  NSObject+UMC.h
//  UdeskMChatSDKDemo
//
//  Created by xuchen on 2018/7/10.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (UMC)

- (NSDictionary *_Nullable)dictionaryFromModel;
- (id _Nullable )idFromObject:(nonnull id)object;

@end
