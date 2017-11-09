//
//  NSString+UMC.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (UMC)

- (CGSize)umcSizeForFont:(UIFont *)font size:(CGSize)size mode:(NSLineBreakMode)lineBreakMode;

- (CGFloat)umcWidthForFont:(UIFont *)font;

- (CGFloat)umcHeightForFont:(UIFont *)font width:(CGFloat)width;

@end
