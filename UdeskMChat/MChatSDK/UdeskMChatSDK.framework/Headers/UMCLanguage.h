//
//  UMCLanguageSetting.h
//  UdeskMChatSDK
//
//  Created by 陈历 on 2020/3/10.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface UMCLanguage : NSObject

/*
 英语 en-us
 泰语 th
 西班牙语 es
 印尼语 id
 日语 ja
 汉语 zh-CN
 葡萄牙语 pt
 俄语 ru
 繁体 zh-HK
 法语 fr
 */

/*
 注意事项
 1. 不设置默认为zh-CN
 */
@property (nonatomic, strong) NSString *language;

/*
 注意事项：
 1. customBundle为用户自定义多语言bundle，注意，这个指的是整个bundle包（比如udCustomBundle.bundle）
 2. 在udCustomBundle.bundle中包含各种语言。程序优先从这里面找，找不到再去Udesk默认的UdeskMChatBundle中找
 具体逻辑在UMCLanguageTool.m中，用户可以修改逻辑
 3. 在Udesk默认的UdeskMChatBundle中，因为历史原因，zh-cn对应zh-Hans.lproj, en-us对应en.lproj. 在用户自己
 的udCustomBundle.bundle中，名称需要与language对应，比如zh-CN必须为zh-CN.lproj,en-us必须为en-us.lproj
 4. 一般来说，udCustomBundle.bundle由集成者纳入git中管理，并且关注key值的变化。Demo中有使用方法，可参考
 */
@property (nonatomic,strong) NSBundle *customBundle;

+ (instancetype)sharedInstance;


@end

NS_ASSUME_NONNULL_END
