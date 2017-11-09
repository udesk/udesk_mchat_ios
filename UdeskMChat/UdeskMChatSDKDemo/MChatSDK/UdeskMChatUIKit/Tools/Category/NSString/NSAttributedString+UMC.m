//
//  NSAttributedString+UMC.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "NSAttributedString+UMC.h"
#import "UMCHelper.h"

@implementation NSAttributedString (UMC)

- (CGFloat)getHeightTextWidth:(CGFloat)textWidth
{
    if ([UMCHelper isBlankString:self.string]) {
        return 50;
    }
    
    CGSize constraint = CGSizeMake(textWidth , CGFLOAT_MAX);
    CGSize title_size;
    CGFloat totalHeight;
    title_size = [self boundingRectWithSize:constraint
                                              options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                              context:nil].size;
    
    totalHeight = ceil(title_size.height);
    
    return totalHeight;
}

- (CGSize)getSizeForTextWidth:(CGFloat)textWidth
{
    if ([UMCHelper isBlankString:self.string]) {
        return CGSizeMake(50, 50);
    }
    
    CGSize constraint = CGSizeMake(textWidth , CGFLOAT_MAX);
    
    CGRect stringRect = [self boundingRectWithSize:constraint
                                                     options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                     context:nil];
    
    stringRect.size.height = stringRect.size.height < 30 ? stringRect.size.height = 18 : stringRect.size.height;
    
    return CGRectIntegral(stringRect).size;
}

@end
