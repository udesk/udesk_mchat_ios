//
//  UMCViewController.m
//  UdeskMChat
//
//  Created by xuchen on 2019/9/10.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UMCViewController.h"
#import "UMCSettingViewController.h"
#import "MBProgressHUD.h"

#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UdeskMChatUIKit.h"
#import <CommonCrypto/CommonDigest.h>
//#import "UMCHTTPManager.h"
#import "UMCHelper.h"

static CGFloat const kUMCHUDDuration = 1.2f;

@interface UMCViewController ()<UMCMessageDelegate>

@property (strong, nonatomic)  UITextField *uuidTextField;
@property (strong, nonatomic)  UITextField *keyTextField;
@property (strong, nonatomic)  UITextField *euidTextField;
@property (strong, nonatomic)  UITextField *nameTextField;
@property (strong, nonatomic)  UITextField *languageTextField;

@property (strong, nonatomic)  UISwitch *environmentSwitch;

@end

@implementation UMCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"多商户SDK";
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor whiteColor];
    [self setupViews];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgChange:) name:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil];
    [[UMCDelegate shareInstance] addDelegate:self];
    
#if 0
    self.uuidTextField.text = @"0ad5f61a-3769-4d32-87fc-4ce562d2677a";
    self.keyTextField.text = @"8d99703ffa2b06cd2609aa3c20be7128";
    self.euidTextField.text = @"abcefg";
#elif 1
    self.uuidTextField.text = @"7aacc075-3b99-477a-8dab-19109a2a5f5b";
    self.keyTextField.text = @"a4db8cf1a0dd4abfad3fce02728f8357";
    self.euidTextField.text = @"tz";
    self.nameTextField.text = @"TestName";
#endif
    //点击键盘消失
    [self configKeyBoard];
}

- (void)configKeyBoard{
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeKeyBoard)];
    [self.view addGestureRecognizer:tap];
}

- (void)closeKeyBoard{
    [self.view endEditing:YES];
}

