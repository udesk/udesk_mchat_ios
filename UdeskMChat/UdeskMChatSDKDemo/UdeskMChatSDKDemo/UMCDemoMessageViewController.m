//
//  UMCDemoMessageViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCDemoMessageViewController.h"
#import "UdeskMChatUIKit.h"

@interface UMCDemoMessageViewController ()

@end

@implementation UMCDemoMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //商户列表
    UMCMerchantsView *merchats = [[UMCMerchantsView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height) sdkConfig:[self getConfig]];
    [self.view addSubview:merchats];
}

- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    
    UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
    config.sdkStyle = styly;
    
    return config;
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
