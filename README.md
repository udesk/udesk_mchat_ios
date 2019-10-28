### 公告

**接入sdk编译报错误请升级Xcode到最新版本或者选择“sdk_xcode10”分支下载导入！！！**

### 1.导入SDK

- 把Udesk SDK 文件夹中的 `UdeskMChatSDK.framework` 、 `UdeskMChatUIKit`文件夹 拷贝到新创建的工程路径下面，然后在工程目录结构中，右键选择 *Add Files to “工程名”* 。或者将这两个个文件拖入 Xcode 工程目录结构中。


#### 1.1 引入依赖库

- libxml2.tbd
- libresolv.tbd

#### 1.2 注意事项

- 多商户SDK使用了以下第三方框架，如果你们APP中也使用了则需要把我们SDK里的第三方框架删除。（框架路径：UdeskMChat/UdeskMChatUIKit/Tools/Vendor）
- 如果你使用的是xcode8 请在你项目的Info.plist文件里添加使用相册、相机、麦克风、保存图片到相册的权限


```objective-c
<key>NSCameraUsageDescription</key>

<string>App需要访问您的相机</string>

<key>NSMicrophoneUsageDescription</key>

<string>App需要访问您的麦克风</string>

<key>NSPhotoLibraryAddUsageDescription</key>

<string>App需要为您添加图片</string>

<key>NSPhotoLibraryUsageDescription</key>

<string>App需要访问您的相册</string>
```

### 2.快速使用

> 引入 ‘ \#import <UdeskMChatSDK/UdeskMChatSDK.h>’
>
> 在AppDelegate、或者登陆成功之后里初始化SDK

##### 签名生成规则：

##### 出于安全的考虑，建议租户将 key 保存在自己的服务器端，App 端通过租户提供的接口获取经过 SHA1  计算后的加密字符串(sign)和时间戳(timestamp),时间戳精确到秒，然后传给 SDK。密码的有效期为时间戳 +/- 5分钟     SHA1("租户uuid+租户key+时间戳")加密字符粗的格式

| 数据名称      | 说明         |
| --------- | ---------- |
| uuid      | Udesk后台提供  |
| secret    | Udesk后台提供  |
| timestamp | 获取精确到秒的时间戳 |

```
sign = SHA1("uuid+secret+timestamp")
```

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  UMCSystem *system = [UMCSystem new];
  //租户ID，Udesk后台系统获取
  system.UUID = @"a04d138d-98fb-4b9d-b2a7-478b7c0c1ce9";
  //时间戳，由你们后端返回
  system.timestamp = @"timestamp";
  //签名，由你们后端返回
  system.sign = @"sign";
            
  UMCCustomer *customer = [UMCCustomer new];
  //用户ID是用户的唯一标示，请不要重复，并且只允许使用数字、字母、数字+字母
  customer.euid = @"用户ID";
  customer.name = @"用户姓名";
            
  [UMCManager initWithSystem:system customer:customer completion:^(NSError *error) {
       NSLog(@"%@",error);
  }];
}
```

> 在合适的地方添加商户列表View

```objective-c
UMCMerchantsView *merchats = [[UMCMerchantsView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) sdkConfig:[self getConfig]];
[self.view addSubview:merchats];

- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    
    UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
    config.sdkStyle = styly;
    
    return config;
}
```

> 进入聊天页

###### 客户通过某个商品详情页点击咨询按钮直接和客服进行会话

```objective-c
UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithMerchantId:@"商户ID"];
sdkManager.sdkConfig = [self getConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
            
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
```

### 3.商品消息

```objective-c
UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithMerchantId:@"商户ID"];
sdkManager.sdkConfig = [self getConfig];
[sdkManager pushUdeskInViewController:self completion:nil];
            
- (UMCSDKConfig *)getConfig {
    
    UMCSDKConfig *config = [UMCSDKConfig sharedConfig];
    
    UMCCustomButtonConfig *customButton = [[UMCCustomButtonConfig alloc] initWithTitle:@"自定义按钮" clickBlock:^(UMCCustomButtonConfig *customButton, UMCIMViewController *viewController){
        
        //点击自定义按钮回调
        //示例里直接在回调里发送了商品消息，开发者可以根据自己需求进行修改
        [viewController sendGoodsMessageWithModel:[self getGoodsModel]];
    }];
    
    config.showCustomButtons = YES;
    config.customButtons = @[customButton];
    
    UMCSDKStyle *styly = [UMCSDKStyle defaultStyle];
    config.sdkStyle = styly;
    
    return config;
}

- (UMCGoodsModel *)getGoodsModel {
    
    UMCGoodsModel *goodsModel = [[UMCGoodsModel alloc] init];
    goodsModel.goodsId = @"12";
    goodsModel.name = @"Apple iPhone X (A1903) 64GB 深空灰色 移动联通4G手机";
    goodsModel.url = @"https://item.jd.com/6748052.html";
    goodsModel.imgUrl = @"http://img12.360buyimg.com/n1/s450x450_jfs/t10675/253/1344769770/66891/92d54ca4/59df2e7fN86c99a27.jpg";
    
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
    
    goodsModel.params = @[paramModel1,paramModel2,paramModel3];
    
    return goodsModel;
}
```

### 4.离线推送

```objective-c
//App 进入后台时，关闭Udesk推送
- (void)applicationDidEnterBackground:(UIApplication *)application {
  
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

//App 进入前台时，开启Udesk推送
- (void)applicationWillEnterForeground:(UIApplication *)application {
	[UMCManager endUdeskMChatPush];
}
```

### 5.接口说明

##### 1.接受消息代理

```objective-c
//添加当前类为代理，
[[UMCDelegate shareInstance] addDelegate:self];
//实现接受消息方法
- (void)didReceiveMessage:(UMCMessage *)message {
  	NSLog(@"%@",message);
}

//移除代理
[[UMCDelegate shareInstance] removeDelegate:self];
```

##### 2.未读消息回调

```objective-c
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(msgUnreadCountHasChange:) name:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil];

- (void)msgUnreadCountHasChange:(NSNotification *)notif {
    [UMCManager merchantsUnreadCountWithEuid:nil completion:^(NSInteger unreadCount) {
        
        UINavigationController *nav = self.tabBarController.viewControllers[1];
        nav.tabBarItem.badgeValue = [NSString stringWithFormat:@"%ld",unreadCount];
        if (unreadCount == 0) {
            nav.tabBarItem.badgeValue = nil;
        }
    }];
}
```

> 其他API参考UMCManager.h

