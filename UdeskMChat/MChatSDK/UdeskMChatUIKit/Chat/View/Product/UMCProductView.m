//
//  UMCProductView.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/11/21.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCProductView.h"
#import "UMCSDKConfig.h"
#import "UMCHelper.h"
#import "UIImage+UMC.h"
#import "UIView+UMC.h"

#import "UMCBundleHelper.h"
#import "UMC_YYWebImage.h"

/** 咨询对象图片距离屏幕水平边沿距离 */
static CGFloat const kUDProductImageToHorizontalEdgeSpacing = 10.0;
/** 咨询对象图片距离屏幕垂直边沿距离 */
static CGFloat const kUDProductImageToVerticalEdgeSpacing = 8.0;
/** 咨询对象图片直径 */
static CGFloat const kUDProductImageDiameter = 55.0;
/** 咨询对象标题距离咨询对象图片水平边沿距离 */
static CGFloat const kUDProductTitleToProductImageHorizontalEdgeSpacing = 12.0;
/** 咨询对象标题距离屏幕垂直边沿距离 */
static CGFloat const kUDProductTitleToVerticalEdgeSpacing = 10.0;
/** 咨询对象标题高度 */
static CGFloat const kUDProductTitleHeight = 20.0;
/** 咨询对象副标题距离标题垂直距离 */
static CGFloat const kUDProductDetailToTitleVerticalEdgeSpacing = 10.0;
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
















@implementation UMCProductView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)setup {
    
    
}

- (UIView *)productBackGroundView {
    
    if (!_productBackGroundView) {
        _productBackGroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _productBackGroundView.backgroundColor = [UMCSDKConfig sharedConfig].sdkStyle.productBackGroundColor;
        [self addSubview:_productBackGroundView];
    }
    return _productBackGroundView;
}

- (UIImageView *)productImageView {
    
    if (!_productImageView) {
        _productImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _productImageView.backgroundColor = [UIColor clearColor];
        [self.productBackGroundView addSubview:_productImageView];
    }
    
    return _productImageView;
}

- (UILabel *)productTitleLabel {
    
    if (!_productTitleLabel) {
        _productTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productTitleLabel.backgroundColor = [UIColor clearColor];
        _productTitleLabel.textColor = [UMCSDKConfig sharedConfig].sdkStyle.productTitleColor;
        _productTitleLabel.font = [UIFont systemFontOfSize:15];
        _productTitleLabel.numberOfLines = 0;
        [self.productBackGroundView addSubview:_productTitleLabel];
    }
    
    return _productTitleLabel;
}

- (UILabel *)productDetailLabel {
    
    if (!_productDetailLabel) {
        _productDetailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _productDetailLabel.backgroundColor = [UIColor clearColor];
        _productDetailLabel.textColor = [UMCSDKConfig sharedConfig].sdkStyle.productDetailColor;
        _productDetailLabel.font = [UIFont systemFontOfSize:15];
        _productDetailLabel.numberOfLines = 0;
        [_productDetailLabel sizeToFit];
        [self.productBackGroundView addSubview:_productDetailLabel];
    }
    
    return _productDetailLabel;
}

- (UIButton *)productSendButton {
    
    if (!_productSendButton) {
        _productSendButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _productSendButton.frame = CGRectZero;
        _productSendButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [_productSendButton setTitleColor:[UMCSDKConfig sharedConfig].sdkStyle.productSendTitleColor forState:UIControlStateNormal];
        _productSendButton.backgroundColor = [UMCSDKConfig sharedConfig].sdkStyle.productSendBackGroundColor;
        [_productSendButton addTarget:self action:@selector(sendProductUrlAction:) forControlEvents:UIControlEventTouchUpInside];
        kUMCViewRadius(_productSendButton, 2);
        [self.productBackGroundView addSubview:_productSendButton];
    }
    
    return _productSendButton;
}
- (void)setProductModel:(UMCProduct *)productModel {
    _productModel = productModel;
    //咨询对象图片
    self.productImageView.frame = CGRectMake(kUDProductImageToHorizontalEdgeSpacing, kUDProductImageToVerticalEdgeSpacing, kUDProductImageDiameter, kUDProductImageDiameter);
    if (productModel.image && [productModel.image isKindOfClass:[NSString class]]) {
        [self.productImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[productModel.image stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage umcDefaultLoadingImage]];
    }
    
    //咨询对象标题
    CGFloat productTitleX = self.productImageView.umcRight+kUDProductTitleToProductImageHorizontalEdgeSpacing;
    self.productTitleLabel.frame = CGRectMake(productTitleX, kUDProductTitleToVerticalEdgeSpacing, kUMCScreenWidth-productTitleX-kUDProductTitleToProductImageHorizontalEdgeSpacing, kUDProductTitleHeight);
    self.productTitleLabel.text = productModel.title;
    
    //咨询对象副标题
    self.productDetailLabel.frame = CGRectMake(CGRectGetMinX(self.productTitleLabel.frame), self.productTitleLabel.umcBottom+ kUDProductDetailToTitleVerticalEdgeSpacing, self.productTitleLabel.umcWidth-kUDProductTitleToProductImageHorizontalEdgeSpacing - kUDProductSendButtonWidth, kUDProductDetailHeight);
    
    //咨询对象发送按钮
    NSString *productSendText = UMCLocalizedString(@"udesk_send_link");
    [self.productSendButton setTitle:productSendText forState:UIControlStateNormal];
    self.productSendButton.frame = CGRectMake(kUMCScreenWidth - kUDProductSendButtonWidth-kUDProductSendButtonToRightHorizontalEdgeSpacing, CGRectGetMaxY(self.productTitleLabel.frame)+kUDProductSendButtonToTitleVerticalEdgeSpacing, kUDProductSendButtonWidth, kUDProductSendButtonHeight);
    
    NSArray *array = [productModel.extras valueForKey:@"content"];
    if (![UMCHelper isBlankString:array.firstObject]) {
        self.productDetailLabel.text = array.firstObject;
    }
    
    //背景
    self.productBackGroundView.frame = CGRectMake(0, 0, kUMCScreenWidth, kUDProductHeight);
}

- (void)sendProductUrlAction:(UIButton *)button {
    
    if (self.didTapProductSendBlock) {
        self.didTapProductSendBlock(self.productModel);
    }
}

@end
