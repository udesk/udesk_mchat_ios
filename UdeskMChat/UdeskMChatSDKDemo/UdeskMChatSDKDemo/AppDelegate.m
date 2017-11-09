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

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    UMCSystem *system = [UMCSystem new];
    
    NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
    
    NSString *sha1 = [NSString stringWithFormat:@"c6042aa7-a1b2-4594-aed8-bf15b547627f240858ffb00b1c814259a6569393bf4e%.f",s];
    
    system.UUID = @"c6042aa7-a1b2-4594-aed8-bf15b547627f";
    system.timestamp = [NSString stringWithFormat:@"%.f",s];
    system.sign = [self sha1:sha1];;
    
    UMCCustomer *customer = [UMCCustomer new];
    customer.euid = @"12122123312313313dsdasd";
    customer.name = @"李林签";
    
    [UMCManager initWithSystem:system customer:customer completion:^(NSError *error) {
        NSLog(@"%@",error);
    }];
    
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
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
