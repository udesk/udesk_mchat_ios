//
//  NSDate+UMC.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (UMC)

- (NSString *)stringWithFormat:(NSString *)format;

- (NSString *)stringWithFormat:(NSString *)format
                      timeZone:(NSTimeZone *)timeZone
                        locale:(NSLocale *)locale;

+ (NSDate *)dateWithString:(NSString *)dateString format:(NSString *)format;

+ (NSDate *)dateWithString:(NSString *)dateString
                    format:(NSString *)format
                  timeZone:(NSTimeZone *)timeZone
                    locale:(NSLocale *)locale;

//多商户时间格式
- (NSString *)umcStyleDate;

@end
