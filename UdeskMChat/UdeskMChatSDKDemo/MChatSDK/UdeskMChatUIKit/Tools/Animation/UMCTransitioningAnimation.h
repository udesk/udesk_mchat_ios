//
//  UMCTransitioningAnimation.h
//  UdeskSDK
//
//  Created by Udesk on 16/7/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMCAnimatorPush.h"
#import "UMCShareTransitioningDelegateImpl.h"
#import "UMCSDKConfig.h"

@interface UMCTransitioningAnimation : NSObject

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl;

+ (CATransition *)createPresentingTransiteAnimation;

+ (CATransition *)createDismissingTransiteAnimation;

+ (void)setInteractive:(BOOL)interactive;

+ (BOOL)isInteractive;

+ (void)updateInteractiveTransition:(CGFloat)percent;

+ (void)cancelInteractiveTransition;

+ (void)finishInteractiveTransition;

@end
