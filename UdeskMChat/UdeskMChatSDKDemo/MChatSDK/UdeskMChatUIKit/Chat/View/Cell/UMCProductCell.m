//
//  UMCProductCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCProductCell.h"
#import "UMCProductMessage.h"
#import "UMCHelper.h"
#import "UMCSDKConfig.h"
#import "UMCUIMacro.h"

#import "UIImageView+WebCache.h"

@interface UMCProductCell()

@property (nonatomic, strong) UMCProductMessage   *productMessage;
@property (nonatomic, strong) UIView              *productBackGroundView;
@property (nonatomic, strong) UIImageView         *productImageView;
@property (nonatomic, strong) UILabel             *productTitleLabel;
@property (nonatomic, strong) UILabel             *productDetailLabel;
@property (nonatomic, strong) UIButton            *productSendButton;

@end

@implementation UMCProductCell

- (void)updateCellWithMessage:(id)message {
    
    @try {
        
        UMCProductMessage *productMessage = (UMCProductMessage *)message;
        _productMessage = productMessage;
        
        if (![UMCHelper isBlankString:productMessage.productTitle]) {
            self.productTitleLabel.text = productMessage.productTitle;
        }
        
        if (![UMCHelper isBlankString:productMessage.productDetail]) {
            self.productDetailLabel.text = productMessage.productDetail;
        }
        
        if (![UMCHelper isBlankString:productMessage.productSendText]) {
            [self.productSendButton setTitle:productMessage.productSendText forState:UIControlStateNormal];
        }
        
        [self.productImageView sd_setImageWithURL:[NSURL URLWithString:productMessage.productImageURL] placeholderImage:productMessage.productImage];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    self.productBackGroundView.frame = self.productMessage.productFrame;
    self.productImageView.frame = self.productMessage.productImageFrame;
    self.productTitleLabel.frame = self.productMessage.productTitleFrame;
    self.productDetailLabel.frame = self.productMessage.productDetailFrame;
    self.productSendButton.frame = self.productMessage.productSendFrame;
}

- (UIView *)productBackGroundView {
    
    if (!_productBackGroundView) {
        _productBackGroundView = [[UIView alloc] initWithFrame:CGRectZero];
        _productBackGroundView.backgroundColor = [UMCSDKConfig sharedConfig].sdkStyle.productBackGroundColor;
        [self.contentView addSubview:_productBackGroundView];
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

- (void)sendProductUrlAction:(UIButton *)button {
    
    if (self.delegate) {
        if ([self.delegate respondsToSelector:@selector(sendProductURL:)]) {
            [self.delegate sendProductURL:self.productMessage.productURL];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
