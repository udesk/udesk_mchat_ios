### 1.导入SDK

- 把Udesk SDK 文件夹中的 `UdeskMChatSDK.framework` 、 `UdeskMChatUIKit`文件夹 拷贝到新创建的工程路径下面，然后在工程目录结构中，右键选择 *Add Files to “工程名”* 。或者将这两个个文件拖入 Xcode 工程目录结构中。


- 在TARGETS里检查Embedded Binaries 下是否已经引入了 `UdeskMChatSDK.framework` ，没有则需要手动添加。


- UdeskMChatSDK 依赖阿里OSS文件存储系统SDK，如果你们App没有该SDK则需要添加。


#### 1.1.注意事项

- 多商户SDK使用了以下第三方框架，如果你们APP中也使用了则需要把我们SDK里的第三方框架删除。（框架路径：UdeskMChat/UdeskMChatUIKit/Tools/Vendor）


### 2.快速使用

> 引入 ‘ \#import <UdeskMChatSDK/UdeskMChatSDK.h>’
>
> 在AppDelegate、或者登陆成功之后里初始化SDK

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
UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithSDKConfig:[self getConfig] merchantId:@"商户ID"];
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



### 3.离线推送

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

### 4.接口说明

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
//当未读消息发生改变时的回调
[UMCSDKConfig sharedConfig].unreadCountDidChange = ^(BOOL isPlus, NSString *count) {
    //isPlus 为YES时 是增加未读消息数，反之则是已读
  	//cont是此次操作的未读消息数
};
```

> 其他API参考UMCManager.h

