//
//  UMCHelper.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UMCHelper : NSObject

//判断是否为整形：
+ (BOOL)isPureInt:(NSString *)string;
//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString *)string;
//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)str;
//随机生成唯一字符串
+ (NSString *)soleString;
//是否为标签
+ (BOOL)stringContainsEmoji:(NSString *)string;
//字符串转字典
+ (id)dictionaryWithJSON:(NSString *)json;
//字典转字符串
+ (NSString *)JSONWithDictionary:(NSDictionary *)dictionary;
// 计算图片实际大小
+ (CGSize)neededSizeForPhoto:(UIImage *)image;
//当前控制器
+ (UIViewController *)currentViewController;
//过滤html
+ (NSString *)filterHTML:(NSString *)html;
//同步获取网络状态
+ (NSString *)internetStatus;
//链接正则
+ (NSRange)linkRegexsMatch:(NSString *)content;

@end
