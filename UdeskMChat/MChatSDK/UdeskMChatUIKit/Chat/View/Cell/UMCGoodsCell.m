//
//  UMCGoodsCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2018/6/27.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCGoodsCell.h"
#import "UMCGoodsMessage.h"
#import "UMCSDKConfig.h"
#import "UMCHelper.h"

#import "UDTTTAttributedLabel.h"
#import "Udesk_YYWebImage.h"

@interface UMCGoodsCell()<UDTTTAttributedLabelDelegate>

@property (nonatomic, strong) UDTTTAttributedLabel *goodsMessageLabel;
@property (nonatomic, strong) UIImageView        *goodsMessageImageView;

@end

@implementation UMCGoodsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setup];
    }
    return self;
}

- (void)setup {
    
    _goodsMessageLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectZero];
    _goodsMessageLabel.numberOfLines = 0;
    _goodsMessageLabel.delegate = self;
    _goodsMessageLabel.textAlignment = NSTextAlignmentLeft;
    _goodsMessageLabel.userInteractionEnabled = true;
    _goodsMessageLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_goodsMessageLabel];
    
    _goodsMessageImageView = [[UIImageView alloc] init];
    _goodsMessageImageView.userInteractionEnabled = true;
    [self.bubbleImageView addSubview:_goodsMessageImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGoodsBunbbleAction)];
    [self.bubbleImageView addGestureRecognizer:tap];
}

//点击商品消息
- (void)didTapGoodsBunbbleAction {
    
    UMCGoodsMessage *goodsMessage = (UMCGoodsMessage *)self.baseMessage;
    if (!goodsMessage || ![goodsMessage isKindOfClass:[UMCGoodsMessage class]]) return;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapGoodsMessageCell:goodsURL:)]) {
        [self.delegate didTapGoodsMessageCell:self goodsURL:goodsMessage.url];
    }
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UMCGoodsMessage *goodsMessage = (UMCGoodsMessage *)baseMessage;
    if (!goodsMessage || ![goodsMessage isKindOfClass:[UMCGoodsMessage class]]) return;
    
    self.goodsMessageLabel.text = goodsMessage.cellText;
    
    //设置frame
    self.goodsMessageLabel.frame = goodsMessage.textFrame;
    
    self.goodsMessageImageView.frame = goodsMessage.imageFrame;
    [self.goodsMessageImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[goodsMessage.imgUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage umcDefaultLoadingImage]];
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
