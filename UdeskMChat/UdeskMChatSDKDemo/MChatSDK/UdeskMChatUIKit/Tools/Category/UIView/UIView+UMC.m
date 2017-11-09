//
//  UIView+UMC.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UIView+UMC.h"

@implementation UIView (UMC)

- (UIViewController *)viewController {
    for (UIView *view = self; view; view = view.superview) {
        UIResponder *nextResponder = [view nextResponder];
        if ([nextResponder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)nextResponder;
        }
    }
    return nil;
}

- (CGFloat)umcLeft {
    return self.frame.origin.x;
}

- (void)setUmcLeft:(CGFloat)umcLeft {
    CGRect frame = self.frame;
    frame.origin.x = umcLeft;
    self.frame = frame;
}

- (CGFloat)umcTop {
    return self.frame.origin.y;
}

- (void)setUmcTop:(CGFloat)umcTop {
    CGRect frame = self.frame;
    frame.origin.y = umcTop;
    self.frame = frame;
}

- (CGFloat)umcRight {
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setUmcRight:(CGFloat)umcRight {
    CGRect frame = self.frame;
    frame.origin.x = umcRight - frame.size.width;
    self.frame = frame;
}

- (CGFloat)umcBottom {
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setUmcBottom:(CGFloat)umcBottom {
    CGRect frame = self.frame;
    frame.origin.y = umcBottom - frame.size.height;
    self.frame = frame;
}

- (CGFloat)umcWidth {
    return self.frame.size.width;
}

- (void)setUmcWidth:(CGFloat)umcWidth {
    CGRect frame = self.frame;
    frame.size.width = umcWidth;
    self.frame = frame;
}

- (CGFloat)umcHeight {
    return self.frame.size.height;
}

- (void)setUmcHeight:(CGFloat)umcHeight {
    CGRect frame = self.frame;
    frame.size.height = umcHeight;
    self.frame = frame;
}

- (CGFloat)umcCenterX {
    return self.center.x;
}

- (void)setUmcCenterX:(CGFloat)umcCenterX {
    self.center = CGPointMake(umcCenterX, self.center.y);
}

- (CGFloat)umcCenterY {
    return self.center.y;
}

- (void)setUmcCenterY:(CGFloat)umcCenterY {
    self.center = CGPointMake(self.center.x, umcCenterY);
}

- (CGPoint)umcOrigin {
    return self.frame.origin;
}

- (void)setUmcOrigin:(CGPoint)umcOrigin {
    CGRect frame = self.frame;
    frame.origin = umcOrigin;
    self.frame = frame;
}

- (CGSize)umcSize {
    return self.frame.size;
}

- (void)setUmcSize:(CGSize)umcSize {
    CGRect frame = self.frame;
    frame.size = umcSize;
    self.frame = frame;
}

@end
