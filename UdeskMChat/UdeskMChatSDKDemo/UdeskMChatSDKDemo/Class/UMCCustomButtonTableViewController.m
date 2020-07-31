//
//  UMCCustomButtonTableViewController.m
//  UDMChatSDK
//
//  Created by xuchen on 2018/7/2.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCCustomButtonTableViewController.h"
#import "UdeskMChatUIKit.h"
#import "UMCOrderTestViewController.h"
#import "UMCSessionListViewController.h"
#import "UMCImagePicker.h"

@interface UMCCustomButtonTableViewController ()

@property (nonatomic, strong) NSMutableArray *customButtons;
@property (nonatomic, strong) NSIndexPath *currentIndexPath;
@property (nonatomic, strong) UMCImagePicker *imagePicker;

@end

@implementation UMCCustomButtonTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    self.tableView.tableFooterView = [UIView new];
    
    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneConfigCustomButton:)];
    UIBarButtonItem *add = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(appendCustomButton:)];
    self.navigationItem.rightBarButtonItems = @[done,add];
}

- (void)appendCustomButton:(id)sender {
    
    UMCCustomButtonConfig *buttonConfig = [[UMCCustomButtonConfig alloc] initWithTitle:@"自定义按钮" clickBlock:^(UMCCustomButtonConfig *customButton, UMCIMViewController *viewController) {
        UMCOrderTestViewController *orders = [[UMCOrderTestViewController alloc] init];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:orders];
        [viewController presentViewController:nav animated:YES completion:nil];
        
        orders.didSendOrderBlock = ^(UMCSendType sendType,UMCGoodsModel *goodsModel) {
            [self sendOrderWithType:sendType viewController:viewController goodsModel:goodsModel];
        };
    }];
    [self.customButtons insertObject:buttonConfig atIndex:0];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择按钮位置" preferredStyle:0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"输入栏上方" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        buttonConfig.type = UMCCustomButtonTypeInInputTop;
        [self.tableView reloadData];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"更多内部" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        buttonConfig.type = UMCCustomButtonTypeInMoreView;
        [self.tableView reloadData];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)doneConfigCustomButton:(id)sender {
    
    UMCSessionListViewController *message = [[UMCSessionListViewController alloc] init];
    message.customButtons = self.customButtons;
    [self.navigationController pushViewController:message animated:YES];
}

- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    config.clickGoodsBlock = ^(UMCIMViewController *viewController, NSString *url) {
        NSLog(@"%@",url);
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    };
    
    config.showCustomButtons = YES;
    config.customButtons = self.customButtons;
    
    UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
    config.sdkStyle = styly;
    
    return config;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.customButtons.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    
    UMCCustomButtonConfig *config = self.customButtons[indexPath.row];
    cell.imageView.image = config.image;
    
    if (config.type == UMCCustomButtonTypeInInputTop) {
        cell.textLabel.text = [config.title stringByAppendingPathComponent:@"（我在输入框上面）"];
    }
    else {
        cell.textLabel.text = [config.title stringByAppendingPathComponent:@"（我在更多里面）"];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.customButtons removeObjectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    _currentIndexPath = indexPath;
    
    UMCCustomButtonConfig *config = self.customButtons[_currentIndexPath.row];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请选择需要修改的内容" preferredStyle:0];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        //ipad适配
        [alert setModalPresentationStyle:UIModalPresentationPopover];
        UIPopoverPresentationController *popPresenter = [alert popoverPresentationController];
        popPresenter.sourceView = self.view;
        popPresenter.sourceRect = CGRectMake(self.view.center.x, 74, 1, 1);
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"图片" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        @udWeakify(self);
        [self.imagePicker showWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary viewController:self];
        self.imagePicker.FinishNormalImageBlock = ^(UIImage *image) {
            @udStrongify(self);
            config.image = image;
            [self.tableView reloadData];
        };
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"标题" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"请输入标题" preferredStyle:1];
        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            UITextField *textField = alert.textFields.firstObject;
            config.title = textField.text;
            [self.tableView reloadData];
        }]];
        
        [alert addTextFieldWithConfigurationHandler:nil];
        
        [self presentViewController:alert animated:YES completion:nil];
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)sendOrderWithType:(UMCSendType)sendType viewController:(UMCIMViewController *)viewController goodsModel:(UMCGoodsModel *)goodsModel {
    
    //以下数据都是伪造的，实际开发已真实为例
    switch (sendType) {
        case UMCSendTypeText:
            
            [viewController sendTextMessageWithContent:@"测试自定义按钮回调发送文本信息"];
            break;
        case UMCSendTypeImage:
            
            [viewController sendImageMessageWithImage:[UIImage imageNamed:@"avatar"]];
            break;
        case UMCSendTypeVoice:
            
            [viewController sendVoiceMessageWithVoicePath:[[NSBundle mainBundle] pathForResource:@"002" ofType:@"aac"] voiceDuration:@"3"];
            break;
        case UMCSendTypeGIF:{
            
            NSData *data = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"001" ofType:@"gif"]];
            [viewController sendGIFMessageWithGIFData:data];
            break;
        }
        case UMCSendTypeGoods:{

            UMCGoodsModel *goodsModel1 = [[UMCGoodsModel alloc] init];
            goodsModel1.name = @"Apple iPhone X (A1903) 64GB 深空灰色 移动联通4G手机";
            goodsModel1.url = @"https://item.jd.com/6748052.html";
            goodsModel1.imgUrl = @"http://img12.360buyimg.com/n1/s450x450_jfs/t10675/253/1344769770/66891/92d54ca4/59df2e7fN86c99a27.jpg";

            UMCGoodsParamModel *paramModel1 = [UMCGoodsParamModel new];
            paramModel1.text = @"￥6999.00";
            paramModel1.color = @"#FF0000";
            paramModel1.fold = @(1);
            paramModel1.udBreak = @(1);
            paramModel1.size = @(14);

            UMCGoodsParamModel *paramModel2 = [UMCGoodsParamModel new];
            paramModel2.text = @"满1999元另加30元";
            paramModel2.color = @"#c2fcc3";
            paramModel2.fold = @(1);
            paramModel2.size = @(12);

            UMCGoodsParamModel *paramModel3 = [UMCGoodsParamModel new];
            paramModel3.text = @"但是我会先提价100";
            paramModel3.color = @"#ffffff";
            paramModel3.fold = @(1);
            paramModel3.size = @(20);

            goodsModel1.params = @[paramModel1,paramModel2,paramModel3];

            [viewController sendGoodsMessageWithModel:goodsModel1];
            
//            [viewController sendGoodsMessageWithModel:goodsModel];
            break;
        }
        default:
            break;
    }
}

- (NSMutableArray *)customButtons {
    if (!_customButtons) {
        _customButtons = [NSMutableArray array];
    }
    return _customButtons;
}

- (UMCImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UMCImagePicker alloc] init];
    }
    return _imagePicker;
}

@end
