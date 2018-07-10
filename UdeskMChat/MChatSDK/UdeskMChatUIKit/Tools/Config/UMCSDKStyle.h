//
//  UMCSDKStyle.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/29.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+UMC.h"
#import "UIImage+UMC.h"
#import "UMCUIMacro.h"

typedef NS_ENUM(NSUInteger, UDChatViewStyleType) {
    UDChatViewStyleTypeDefault
};

@interface UMCSDKStyle : NSObject

/** 用户的消息颜色 */
@property (nonatomic, strong) UIColor  *customerTextColor;

/** 客户的气泡颜色 */
@property (nonatomic, strong) UIColor  *customerBubbleColor;

/** 客户的气泡图片 */
@property (nonatomic, strong) UIImage  *customerBubbleImage;

/** 客服的消息颜色 */
@property (nonatomic, strong) UIColor  *agentTextColor;

/** 客服的气泡颜色 */
@property (nonatomic, strong) UIColor  *agentBubbleColor;

/** 客服的气泡图片 */
@property (nonatomic, strong) UIImage  *agentBubbleImage;

/** 时间颜色（默认灰色）*/
@property (nonatomic, strong) UIColor  *chatTimeColor;

/** IM页面底部功能栏背景颜色(默认白色) */
@property (nonatomic, strong) UIColor  *inputViewColor;

/** IM页面底部输入栏背景颜色(默认白色) */
@property (nonatomic, strong) UIColor  *textViewColor;

/** 消息内容（文字）字体大小 */
@property (nonatomic, strong) UIFont   *messageContentFont;

/** 消息内容（时间）字体大小 */
@property (nonatomic, strong) UIFont   *messageTimeFont;

/** 导航栏返回按钮颜色 */
@property (nonatomic, strong) UIColor  *navBackButtonColor;

/** 导航栏返回按钮图片 */
@property (nonatomic, strong) UIImage  *navBackButtonImage;

/** 导航栏颜色 */
@property (nonatomic, strong) UIColor  *navigationColor;

/** 导航栏背景图片 */
@property (nonatomic, strong) UIImage  *navBarBackgroundImage;

/** 标题颜色 */
@property (nonatomic, strong) UIColor  *titleColor;

/** 标题大小 */
@property (nonatomic, strong) UIFont   *titleFont;

/** 录音颜色 */
@property (nonatomic, strong) UIColor  *recordViewColor;

/** 客户语音时长颜色 */
@property (nonatomic, strong) UIColor  *customerVoiceDurationColor;

/** 客服语音时长颜色 */
@property (nonatomic, strong) UIColor  *agentVoiceDurationColor;

/** 背景颜色 */
@property (nonatomic, strong) UIColor  *tableViewBackGroundColor;

/** 聊天vc背景颜色 (在iPhone x上这个和inputViewColor结合使用) */
@property (nonatomic, strong) UIColor  *chatViewControllerBackGroundColor;

/** 咨询对象背景颜色 */
@property (nonatomic, strong) UIColor  *productBackGroundColor;

/** 咨询对象标题颜色 */
@property (nonatomic, strong) UIColor  *productTitleColor;

/** 咨询对象子标题颜色 */
@property (nonatomic, strong) UIColor  *productDetailColor;

/** 咨询对象发送按钮背景颜色 */
@property (nonatomic, strong) UIColor  *productSendBackGroundColor;

/** 咨询对象发送按钮颜色 */
@property (nonatomic, strong) UIColor  *productSendTitleColor;

/** 超链接点击颜色 */
@property (nonatomic, strong) UIColor *activeLinkColor;
/** 超链接颜色 */
@property (nonatomic, strong) UIColor *linkColor;

/** 商品消息名称字体 */
@property (nonatomic, strong) UIFont *goodsNameFont;
/** 商品消息名称颜色 */
@property (nonatomic, strong) UIColor *goodsNameTextColor;

+ (instancetype)defaultStyle;
+ (instancetype)customStyle;

@end
