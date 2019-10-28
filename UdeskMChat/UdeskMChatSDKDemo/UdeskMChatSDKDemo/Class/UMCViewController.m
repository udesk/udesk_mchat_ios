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

@property (strong, nonatomic) IBOutlet UITextField *uuidTextField;
@property (strong, nonatomic) IBOutlet UITextField *keyTextField;
@property (strong, nonatomic) IBOutlet UITextField *euidTextField;
@property (strong, nonatomic) IBOutlet UITextField *nameTextField;
@property (strong, nonatomic) IBOutlet UISwitch *environmentSwitch;

@end

@implementation UMCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgChange:) name:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil];
    [[UMCDelegate shareInstance] addDelegate:self];
    
    self.uuidTextField.text = @"b1ce357b-8ce8-4ea1-9a87-7d15519dd7e6";
    self.keyTextField.text = @"27aa6696cba45cc091ee66fbc25aedab";
}

- (IBAction)startUMCAction:(id)sender {
    
    if (self.uuidTextField.text.length == 0) {
        [self showTextMessage:self.uuidTextField.placeholder];
        return;
    }
    
    if (self.euidTextField.text.length == 0) {
        [self showTextMessage:self.euidTextField.placeholder];
        return;
    }
    
    //测试环境
    if (self.environmentSwitch.on) {
        
        [UMCManager setIsDeveloper:YES];
        
        [self showWaitingMessage:nil];
        NSString *url = [NSString stringWithFormat:@"http://mchat.udeskmonkey.com/sdk/v1/%@/demo_sign",self.uuidTextField.text];
        [self serversSignWithURL:url completion:^(NSString *sign,NSString *timestamp) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self pushSetingVCWithSign:sign timestamp:timestamp];
            });
        }];
    }
    else {
        
        if (self.keyTextField.text.length == 0) {
            [self showTextMessage:self.keyTextField.placeholder];
            return;
        }
        
        [UMCManager setIsDeveloper:NO];
        
        NSTimeInterval s = [[NSDate date] timeIntervalSince1970];
        NSString *sha1 = [NSString stringWithFormat:@"%@%@%.f",self.uuidTextField.text,self.keyTextField.text,s];
        
        [self pushSetingVCWithSign:[self sha1:sha1] timestamp:[NSString stringWithFormat:@"%.f",s]];
    }
}

- (void)pushSetingVCWithSign:(NSString *)sign timestamp:(NSString *)timestamp {
    
    UMCSystem *system = [UMCSystem new];
    
    system.UUID = self.uuidTextField.text;
    system.timestamp = timestamp;
    system.sign = sign;
    
    UMCCustomer *customer = [UMCCustomer new];
    customer.euid = self.euidTextField.text;
    if (self.nameTextField.text.length == 0) {
        customer.name = self.nameTextField.text;
    }
    
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
