//
//  UMCDemoHomeViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCDemoHomeViewController.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"
#import "UMCDemoMessageViewController.h"
#import<CommonCrypto/CommonDigest.h>

@interface UMCDemoHomeViewController ()

@end

@implementation UMCDemoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UMCManager merchantsUnreadCountWithEuid:nil completion:^(NSInteger unreadCount) {
        
        UINavigationController *nav = self.tabBarController.viewControllers[1];
        if (unreadCount == 0) {
            nav.tabBarItem.badgeValue = nil;
        }
        else {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",unreadCount];
        }
    }];

    [UMCSDKConfig sharedConfig].unreadCountDidChange = ^(BOOL isPlus, NSString *count) {
        
        UINavigationController *nav = self.tabBarController.viewControllers[1];
        if (isPlus) {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",nav.tabBarItem.badgeValue.integerValue + count.integerValue];
        }
        else {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",nav.tabBarItem.badgeValue.integerValue - count.integerValue];
            if (nav.tabBarItem.badgeValue.integerValue - count.integerValue == 0) {
                nav.tabBarItem.badgeValue = nil;
            }
        }
    };
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
