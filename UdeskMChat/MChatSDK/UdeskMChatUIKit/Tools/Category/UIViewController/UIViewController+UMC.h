//
//  UIViewController+UMC.h
//  UdeskSDK
//
//  Created by Udesk on 18/8/1.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (UMC)

//键盘监听
typedef void(^UDAnimationsWithKeyboardBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);
typedef void(^UDBeforeAnimationsWithKeyboardBlock)(CGRect keyboardRect, NSTimeInterval duration, BOOL isShowing);
typedef void(^UDCompletionKeyboardAnimations)(BOOL finished);

- (void)udSubscribeKeyboardWithAnimations:(UDAnimationsWithKeyboardBlock)animations
                                completion:(UDCompletionKeyboardAnimations)completion;

- (void)udSubscribeKeyboardWithBeforeAnimations:(UDBeforeAnimationsWithKeyboardBlock)beforeAnimations
                                      animations:(UDAnimationsWithKeyboardBlock)animations
                                completion:(UDCompletionKeyboardAnimations)completion;

- (void)udUnsubscribeKeyboard;

@end
