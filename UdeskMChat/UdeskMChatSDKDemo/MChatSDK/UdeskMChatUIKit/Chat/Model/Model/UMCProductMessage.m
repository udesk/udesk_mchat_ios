//
//  UMCProductMessage.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCProductMessage.h"
#import "UMCProductCell.h"
#import "UIImage+UMC.h"
#import "UMCSDKConfig.h"
#import "UMCHelper.h"
#import "UMCBundleHelper.h"
#import "UMCUIMacro.h"

/** 咨询对象cell高度 */
static CGFloat const kUDProductCellHeight = 105;
/** 咨询对象height */
static CGFloat const kUDProductHeight = 85;
/** 咨询对象图片距离屏幕水平边沿距离 */
static CGFloat const kUDProductImageToHorizontalEdgeSpacing = 10.0;
/** 咨询对象图片距离屏幕垂直边沿距离 */
static CGFloat const kUDProductImageToVerticalEdgeSpacing = 10.0;
/** 咨询对象图片直径 */
static CGFloat const kUDProductImageDiameter = 65.0;
/** 咨询对象标题距离咨询对象图片水平边沿距离 */
static CGFloat const kUDProductTitleToProductImageHorizontalEdgeSpacing = 12.0;
/** 咨询对象标题距离屏幕垂直边沿距离 */
static CGFloat const kUDProductTitleToVerticalEdgeSpacing = 10.0;
/** 咨询对象标题高度 */
static CGFloat const kUDProductTitleHeight = 40.0;
/** 咨询对象副标题距离标题垂直距离 */
static CGFloat const kUDProductDetailToTitleVerticalEdgeSpacing = 5.0;
/** 咨询对象副标题高度 */
static CGFloat const kUDProductDetailHeight = 20;
/** 咨询对象发送按钮右侧距离 */
static CGFloat const kUDProductSendButtonToRightHorizontalEdgeSpacing = 19.0;
/** 咨询对象发送按钮距离标题垂直距离 */
static CGFloat const kUDProductSendButtonToTitleVerticalEdgeSpacing = 5.0;
/** 咨询对象发送按钮距width */
static CGFloat const kUDProductSendButtonWidth = 65.0;
/** 咨询对象发送按钮距height */
static CGFloat const kUDProductSendButtonHeight = 25.0;

@interface UMCProductMessage()

/** 咨询对象标题Frame */
@property (nonatomic, assign, readwrite) CGRect   productTitleFrame;
/** 咨询对象副标题Frame */
@property (nonatomic, assign, readwrite) CGRect   productDetailFrame;
/** 咨询对象发送文字Frame */
@property (nonatomic, assign, readwrite) CGRect   productSendFrame;
/** 咨询对象图片Frame */
@property (nonatomic, assign, readwrite) CGRect   productImageFrame;
/** 咨询对象Frame */
@property (nonatomic, assign, readwrite) CGRect   productFrame;

@end

@implementation UMCProductMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        @try {
            
            self.cellHeight = kUDProductCellHeight;
            
            if (![UMCHelper isBlankString:message.productMessage.url]) {
                self.productURL = message.productMessage.url;
            }
            
            //咨询对象图片
            if (![UMCHelper isBlankString:message.productMessage.image]) {
                
                self.productImage = [UIImage umcDefaultLoadingImage];
                self.productImageURL = message.productMessage.image;
                self.productImageFrame = CGRectMake(kUDProductImageToHorizontalEdgeSpacing, kUDProductImageToVerticalEdgeSpacing, kUDProductImageDiameter, kUDProductImageDiameter);
            }
            
            //咨询对象标题
            if (![UMCHelper isBlankString:message.productMessage.title]) {
                self.productTitle = message.productMessage.title;
                CGFloat productTitleX = self.productImageFrame.origin.x+self.productImageFrame.size.width+kUDProductTitleToProductImageHorizontalEdgeSpacing;
                self.productTitleFrame = CGRectMake(productTitleX, kUDProductTitleToVerticalEdgeSpacing, kUMCScreenWidth-productTitleX-kUDProductTitleToProductImageHorizontalEdgeSpacing, kUDProductTitleHeight);
            }
            
            //咨询对象副标题
            NSArray *array = [message.productMessage.extras valueForKey:@"content"];
            if (![UMCHelper isBlankString:array.firstObject]) {
                self.productDetail = array.firstObject;
                self.productDetailFrame = CGRectMake(CGRectGetMinX(self.productTitleFrame), self.productTitleFrame.origin.y+self.productTitleFrame.size.height+ kUDProductDetailToTitleVerticalEdgeSpacing, self.productTitleFrame.size.width/2, kUDProductDetailHeight);
            }
            
            //咨询对象发送按钮
            if ([UMCSDKConfig sharedConfig].productSendText) {
                self.productSendText = [UMCSDKConfig sharedConfig].productSendText;
            }
            else {
                self.productSendText = UMCLocalizedString(@"udesk_send_link");
            }
            
            self.productSendFrame = CGRectMake(kUMCScreenWidth-kUDProductSendButtonWidth-kUDProductSendButtonToRightHorizontalEdgeSpacing, self.productTitleFrame.origin.y+self.productTitleFrame.size.height+kUDProductSendButtonToTitleVerticalEdgeSpacing, kUDProductSendButtonWidth, kUDProductSendButtonHeight);
            
            self.productFrame = CGRectMake(0, 10, kUMCScreenWidth, kUDProductHeight);
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UMCProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
