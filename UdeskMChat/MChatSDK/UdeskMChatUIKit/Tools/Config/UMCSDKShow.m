//
//  UdeskSDKShow.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/26.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCSDKShow.h"
#import "UMCTransitioningAnimation.h"
#import "UMCIMViewController.h"
#import "UMCBundleHelper.h"
#import "NSString+UMC.h"
#import "UMCSDKConfig.h"

@interface UMCSDKShow()

@property (nonatomic, strong) UMCSDKConfig *sdkConfig;

@end

@implementation UMCSDKShow

- (instancetype)initWithConfig:(UMCSDKConfig *)sdkConfig
{
    self = [super init];
    if (self) {
        _sdkConfig = sdkConfig;
    }
    return self;
}

- (void)presentOnViewController:(UIViewController *)rootViewController
            udeskViewController:(id)udeskViewController
                     completion:(void (^)(void))completion {

    UIViewController *viewController = [self createNavigationControllerWithWithAnimationSupport:udeskViewController presentedViewController:rootViewController];
    BOOL shouldUseUIKitAnimation = [[[UIDevice currentDevice] systemVersion] floatValue] >= 7;
    
    if (kUMCSystemVersion >= 8.0) {
        //防止多次点击崩溃
        if (viewController.popoverPresentationController && !viewController.popoverPresentationController.sourceView) {
            return;
        }
    }
    
    if(![rootViewController.navigationController.topViewController isKindOfClass:[viewController class]]) {
        [rootViewController presentViewController:viewController animated:shouldUseUIKitAnimation completion:completion];
    }
}

- (UINavigationController *)createNavigationControllerWithWithAnimationSupport:(UIViewController *)rootViewController presentedViewController:(UIViewController *)presentedViewController{
    
    UINavigationController *navigationController = [[UINavigationController alloc]initWithRootViewController:rootViewController];
    [self updateNavAttributesWithViewController:rootViewController navigationController:(UINavigationController *)navigationController defaultNavigationController:rootViewController.navigationController isPresentModalView:true];
    [navigationController setTransitioningDelegate:[UMCTransitioningAnimation transitioningDelegateImpl]];
    [navigationController setModalPresentationStyle:UIModalPresentationCustom];
    
    return navigationController;
}

//修改导航栏属性
- (void)updateNavAttributesWithViewController:(UIViewController *)viewController
                         navigationController:(UINavigationController *)navigationController
                  defaultNavigationController:(UINavigationController *)defaultNavigationController
                           isPresentModalView:(BOOL)isPresentModalView {
    if (_sdkConfig.sdkStyle.navBackButtonColor) {
        navigationController.navigationBar.tintColor = _sdkConfig.sdkStyle.navBackButtonColor;
    } else if (defaultNavigationController && defaultNavigationController.navigationBar.tintColor) {
        navigationController.navigationBar.tintColor = defaultNavigationController.navigationBar.tintColor;
    }
    
    if (defaultNavigationController.navigationBar.titleTextAttributes) {
        navigationController.navigationBar.titleTextAttributes = defaultNavigationController.navigationBar.titleTextAttributes;
    } else {
        UIColor *color = _sdkConfig.sdkStyle.titleColor;
        UIFont *font = _sdkConfig.sdkStyle.titleFont;
        NSDictionary *attr = @{NSForegroundColorAttributeName : color, NSFontAttributeName : font};
        navigationController.navigationBar.titleTextAttributes = attr;
    }
    
    if (_sdkConfig.sdkStyle.navBarBackgroundImage) {
        [navigationController.navigationBar setBackgroundImage:_sdkConfig.sdkStyle.navBarBackgroundImage forBarMetrics:UIBarMetricsDefault];
    } else {
        if (_sdkConfig.sdkStyle.navigationColor) {
            navigationController.navigationBar.barTintColor = _sdkConfig.sdkStyle.navigationColor;
        }
    }
    
    //导航栏左键
    UIBarButtonItem *customizedBackItem = [[UIBarButtonItem alloc] initWithImage:_sdkConfig.sdkStyle.navBackButtonImage style:UIBarButtonItemStylePlain target:viewController action:@selector(dismissChatViewController)];
    
    UIBarButtonItem *otherNavigationItem;
    if (_sdkConfig.navBackButtonTitle) {
     
        NSString *backText = _sdkConfig.navBackButtonTitle;
        UIImage *backImage = [UIImage umcDefaultBackImage];
        CGSize backTextSize = [backText umcSizeForFont:[UIFont systemFontOfSize:17] size:CGSizeMake(70, 30) mode:NSLineBreakByTruncatingTail];
        
        UIButton *leftBarButton = [UIButton buttonWithType:UIButtonTypeCustom];
        leftBarButton.frame = CGRectMake(0, 0, backTextSize.width+backImage.size.width+20, backTextSize.height);
        [leftBarButton setTitle:backText forState:UIControlStateNormal];
        backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [leftBarButton setTintColor:_sdkConfig.sdkStyle.navBackButtonColor];
        [leftBarButton setImage:backImage forState:UIControlStateNormal];
        [leftBarButton setTitleColor:_sdkConfig.sdkStyle.navBackButtonColor forState:UIControlStateNormal];
        [leftBarButton addTarget:viewController action:@selector(dismissChatViewController) forControlEvents:UIControlEventTouchUpInside];
        
        [leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 8, 0, 0)];
        
        if (kUMCSystemVersion >= 11.0) {
            leftBarButton.contentHorizontalAlignment =UIControlContentHorizontalAlignmentLeft;
            [leftBarButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5 * kUMCScreenWidth/375.0,0,0)];
            [leftBarButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -2 * kUMCScreenWidth/375.0,0,0)];
        }
        
        otherNavigationItem = [[UIBarButtonItem alloc] initWithCustomView:leftBarButton];
    }
    
    viewController.navigationItem.leftBarButtonItem = otherNavigationItem ?: customizedBackItem;
    
    if ([viewController isKindOfClass:[UMCIMViewController class]]) {
        
        //导航栏标题
        if (_sdkConfig.imTitle) {
            viewController.navigationItem.title = _sdkConfig.imTitle;
        }
    }
}

@end
