//
//  UMCSDKStyle.m
//  UdeskSDK
//
//  Created by Udesk on 16/8/29.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCSDKStyle.h"

@implementation UMCSDKStyle

+ (instancetype)createWithStyle:(UDChatViewStyleType)type {
    return [UMCSDKStyle new];
}

+ (instancetype)customStyle {
    return [self createWithStyle:(UDChatViewStyleTypeDefault)];
}

+ (instancetype)defaultStyle {
    return [self createWithStyle:(UDChatViewStyleTypeDefault)];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        //customer
        self.customerTextColor = [UIColor whiteColor];
        self.customerBubbleColor = [UIColor umcColorWithHexString:@"#0B84FE"];
        self.customerBubbleImage = [UIImage umcBubbleSendImage];
        self.customerVoiceDurationColor = [UIColor umcColorWithHexString:@"#8E8E93"];;
        
        //agent
        self.agentTextColor = [UIColor blackColor];
        self.agentBubbleColor = [UIColor umcColorWithHexString:@"#F1F0F0"];
        self.agentBubbleImage = [UIImage umcBubbleReceiveImage];
        self.agentVoiceDurationColor = [UIColor umcColorWithHexString:@"#8E8E93"];
        
        //im
        self.tableViewBackGroundColor = [UIColor whiteColor];
        self.chatViewControllerBackGroundColor = [UIColor whiteColor];
        self.chatTimeColor = [UIColor umcColorWithHexString:@"#8E8E93"];
        self.inputViewColor = [UIColor whiteColor];
        self.textViewColor = [UIColor whiteColor];
        self.messageContentFont = [UIFont systemFontOfSize:16];
        self.messageTimeFont = [UIFont systemFontOfSize:12];
        self.linkColor = [UIColor blueColor];
        self.activeLinkColor = [UIColor redColor];
        self.goodsNameFont = [UIFont boldSystemFontOfSize:14];
        self.goodsNameTextColor = [UIColor whiteColor];
        
        //nav
        self.navBackButtonColor = [UIColor umcColorWithHexString:@"#007AFF"];
        self.navBackButtonImage = [UIImage umcDefaultBackImage];
        self.navigationColor = [UIColor colorWithRed:0.976f  green:0.976f  blue:0.976f alpha:1];
        self.navBarBackgroundImage = nil;
        
        //title
        self.titleFont = [UIFont systemFontOfSize:16];
        self.titleColor = [UIColor blackColor];
        
        //record
        self.recordViewColor = [UIColor umcColorWithHexString:@"#FAFAFA"];
        
        //product
        self.productBackGroundColor = [UIColor umcColorWithHexString:@"#F1F0F0"];
        self.productTitleColor = [UIColor umcColorWithHexString:@"#000000"];
        self.productDetailColor = [UIColor umcColorWithHexString:@"#FF3B30"];
        self.productSendBackGroundColor = [UIColor umcColorWithHexString:@"#FF3B30"];
        self.productSendTitleColor = [UIColor whiteColor];
        
    }
    return self;
}

@end
