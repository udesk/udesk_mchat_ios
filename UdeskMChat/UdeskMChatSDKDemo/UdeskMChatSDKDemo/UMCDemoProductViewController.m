//
//  UMCDemoProductViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/28.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCDemoProductViewController.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"

@interface UMCDemoProductViewController ()

@end

@implementation UMCDemoProductViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)showChatViewControllerAction:(id)sender {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"请输入商户ID" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        
    }];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *textField = alert.textFields.firstObject;
        
        if (textField.text.length) {
            
            //直接进入im咨询
            UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithSDKConfig:[self getConfig] merchantId:textField.text];
            [sdkManager pushUdeskInViewController:self completion:nil];
        }
        else {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入ID" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
            [alertView show];
        }
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    
#warning 这里写死了单个商品的咨询对象，实际开发中可根据需求自定义
    UMCProduct *product = [[UMCProduct alloc] init];
    product.title = @"iPhone X";
    product.image = @"https://g-search3.alicdn.com/img/bao/uploaded/i4/i3/1917047079/TB1IfFybl_85uJjSZPfXXcp0FXa_!!0-item_pic.jpg_460x460Q90.jpg";
    product.url = @"http://www.apple.com/cn";
    
    UMCProductExtras *extras = [[UMCProductExtras alloc] init];
    extras.title = @"标题";
    extras.content = @"¥9999";
    
    product.extras = @[extras];
    
    config.product = product;
    
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
