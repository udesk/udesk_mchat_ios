//
//  UMCTransitioningAnimation.h
//  UdeskSDK
//
//  Created by Udesk on 16/7/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCTransitioningAnimation.h"

@interface UMCTransitioningAnimation()

@property (nonatomic, strong) UMCShareTransitioningDelegateImpl <UIViewControllerTransitioningDelegate> * transitioningDelegateImpl;

@end


@implementation UMCTransitioningAnimation

+ (instancetype)sharedInstance {
    static UMCTransitioningAnimation *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [UMCTransitioningAnimation new];
    });
    
    return instance;
}

- (instancetype)init {
    
    if (self = [super init]) {
        self.transitioningDelegateImpl = [UMCShareTransitioningDelegateImpl new];
    }
    return self;
}

+ (void)setInteractive:(BOOL)interactive {
    [UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive = interactive;
}

+ (BOOL)isInteractive {
    return [UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactive;
}

+ (id <UIViewControllerTransitioningDelegate>)transitioningDelegateImpl {
    return [[self sharedInstance] transitioningDelegateImpl];
}

+ (void)updateInteractiveTransition:(CGFloat)percent {
    [[UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning updateInteractiveTransition:percent];
}

+ (void)cancelInteractiveTransition {
    [[UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning cancelInteractiveTransition];
    [UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning = nil;
}

+ (void)finishInteractiveTransition {
    [[UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl.interactiveTransitioning finishInteractiveTransition];
    [[UMCTransitioningAnimation sharedInstance].transitioningDelegateImpl finishTransition];
}

#pragma mark -

+ (CATransition *)createPresentingTransiteAnimation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromRight;
    
    return transition;
}
+ (CATransition *)createDismissingTransiteAnimation {
    CATransition *transition = [CATransition animation];
    transition.duration = 0.5;
    [transition setFillMode:kCAFillModeBoth];
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = kCATransitionMoveIn;
    transition.subtype = kCATransitionFromLeft;
    
    return transition;
}

@end
