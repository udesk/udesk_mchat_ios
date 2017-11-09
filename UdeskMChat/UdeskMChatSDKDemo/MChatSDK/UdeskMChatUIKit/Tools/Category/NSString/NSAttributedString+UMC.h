//
//  NSAttributedString+UMC.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/23.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSAttributedString (UMC)

- (CGFloat)getHeightTextWidth:(CGFloat)textWidth;

- (CGSize)getSizeForTextWidth:(CGFloat)textWidth;

@end
