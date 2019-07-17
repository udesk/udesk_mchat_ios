//
//  UMCSessionListViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCSessionListViewController.h"
#import "UdeskMChatUIKit.h"
#import "UMCUIMacro.h"

@interface UMCSessionListViewController ()

@end

@implementation UMCSessionListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat spacing = 0;
    if (kUMCIPhoneXSeries) {
        spacing = 24;
    }
    UMCMerchantsView *merchats = [[UMCMerchantsView alloc] initWithFrame:CGRectMake(0, 64+spacing, self.view.frame.size.width, self.view.frame.size.height) sdkConfig:[self getConfig]];
    [self.view addSubview:merchats];
}

- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    config.customButtons = self.customButtons;
    config.showCustomButtons = YES;
    
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
