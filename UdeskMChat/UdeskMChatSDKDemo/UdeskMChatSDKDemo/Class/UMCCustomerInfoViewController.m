//
//  UMCCustomerInfoViewController.m
//  UdeskMChat
//
//  Created by xuchen on 2020/8/10.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCCustomerInfoViewController.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"

#import "MBProgressHUD.h"
#import <CommonCrypto/CommonDigest.h>

@interface UMCCustomerInfoViewController ()

@property (nonatomic, strong) NSMutableArray *customerInfo;
@property (nonatomic, strong) NSMutableArray *customeField;
@property (nonatomic, strong) UMCCustomer *customerModel;
@property (nonatomic, strong) NSString *uuid;
@property (nonatomic, strong) NSString *key;

@property (nonatomic, assign) BOOL selectCustomFieldType;

@end

@implementation UMCCustomerInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    UIBarButtonItem *customField = [[UIBarButtonItem alloc] initWithTitle:@"新增字段" style:UIBarButtonItemStylePlain target:self action:@selector(addCustomField)];
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(pushUdeskSDK)];
    
    self.navigationItem.rightBarButtonItems = @[done,customField];
}

- (void)addCustomField {
    
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"请选择自定义字段类型" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //ipad适配
        [sheet setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [sheet popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [sheet addAction:[UIAlertAction actionWithTitle:@"选择性字段" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.selectCustomFieldType = YES;
        [self inputCustomField];
    }]];
    
    [sheet addAction:[UIAlertAction actionWithTitle:@"文本字段" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self.selectCustomFieldType = NO;
        [self inputCustomField];
    }]];
    
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)inputCustomField {
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入自定义字段" preferredStyle:1];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UITextField *key = alert.textFields.firstObject;
        UITextField *value = alert.textFields.lastObject;
        if (key.text.length == 0) {
            [self showTextMessage:key.placeholder];
            return;
        }
        if (value.text.length == 0) {
            [self showTextMessage:value.placeholder];
            return;
        }
        
        if (self.selectCustomFieldType) {
            [self.customeField addObject:@{key.text:@[@(value.text.integerValue)]}];
        }
        else {
            [self.customeField addObject:@{key.text:value.text}];
        }
        
        [self updateCustomerField];
        [self.tableView reloadData];
    }]];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"自定义字段的key";
    }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"自定义字段的value";
    }];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateCustomerField {
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    for (NSDictionary *fieldDic in self.customeField) {
        [dict addEntriesFromDictionary:fieldDic];
    }
    self.customerModel.customField = [dict copy];
}

- (void)pushUdeskSDK {
    
    if (self.uuid.length == 0) {
        [self showTextMessage:@"uuid必须要传！"];
        return;
    }
    
    if (self.key.length == 0) {
        [self showTextMessage:@"key必须要传！"];
        return;
    }
    
    if (self.customerModel.euid.length == 0) {
        [self showTextMessage:@"用户euid必须要传！"];
        return;
    }
    
    if (self.customerModel.name.length == 0) {
        [self showTextMessage:@"用户名称必须要传！"];
        return;
    }
    
    NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
    NSString *sha1 = [NSString stringWithFormat:@"%@%@%.f",self.uuid,self.key,s];
    
    [self pushSetingVCWithSign:[self sha1:sha1] timestamp:[NSString stringWithFormat:@"%.f",s]];
}

