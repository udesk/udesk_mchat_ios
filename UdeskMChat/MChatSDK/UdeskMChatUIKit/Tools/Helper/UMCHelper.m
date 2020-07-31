//
//  UMCHelper.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCHelper.h"
#import "UdeskReachability.h"

@implementation UMCHelper

//字符串转字典
+ (id)dictionaryWithJSON:(NSString *)json {
    if (json == nil) {
        return nil;
    }
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err) {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

//字典转字符串
+ (NSString *)JSONWithDictionary:(NSDictionary *)dictionary {
    if (!dictionary || dictionary == (id)kCFNull) return @"";
    if (![dictionary isKindOfClass:[NSDictionary class]]) return @"";
    
    @try {
        
        NSError *error;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:0 error:&error];
        
        NSString *jsonString;
        
        if (!jsonData) {
            NSLog(@"UdeskSDK：%@",error);
        } else{
            jsonString = [[NSString alloc]initWithData:jsonData encoding:NSUTF8StringEncoding];
        }
        
        NSMutableString *mutStr = [NSMutableString stringWithString:jsonString];
        
        NSRange range = {0,jsonString.length};
        
        //去掉字符串中的空格
        [mutStr replaceOccurrencesOfString:@" " withString:@"" options:NSLiteralSearch range:range];
        
        NSRange range2 = {0,mutStr.length};
        
        //去掉字符串中的换行符
        [mutStr replaceOccurrencesOfString:@"\n" withString:@"" options:NSLiteralSearch range:range2];
        
        return mutStr;
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

+ (UIViewController *)currentViewController
{
    UIWindow *keyWindow  = [UIApplication sharedApplication].keyWindow;
    UIViewController *vc = keyWindow.rootViewController;
    while (vc.presentedViewController)
    {
        vc = vc.presentedViewController;
        
        if ([vc isKindOfClass:[UINavigationController class]])
        {
            vc = [(UINavigationController *)vc visibleViewController];
        }
        else if ([vc isKindOfClass:[UITabBarController class]])
        {
            vc = [(UITabBarController *)vc selectedViewController];
        }
    }
    
    return vc;
}

//判断字符串是否为空
+ (BOOL)isBlankString:(NSString *)string {
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    
    if ([string isKindOfClass:[NSNull class]]) {
        return YES;
    }
    
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

//随机生成唯一标示
+ (NSString *)soleString {
    
    CFUUIDRef identifier = CFUUIDCreate(NULL);
    NSString* identifierString = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, identifier));
    CFRelease(identifier);
    
    return identifierString;
}

+ (BOOL)stringContainsEmoji:(NSString *)string
{
    @try {
        
        __block BOOL returnValue = NO;
        
        [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                                   options:NSStringEnumerationByComposedCharacterSequences
                                usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                    const unichar hs = [substring characterAtIndex:0];
                                    if (0xd800 <= hs && hs <= 0xdbff) {
                                        if (substring.length > 1) {
                                            const unichar ls = [substring characterAtIndex:1];
                                            const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                            if (0x1d000 <= uc && uc <= 0x1f77f) {
                                                returnValue = YES;
                                            }
                                        }
                                    } else if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        if (ls == 0x20e3) {
                                            returnValue = YES;
                                        }
                                    } else {
                                        if (0x2100 <= hs && hs <= 0x27ff) {
                                            returnValue = YES;
                                        } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                            returnValue = YES;
                                        } else if (0x2934 <= hs && hs <= 0x2935) {
                                            returnValue = YES;
                                        } else if (0x3297 <= hs && hs <= 0x3299) {
                                            returnValue = YES;
                                        } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                            returnValue = YES;
                                        }
                                    }
                                }];
        
        return returnValue;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

// 计算图片实际大小
+ (CGSize)neededSizeForPhoto:(UIImage *)image {
    
    @try {
        
        CGFloat fixedSize;
        if ([[UIScreen mainScreen] bounds].size.width>320) {
            fixedSize = 140;
        }
        else {
            fixedSize = 115;
        }
        
        CGSize imageSize = CGSizeMake(fixedSize, fixedSize);
        
        if (image.size.height > image.size.width) {
            
            CGFloat scale = image.size.height/fixedSize;
            if (scale!=0) {
                
                CGFloat newWidth = (image.size.width)/scale;
                
                imageSize = CGSizeMake(newWidth<60.0f?60:newWidth, fixedSize);
            }
            
        }
        else if (image.size.height < image.size.width) {
            
            CGFloat scale = image.size.width/fixedSize;
            
            if (scale!=0) {
                
                CGFloat newHeight = (image.size.height)/scale;
                imageSize = CGSizeMake(fixedSize, newHeight);
            }
            
        }
        else if (image.size.height == image.size.width) {
            
            imageSize = CGSizeMake(fixedSize, fixedSize);
        }
        
        // 这里需要缩放后的size
        return imageSize;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//判断是否为整形：
+ (BOOL)isPureInt:(NSString *)string {
    
    if ([self isBlankString:string]) {
        return NO;
    }
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形：
+ (BOOL)isPureFloat:(NSString *)string {
    
    if ([self isBlankString:string]) {
        return NO;
    }
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return[scan scanFloat:&val] && [scan isAtEnd];
}

//过滤html
+ (NSString *)filterHTML:(NSString *)html {
    NSScanner * scanner = [NSScanner scannerWithString:html];
    NSString * text = nil;
    while([scanner isAtEnd]==NO)
    {
        //找到标签的起始位置
        [scanner scanUpToString:@"<" intoString:nil];
        //找到标签的结束位置
        [scanner scanUpToString:@">" intoString:&text];
        //替换字符
        html = [html stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@>",text] withString:@""];
    }
    //    NSString * regEx = @"<([^>]*)>";
    //    html = [html stringByReplacingOccurrencesOfString:regEx withString:@""];
    return html;
}

//同步获取网络状态
+ (NSString *)internetStatus {
    
    UdeskReachability *reachability   = [UdeskReachability reachabilityWithHostName:@"www.baidu.com"];
    UDNetworkStatus internetStatus = [reachability currentReachabilityStatus];
    
    NSString *net = nil;
    switch (internetStatus) {
        case UDReachableViaWiFi:
            net = @"wifi";
            break;
            
        case UDReachableViaWWAN:
            net = @"WWAN";
            break;
            
        case UDNotReachable:
            net = @"notReachable";
            
        default:
            break;
    }
    
    return net;
}

+ (NSArray *)linkRegexs {
    
    return @[@"((http[s]{0,1}|ftp)://[a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)|([a-zA-Z0-9\\.\\-]+\\.([a-zA-Z]{2,4})(:\\d+)?(/[a-zA-Z0-9\\.\\-~!@#$%^&*+?:_/=<>]*)?)",
             @"^[hH][tT][tT][pP]([sS]?):\\/\\/(\\S+\\.)+\\S{2,}$"];
}

+ (NSRange)linkRegexsMatch:(NSString *)content {
    
    NSArray *numberRegexs = [UMCHelper linkRegexs];
    // 数字正则匹配
    for (NSString *numberRegex in numberRegexs) {
        NSRange range = [content rangeOfString:numberRegex options:NSRegularExpressionSearch];
        if (range.location != NSNotFound) {
            return range;
        }
    }
    
    return NSMakeRange(NSNotFound, 0);
}

@end