- (void)setupViews{
    {
        UITextField *tx = [[UITextField alloc] initWithFrame:CGRectMake(15, 100, kUMCScreenWidth - 30, 28)];
        tx.placeholder = @"uuid(后台获取)";
        tx.font = [UIFont systemFontOfSize:14];
        tx.layer.borderWidth = 1.0;
        tx.layer.cornerRadius = 2.0;
        tx.layer.borderColor = [UIColor grayColor].CGColor;
        
        [self.view addSubview:tx];
        _uuidTextField = tx;
    }
    {
        UITextField *tx = [[UITextField alloc] initWithFrame:CGRectMake(15, 130, kUMCScreenWidth - 30, 28)];
        tx.placeholder = @"key(生产环境必须输入这个！))";
        tx.font = [UIFont systemFontOfSize:14];
        tx.layer.borderWidth = 1.0;
        tx.layer.cornerRadius = 2.0;
        tx.layer.borderColor = [UIColor grayColor].CGColor;
        [self.view addSubview:tx];
        _keyTextField = tx;
    }
    {
        UITextField *tx = [[UITextField alloc] initWithFrame:CGRectMake(15, 160, kUMCScreenWidth - 30, 28)];
        tx.placeholder = @"(商户ID)";
        tx.font = [UIFont systemFontOfSize:14];
        tx.layer.borderWidth = 1.0;
        tx.layer.cornerRadius = 2.0;
        tx.layer.borderColor = [UIColor grayColor].CGColor;
        [self.view addSubview:tx];
        _euidTextField = tx;
    }
    {
        UITextField *tx = [[UITextField alloc] initWithFrame:CGRectMake(15, 190, kUMCScreenWidth - 30, 28)];
        tx.placeholder = @"name(客户名称)";
        tx.font = [UIFont systemFontOfSize:14];
        tx.layer.borderWidth = 1.0;
        tx.layer.cornerRadius = 2.0;
        tx.layer.borderColor = [UIColor grayColor].CGColor;
        [self.view addSubview:tx];
        _nameTextField = tx;
    }
    
    
    {
        UITextField *tx = [[UITextField alloc] initWithFrame:CGRectMake(15, 220, kUMCScreenWidth - 30, 28)];
        tx.placeholder = @"多语言(默认不传，使用zh-CN)";
        tx.font = [UIFont systemFontOfSize:14];
        tx.layer.borderWidth = 1.0;
        tx.layer.cornerRadius = 2.0;
        tx.layer.borderColor = [UIColor grayColor].CGColor;
        [self.view addSubview:tx];
        _languageTextField = tx;
    }
    
    {
        UISwitch *switchButton = [[UISwitch alloc] initWithFrame:CGRectMake(kUMCScreenWidth - 60 - 20, _languageTextField.frame.origin.y + 50, 60, 40)];
        switchButton.on = YES;
        [self.view addSubview:switchButton];
        _environmentSwitch = switchButton;
        
        UILabel *label =[[UILabel alloc] initWithFrame:CGRectMake(0, switchButton.frame.origin.y + 45, kUMCScreenWidth - 16, 20)];
        label.text = @"打开状态为测试环境";
        label.font = [UIFont systemFontOfSize:14];
        label.textAlignment = NSTextAlignmentRight;
        [self.view addSubview:label];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(15, label.frame.origin.y + 30, kUMCScreenWidth - 30, 30)];
        button.layer.cornerRadius = 2.0;
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = [UIColor lightGrayColor].CGColor;
        [button setTitle:@"开启" forState:UIControlStateNormal];
        [button setTitleColor:[UIColor greenColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
}

- (void)buttonPressed:(id)sender {
    
    if (self.uuidTextField.text.length == 0) {
        [self showTextMessage:self.uuidTextField.placeholder];
        return;
    }
    
    if (self.euidTextField.text.length == 0) {
        [self showTextMessage:self.euidTextField.placeholder];
        return;
    }
    
    if (self.nameTextField.text.length == 0) {
        [self showTextMessage:self.nameTextField.placeholder];
        return;
    }
    
    if (self.keyTextField.text.length == 0) {
        [self showTextMessage:self.keyTextField.placeholder];
        return;
    }
    
    if (self.languageTextField.text.length > 0) {
        [UMCLanguage sharedInstance].language = self.languageTextField.text;
    }
    
    [UMCLanguage sharedInstance].language = self.languageTextField.text;
    
    NSString *bundlePath = [[NSBundle bundleForClass:[UMCViewController class]] pathForResource:@"udCustomBundle" ofType:@"bundle"];
    [UMCLanguage sharedInstance].customBundle = [NSBundle bundleWithPath:bundlePath];
    //测试环境
    if (self.environmentSwitch.on) {
        [UMCManager setIsDeveloper:YES];
    }
    else {
        [UMCManager setIsDeveloper:NO];
    }
    NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
    NSString *sha1 = [NSString stringWithFormat:@"%@%@%.f",self.uuidTextField.text,self.keyTextField.text,s];
    
    [self pushSetingVCWithSign:[self sha1:sha1] timestamp:[NSString stringWithFormat:@"%.f",s]];
}

- (void)pushSetingVCWithSign:(NSString *)sign timestamp:(NSString *)timestamp {
    
    UMCSystem *system = [UMCSystem new];
    
    system.UUID = self.uuidTextField.text;
    system.timestamp = timestamp;
    system.sign = sign;
    
    UMCCustomer *customer = [UMCCustomer new];
    customer.euid = self.euidTextField.text;
    customer.name = self.nameTextField.text;
//    customer.cellphone = @"15101509938";
//    customer.email = @"xuchen7@udesk.cn";
//    customer.org = @"udesk5";
//    customer.tags = @"测试7,test3";
//    customer.customerDescription = @"44442212125g";
//    customer.customField = @{@"TextField_34012":@"bbbvbb",
//                             @"SelectField_533":@[@(1)],
//    };
    
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
        
        [self hideWaitingMessage:nil];
        UMCSettingViewController *settingVC = [[UMCSettingViewController alloc] init];
        [self.navigationController pushViewController:settingVC animated:YES];
    }];
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

- (void)serversSignWithURL:(NSString *)url completion:(void(^)(NSString *sign,NSString *timestamp))completion {
    
    //请求路径
    NSMutableURLRequest *mulRequest = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
    //设置请求方法和请求体
    mulRequest.HTTPMethod = @"GET";
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:mulRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        //解析返回数据
        NSString *strData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSDictionary *dic = [UMCHelper dictionaryWithJSON:strData];
        if (completion) {
            completion(dic[@"sign"],dic[@"timestamp"]);
        }
    }];
    [dataTask resume];
}

- (void)didReceiveMessage:(UMCMessage *)message {
    
    NSLog(@"收到的信息:%@",message.content);
}

- (void)showTextMessage:(NSString *)message {
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    HUD.userInteractionEnabled = NO;
    HUD.mode = MBProgressHUDModeText;
    HUD.detailsLabel.text = [message copy];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [HUD hideAnimated:YES afterDelay:kUMCHUDDuration];
}

- (void)showWaitingMessage:(NSString *)message {
    
    MBProgressHUD *HUD = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    HUD.userInteractionEnabled = NO;
    HUD.detailsLabel.text = [message copy];
    HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
    
    [HUD showAnimated:YES];
}

- (void)hideWaitingMessage:(NSString *)message {
    
    MBProgressHUD *HUD = [MBProgressHUD HUDForView:self.view];
    if (message) {
        
        HUD.userInteractionEnabled = NO;
        HUD.detailsLabel.text = [message copy];
        HUD.detailsLabel.font = [UIFont boldSystemFontOfSize:16];
        HUD.mode = MBProgressHUDModeText;
        [HUD hideAnimated:YES afterDelay:kUMCHUDDuration];
    }
    else {
        [HUD hideAnimated:YES afterDelay:kUMCHUDDuration];
    }
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