- (void)pushSetingVCWithSign:(NSString *)sign timestamp:(NSString *)timestamp {
    
    UMCSystem *system = [UMCSystem new];
    
    system.UUID = self.uuid;
    system.timestamp = timestamp;
    system.sign = sign;
    
    [UMCManager initWithSystem:system customer:self.customerModel completion:^(NSError *error) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"商户euid" message:@"请输入商户euid" preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            
        }];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            UITextField *textField = alert.textFields.firstObject;
            if (textField.text.length) {
                
                UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithMerchantEuid:textField.text];
                UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
                UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
                config.sdkStyle = styly;
                sdkManager.sdkConfig = config;
                [sdkManager pushUdeskInViewController:self completion:nil];
            }
            else {
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"请输入ID" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"确定", nil];
                [alertView show];
            }
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return self.customerInfo.count;
    }
    else {
        return self.customerModel.customField.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }

    if (indexPath.section == 0) {

        cell.textLabel.text = self.customerInfo[indexPath.row];
        switch (indexPath.row) {
            case 0:
                cell.detailTextLabel.text = self.uuid;
                break;
            case 1:
                cell.detailTextLabel.text = self.key;
                break;
            case 2:
                cell.detailTextLabel.text = self.customerModel.euid;
                break;
            case 3:
                cell.detailTextLabel.text = self.customerModel.name;
                break;
            case 4:
                cell.detailTextLabel.text = self.customerModel.cellphone;
                break;
            case 5:
                cell.detailTextLabel.text = self.customerModel.email;
                break;
            case 6:
                cell.detailTextLabel.text = self.customerModel.customerDescription;
                break;
            case 7:
                cell.detailTextLabel.text = self.customerModel.org;
                break;
            case 8:
                cell.detailTextLabel.text = self.customerModel.tags;
                break;
                
            default:
                break;
        }
    }
    else {

        NSDictionary *customField = self.customeField[indexPath.row];
        cell.textLabel.text = customField.allKeys.firstObject;
        id value = customField.allValues.firstObject;
        if ([value isKindOfClass:[NSString class]]) {
            cell.detailTextLabel.text = value;
        } else if ([value isKindOfClass:[NSArray class]]) {
            cell.detailTextLabel.text = [value componentsJoinedByString:@","];
        }
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.section != 0) {
        [self showTextMessage:cell.textLabel.text];
        return;
    }

    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"请输入%@的值",cell.textLabel.text] preferredStyle:1];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {

        UITextField *textField = alert.textFields.firstObject;
        if (indexPath.section == 0) {
            cell.detailTextLabel.text = textField.text;
            switch (indexPath.row) {
                case 0:
                    self.uuid = textField.text;
                    break;
                case 1:
                    self.key = textField.text;
                    break;
                case 2:
                    self.customerModel.euid = textField.text;
                    break;
                case 3:
                    self.customerModel.name = textField.text;
                    break;
                case 4:
                    self.customerModel.cellphone = textField.text;
                    break;
                case 5:
                    self.customerModel.email = textField.text;
                    break;
                case 6:
                    self.customerModel.customerDescription = textField.text;
                    break;
                case 7:
                    self.customerModel.org = textField.text;
                    break;
                case 8:
                    self.customerModel.tags = textField.text;
                    break;

                default:
                    break;
            }
        }

        [self.tableView reloadData];
    }]];

    [alert addTextFieldWithConfigurationHandler:nil];
    [self presentViewController:alert animated:YES completion:nil];
}

// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

    if (indexPath.section == 0) {
        return NO;
    }

    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source

        if (indexPath.section == 1) {
            [self.customeField removeObjectAtIndex:indexPath.row];
            [self updateCustomerField];
            [tableView reloadData];
        }
    }
}

- (NSMutableArray *)customerInfo {
    if (!_customerInfo) {
        _customerInfo = [NSMutableArray arrayWithObjects:@"uuid",@"key",@"euid",@"nickName",@"cellphone",@"email",@"description",@"org",@"tags", nil];
    }
    return _customerInfo;
}

- (NSMutableArray *)customeField {
    if (!_customeField) {
        _customeField = [NSMutableArray array];
    }
    return _customeField;;
}

- (UMCCustomer *)customerModel {
    if (!_customerModel) {
        _customerModel = [UMCCustomer new];
    }
    return _customerModel;
}

- (void)showTextMessage:(NSString *)message {

    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];

    HUD.userInteractionEnabled = NO;
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabel.text = [message copy];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];

    [HUD hideAnimated:YES afterDelay:2];
}

- (NSString *) sha1:(NSString *)input {
    
    NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, (unsigned int)data.length, digest);
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i=0; i<CC_SHA1_DIGEST_LENGTH; i++) {
        [output appendFormat:@"%02x", digest[i]];
    }
    
    return output;
}

@end
