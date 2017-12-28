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
#import <CommonCrypto/CommonDigest.h>

@interface UMCDemoHomeViewController ()<UMCMessageDelegate>

@end

@implementation UMCDemoHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //获取未读消息
    [UMCManager merchantsUnreadCountWithEuid:nil completion:^(NSInteger unreadCount) {
        
        UINavigationController *nav = self.tabBarController.viewControllers[1];
        if (unreadCount == 0) {
            nav.tabBarItem.badgeValue = nil;
        }
        else {
            nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",unreadCount];
        }
    }];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgUnreadCountHasChange:) name:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil];
    
    [[UMCDelegate shareInstance] addDelegate:self];
}

- (void)msgUnreadCountHasChange:(NSNotification *)notif {
    [UMCManager merchantsUnreadCountWithEuid:nil completion:^(NSInteger unreadCount) {
        
        UINavigationController *nav = self.tabBarController.viewControllers[1];
        nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",unreadCount];
        if (unreadCount == 0) {
            nav.tabBarItem.badgeValue = nil;
        }
    }];
}

- (void)didReceiveMessage:(UMCMessage *)message {
    NSLog(@"1111111:%@",message.content);
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
