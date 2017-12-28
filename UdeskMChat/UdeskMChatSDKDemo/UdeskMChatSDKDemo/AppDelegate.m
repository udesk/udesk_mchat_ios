//
//  AppDelegate.m
//  UdeskMChatSDKDemo
//
//  Created by xuchen on 2017/11/9.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "AppDelegate.h"
#import <CommonCrypto/CommonDigest.h>
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import <Bugtags/Bugtags.h>

#import "JPUSHService.h"

static NSString *appKey = @"67a6e5b02715ef9f34e4222c";
static NSString *channel = @"Merchants";

//需要测试自己的账号，替换uuid和key即可
static NSString *UUID = @"c6042aa7-a1b2-4594-aed8-bf15b547627f";
static NSString *key = @"240858ffb00b1c814259a6569393bf4e";

static NSString *euid = @"xinlixuegang2";
static NSString *name = @"新李雪刚2";

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    [Bugtags startWithAppKey:@"e295aa1df3a7124c5e2929077ba37f95" invocationEvent:BTGInvocationEventNone];
    
    //客户端自己算签名，此方法仅用于开发测试。正式上线需要后端算好签名和时间戳返给前端
    UMCSystem *system = [UMCSystem new];
    
    NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
    NSString *sha1 = [NSString stringWithFormat:@"%@%@%.f",UUID,key,s];
    
    system.UUID = UUID;
    system.timestamp = [NSString stringWithFormat:@"%.f",s];
    system.sign = [self sha1:sha1];
    
    UMCCustomer *customer = [UMCCustomer new];
    //euid为客户ID，请保证唯一性，并且请勿传特殊字符。
    customer.euid = euid;
    customer.name = name;
    
    //初始化接口
    [UMCManager initWithSystem:system customer:customer completion:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
    
    //    注册推送通知
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        //可以添加自定义categories
        [JPUSHService registerForRemoteNotificationTypes:(UIUserNotificationTypeBadge |
                                                          UIUserNotificationTypeSound |
                                                          UIUserNotificationTypeAlert)
                                              categories:nil];
    }
    //如不需要使用IDFA，advertisingIdentifier 可为nil
    [JPUSHService setupWithOption:launchOptions appKey:appKey
                          channel:channel
                 apsForProduction:NO];
    
    return YES;
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

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [application setApplicationIconBadgeNumber:0];
    
    __block UIBackgroundTaskIdentifier background_task;
    //注册一个后台任务，告诉系统我们需要向系统借一些事件
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        
        //不管有没有完成，结束background_task任务
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        //根据需求 开启／关闭 通知
        [UMCManager startUdeskMChatPush];
    });
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    
    [UMCManager endUdeskMChatPush];
    [application setApplicationIconBadgeNumber:0];
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    
    NSLog(@"%@", [NSString stringWithFormat:@"Device Token: %@", deviceToken]);
    [JPUSHService registerDeviceToken:deviceToken];
    NSLog(@"%@",[JPUSHService registrationID]);
    
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        [UMCManager registerDeviceToken:[JPUSHService registrationID]];
        NSLog(@"%@",[JPUSHService registrationID]);
    }];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler: (void (^)(UIBackgroundFetchResult))completionHandler {
    [JPUSHService handleRemoteNotification:userInfo];
    //    NSLog(@"收到通知:%@", userInfo);
    [application setApplicationIconBadgeNumber:1];
    completionHandler(UIBackgroundFetchResultNewData);
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
