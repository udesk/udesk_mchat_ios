//
//  UMCIMViewController.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMCSDKConfig;
@class UMCMessage;
@class UMCGoodsModel;

@interface UMCIMViewController : UIViewController

//更新最后一条消息
@property (nonatomic, copy) void(^UpdateLastMessageBlock)(UMCMessage *message);

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantEuid:(NSString *)merchantEuid;

- (void)dismissChatViewController;

//发送文字
- (void)sendTextMessageWithContent:(NSString *)content;
//发送图片
- (void)sendImageMessageWithImage:(UIImage *)image;
//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData;
//发送语音
- (void)sendVoiceMessageWithVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration;
//发送商品
- (void)sendGoodsMessageWithModel:(UMCGoodsModel *)goodsModel;

@end
