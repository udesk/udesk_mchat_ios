//
//  UMCHomeViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCHomeViewController.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"
#import "UMCSessionListViewController.h"
#import <CommonCrypto/CommonDigest.h>

static NSString *const uuid = @"c6042aa7-a1b2-4594-aed8-bf15b547627f";
static NSString *const key = @"240858ffb00b1c814259a6569393bf4e";

//static NSString *const uuid = @"0ad5f61a-3769-4d32-87fc-4ce562d2677a";
//static NSString *const key = @"8d99703ffa2b06cd2609aa3c20be7128";

//product
//static NSString *const uuid = @"63922389-ae73-4368-a610-8da6b0c7796b";
//static NSString *const key = @"2819bef099b158d46c6a71903ad7c963";

static NSString *euid = @"testMchatEuid1111";
static NSString *name = @"testMchatName1111";


@interface UMCHomeViewController ()<UMCMessageDelegate>

@end

@implementation UMCHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [UMCManager setIsDeveloper:NO];
    UMCSystem *system = [UMCSystem new];
    
    NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
    
    NSString *sha1 = [NSString stringWithFormat:@"%@%@%.f",uuid,key,s];
    
    system.UUID = uuid;
    system.timestamp = [NSString stringWithFormat:@"%.f",s];
    system.sign = [self sha1:sha1];
    
    UMCCustomer *customer = [UMCCustomer new];
    customer.euid = euid;
    customer.name = name;
    
    [UMCManager initWithSystem:system customer:customer completion:^(NSError *error) {
        
        [UMCManager merchantsUnreadCountWithEuid:nil completion:^(NSInteger unreadCount) {
            
            UINavigationController *nav = self.tabBarController.viewControllers[1];
            if (unreadCount == 0) {
                nav.tabBarItem.badgeValue = nil;
            }
            else {
                nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",unreadCount];
            }
        }];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgChange:) name:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil];
    
    [[UMCDelegate shareInstance] addDelegate:self];
}

- (void)msgChange:(NSNotification *)notif {
    [UMCManager merchantsUnreadCountWithEuid:nil completion:^(NSInteger unreadCount) {
        
        UINavigationController *nav = self.tabBarController.viewControllers[1];
        nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",unreadCount];
        if (unreadCount == 0) {
            nav.tabBarItem.badgeValue = nil;
        }
    }];
}

- (NSString *) sha1:(NSString *)input
{
    
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

- (void)didReceiveMessage:(UMCMessage *)message {
    
    NSLog(@"收到：%@",message.content);
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
