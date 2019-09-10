//
//  UMCSettingViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/12/21.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCSettingViewController.h"
#import "UMCSessionListViewController.h"
#import "UMCDeveloperViewController.h"

#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"

@interface UMCSettingViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation UMCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellIdentifier"];
    self.dataSource = @[
                        @"咨询客服",
                        @"会话列表",
                        @"其他功能",
                        ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"商户euid" message:@"请输入商户euid" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alert.textFields.firstObject;
            if (textField.text.length) {
                
                UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithMerchantId:textField.text];
                sdkManager.sdkConfig = [self getConfig];
                [sdkManager pushUdeskInViewController:self completion:nil];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入商户euid" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else if (indexPath.row == 1) {
        
        UMCSessionListViewController *sessionListVC = [[UMCSessionListViewController alloc] init];
        [self.navigationController pushViewController:sessionListVC animated:YES];
    }
    else if (indexPath.row == 2) {
        
        UMCDeveloperViewController *developerVC = [[UMCDeveloperViewController alloc] init];
        [self.navigationController pushViewController:developerVC animated:YES];
    }
}

- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    
#warning 这里写死了单个商品的咨询对象，实际开发中可根据需求自定义
    UMCProduct *product = [[UMCProduct alloc] init];
    product.title = @"iPhone XiPhone XiPhone XXiPhone X";
    product.image = @"https://g-search3.alicdn.com/img/bao/uploaded/i4/i3/1917047079/TB1IfFybl_85uJjSZPfXXcp0FXa_!!0-item_pic.jpg_460x460Q90.jpg";
    product.url = @"http://www.apple.com/cn";
    
    UMCProductExtras *extras = [[UMCProductExtras alloc] init];
    extras.title = @"标题";
    extras.content = @"¥9999¥9999¥9999¥9999¥999999999999";
    
    product.extras = @[extras];
    
    config.product = product;
    
    UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
    config.sdkStyle = styly;
    
    return config;
}

@end
