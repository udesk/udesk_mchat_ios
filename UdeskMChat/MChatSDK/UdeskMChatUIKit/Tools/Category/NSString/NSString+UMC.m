//
//  NSString+UMC.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "NSString+UMC.h"

@implementation NSString (UMC)

- (CGSize)umcSizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode {
    CGSize result;
    if (!font) font = [UIFont systemFontOfSize:12];
    if ([self respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        NSMutableDictionary *attr = [NSMutableDictionary new];
        attr[NSFontAttributeName] = font;
        if (lineBreakMode != NSLineBreakByWordWrapping) {
            NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
            paragraphStyle.lineBreakMode = lineBreakMode;
            attr[NSParagraphStyleAttributeName] = paragraphStyle;
        }
        CGRect rect = [self boundingRectWithSize:size
                                         options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attr context:nil];
        result = rect.size;
    } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        result = [self sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
#pragma clang diagnostic pop
    }
    return result;
}

- (CGFloat)umcWidthForFont:(UIFont *)font {
    CGSize size = [self umcSizeForFont:font size:CGSizeMake(HUGE, HUGE) mode:NSLineBreakByWordWrapping];
    return size.width;
}

- (CGFloat)umcHeightForFont:(UIFont *)font width:(CGFloat)width {
    CGSize size = [self umcSizeForFont:font size:CGSizeMake(width, HUGE) mode:NSLineBreakByWordWrapping];
    return size.height;
}

- (NSString *)umcLimitOmitLength:(int)limit
{
    int charLength = 0;
    int limitIndex = limit;
    char* p = (char*)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    NSInteger stringLength = [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0 ; i< stringLength; i++) {
        if (*p) {
            int a = p[0];
            if(a > 0x4e00 && a < 0x9fff) {
                charLength+=2;
            }
            charLength+=1;
            p++;
        }
        else {
            p++;
        }
        if (charLength >= limit -1) {
            limitIndex = i/2;
            break;
        }
    }
    
    if (limitIndex >= self.length - 1) {
        return self;
    }
    
    NSString *subString = [self substringToIndex:limitIndex];
    return [subString stringByAppendingString:@"..."];
}

@end
