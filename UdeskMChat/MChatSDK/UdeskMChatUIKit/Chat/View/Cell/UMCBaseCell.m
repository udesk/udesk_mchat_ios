//
//  UMCBaseCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseCell.h"
#import "UMCUIMacro.h"
#import "UMCSDKConfig.h"
#import "UIImage+UMC.h"
#import "NSDate+UMC.h"
#import "UIView+UMC.h"

#import "Udesk_YYWebImage.h"

@implementation UMCBaseCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.umcWidth = kUMCScreenWidth;
    }
    return self;
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    if (!baseMessage || baseMessage == (id)kCFNull) return ;
    self.baseMessage = baseMessage;

    //头像位置
    self.avatarImageView.frame = baseMessage.avatarFrame;
    //头像图片
    NSString *avatarUrl = [UMCSDKConfig sharedConfig].merchantImageURL;
    UIImage *avatarImage = [UMCSDKConfig sharedConfig].merchantImage;

    if (baseMessage.message.direction == UMCMessageDirectionIn) {
        avatarUrl = [UMCSDKConfig sharedConfig].customerImageURL;
        avatarImage = [UMCSDKConfig sharedConfig].customerImage;
    }

    [self.avatarImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[avatarUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:avatarImage];
    
    //气泡
    self.bubbleImageView.frame = baseMessage.bubbleFrame;
    self.loadingView.frame = baseMessage.loadingFrame;
    self.resetButton.frame = baseMessage.failureFrame;
    
    //时间
    self.dateLabel.frame = baseMessage.dateFrame;
    if (baseMessage.message.category == UMCMessageCategoryTypeEvent) {
        
        NSString *date = [[NSDate dateWithString:baseMessage.message.createdAt format:kUMCDateFormat] stringWithFormat:kUMCShowDateFormat];
        self.dateLabel.text = [NSString stringWithFormat:@"——— %@ ———",date];
        self.dateLabel.textAlignment = NSTextAlignmentCenter;
        self.dateLabel.umcWidth = self.contentView.umcWidth;
    }
    else {
        self.dateLabel.text = [[NSDate dateWithString:baseMessage.message.createdAt format:kUMCDateFormat] umcStyleDate];
        self.dateLabel.umcBottom = self.bubbleImageView.umcTop - kUDCellBubbleToIndicatorSpacing;
    }
    
    if (baseMessage.message.category == UMCMessageCategoryTypeChat) {
        
        switch (baseMessage.message.direction) {
            case UMCMessageDirectionOut:{
                
                //气泡
                UIImage *bubbleImage = [UMCSDKConfig sharedConfig].sdkStyle.agentBubbleImage;
                
                if ([UMCSDKConfig sharedConfig].sdkStyle.agentBubbleColor) {
                    bubbleImage = [bubbleImage umcConvertImageColor:[UMCSDKConfig sharedConfig].sdkStyle.agentBubbleColor];
                }
                
                self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
                self.dateLabel.textAlignment = NSTextAlignmentLeft;
                self.dateLabel.umcLeft = self.bubbleImageView.umcLeft+kUDArrowMarginWidth;
                
                break;
            }
            case UMCMessageDirectionIn:{
                
                //气泡
                UIImage *bubbleImage = [UMCSDKConfig sharedConfig].sdkStyle.customerBubbleImage;
                if ([UMCSDKConfig sharedConfig].sdkStyle.customerBubbleColor) {
                    bubbleImage = [bubbleImage umcConvertImageColor:[UMCSDKConfig sharedConfig].sdkStyle.customerBubbleColor];
                }
                self.bubbleImageView.image = [bubbleImage stretchableImageWithLeftCapWidth:bubbleImage.size.width*0.5f topCapHeight:bubbleImage.size.height*0.8f];
                //更新位置
                self.dateLabel.textAlignment = NSTextAlignmentRight;
                self.dateLabel.umcRight = self.bubbleImageView.umcRight-kUDArrowMarginWidth;
                
                break;
            }
                
            default:
                break;
        }
        
        [self updateLoding:baseMessage.message.messageStatus];
    }
}

//更新loding
- (void)updateLoding:(UMCMessageStatus)sendStatus {
    
    switch (sendStatus) {
        case UMCMessageStatusFailed:
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            self.resetButton.hidden = NO;
            break;
        case UMCMessageStatusSending:
            [self.loadingView startAnimating];
            self.loadingView.hidden = NO;
            self.resetButton.hidden = YES;
            break;
        case UMCMessageStatusSuccess:
            [self.loadingView stopAnimating];
            self.loadingView.hidden = YES;
            self.resetButton.hidden = YES;
            break;
        default:
            break;
    }
}

//初始化头像
- (UIImageView *)avatarImageView {
    
    if (!_avatarImageView) {
        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.contentMode = UIViewContentModeScaleAspectFit;
        _avatarImageView.userInteractionEnabled = YES;
        kUMCViewRadius(_avatarImageView, 20);
        [self.contentView addSubview:_avatarImageView];
    }
    return _avatarImageView;
}

//初始化气泡
- (UIImageView *)bubbleImageView {
    
    if (!_bubbleImageView) {
        _bubbleImageView = [[UIImageView alloc] init];
        _bubbleImageView.userInteractionEnabled = true;
        [self.contentView addSubview:_bubbleImageView];
    }
    return _bubbleImageView;
}

//时间
- (UILabel *)dateLabel {
    
    if (!_dateLabel) {
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _dateLabel.textColor = [UMCSDKConfig sharedConfig].sdkStyle.chatTimeColor;
        _dateLabel.font = [UMCSDKConfig sharedConfig].sdkStyle.messageTimeFont;
        _dateLabel.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_dateLabel];
    }
    return _dateLabel;
}

//重发
- (UIButton *)resetButton {
    
    if (!_resetButton) {
        _resetButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_resetButton setImage:[UIImage umcDefaultResetButtonImage] forState:UIControlStateNormal];
        [_resetButton addTarget:self action:@selector(tapResetButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_resetButton];
    }
    return _resetButton;
}

//loading
- (UIActivityIndicatorView *)loadingView {
    
    if (!_loadingView) {
        _loadingView = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [self.contentView addSubview:_loadingView];
    }
    return _loadingView;
}

#pragma mark - resetButtonAction
- (void)tapResetButtonAction:(UIButton *)button {
    
    self.resetButton.hidden = YES;
    self.loadingView.hidden = NO;
    [self.loadingView startAnimating];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(resendMessageInCell:resendMessage:)]) {
        [self.delegate resendMessageInCell:self resendMessage:self.baseMessage.message];
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
