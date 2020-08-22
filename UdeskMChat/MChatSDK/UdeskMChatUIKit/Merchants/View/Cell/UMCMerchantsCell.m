//
//  UMCMerchantsCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCMerchantsCell.h"
#import "UIView+UMC.h"
#import "UMCUIMacro.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "NSDate+UMC.h"
#import "UIImage+UMC.h"
#import "UMCBundleHelper.h"
#import "UIColor+UMC.h"
#import "UMCHelper.h"

#import "Udesk_YYWebImage.h"
#import "Udesk_JSCustomBadge.h"
#import "UDTTTAttributedLabel.h"

/** 商户视图之间的空隙 */
static CGFloat const kUDMerchantPadding = 10.0;
/** 商户头像大小 */
static CGFloat const kUDMerchantAvatarDiameter = 45.0;
/** 商户时间长度 */
static CGFloat const kUDMerchantTimeWidth = 170.0;
/** 商户时间高度 */
static CGFloat const kUDMerchantTimeHeight = 17;
/** 商户昵称高度 */
static CGFloat const kUDMerchantNickNameHeight = 23;
/** 商户最后一条消息高度 */
static CGFloat const kUDMerchantLastContentTextHeight = 23;
/** 未读消息 */
static CGFloat const kUDMerchantUnreadY = 5;

@interface UMCMerchantsCell()

@property (nonatomic, strong) UIImageView   *avatarImageView;
@property (nonatomic, strong) UILabel       *nickNameLabel;
@property (nonatomic, strong) UILabel       *dateLabel;
@property (nonatomic, strong) Udesk_JSCustomBadge *badgeView;
@property (nonatomic, strong) UDTTTAttributedLabel  *contentLabel;

@end

@implementation UMCMerchantsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        self.contentView.umcWidth = kUMCScreenWidth;
        [self setup];
    }
    
    return self;
}

- (void)setup {
    
    //时间
    _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.contentView.umcRight-kUDMerchantTimeWidth-kUDMerchantPadding, kUDMerchantPadding, kUDMerchantTimeWidth, kUDMerchantTimeHeight)];
    _dateLabel.umcRight = self.contentView.umcRight-kUDMerchantPadding;
    _dateLabel.font = [UIFont systemFontOfSize:12.f];
    _dateLabel.textColor = [UIColor grayColor];
    _dateLabel.textAlignment = NSTextAlignmentRight;
    _dateLabel.highlightedTextColor = _dateLabel.textColor;
    [self.contentView addSubview:_dateLabel];
    
    //头像
    _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(kUDMerchantPadding, kUDMerchantPadding, kUDMerchantAvatarDiameter, kUDMerchantAvatarDiameter)];
    _avatarImageView.userInteractionEnabled = YES;
    [self.contentView addSubview:_avatarImageView];
    
    //名字
    _nickNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.umcRight+kUDMerchantPadding, kUDMerchantPadding, kUMCScreenWidth-_dateLabel.umcWidth-_avatarImageView.umcWidth-(kUDMerchantPadding*4), kUDMerchantNickNameHeight)];
    _nickNameLabel.font = [UIFont systemFontOfSize:16.f];
    _nickNameLabel.textColor = [UIColor umcColorWithHexString:@"#333333"];
    [self.contentView addSubview:_nickNameLabel];
    
    //最后一条消息
    _contentLabel = [[UDTTTAttributedLabel alloc] initWithFrame:CGRectMake(_nickNameLabel.umcLeft, _nickNameLabel.umcBottom, kUMCScreenWidth-_avatarImageView.umcWidth-(kUDMerchantPadding*3), kUDMerchantLastContentTextHeight)];
    _contentLabel.userInteractionEnabled = YES;
    _contentLabel.font = [UIFont systemFontOfSize:14.f];
    _contentLabel.textColor = [UIColor umcColorWithHexString:@"#999999"];
    [self.contentView addSubview:_contentLabel];
    
    //未读条数view
    _badgeView = [Udesk_JSCustomBadge customBadgeWithString:nil
                                           withStringColor:[UIColor whiteColor]
                                            withInsetColor:[UIColor redColor]
                                            withBadgeFrame:YES
                                       withBadgeFrameColor:[UIColor redColor]
                                                 withScale:.8f
                                               withShining:NO
                                                withShadow:NO];
    
    _badgeView.umcOrigin = CGPointMake(kUDMerchantAvatarDiameter-kUDMerchantPadding, kUDMerchantUnreadY);
    [self.contentView addSubview:_badgeView];
}

- (void)setMerchant:(UMCMerchant *)merchant {
    _merchant = merchant;
    
    self.dateLabel.text = [[NSDate dateWithString:merchant.lastMessage.createdAt format:kUMCDateFormat] umcStyleDate];
    [self.avatarImageView udesk_yy_setImageWithURL:[NSURL URLWithString:[merchant.logoURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholder:[UIImage umcContactsMerchantAvatarImage]];
    self.nickNameLabel.text = merchant.name;
    self.contentLabel.text = [self getLastMessageContent:merchant.lastMessage];
    
    //有该用户的未读消息时显示badgeView
    if ([merchant.unreadCount integerValue] > 0) {
        self.badgeView.hidden = NO;
        
        NSString *unreadFlag = [merchant.unreadCount integerValue] < 100?merchant.unreadCount:@"99+";
        [self.badgeView autoBadgeSizeWithString:unreadFlag];
        [self.contentView bringSubviewToFront:self.badgeView];
    }
    else {
        self.badgeView.hidden = YES;
    }
}

- (NSString *)getLastMessageContent:(UMCMessage *)message {
    
    //撤回消息
    if (message.category == UMCMessageCategoryTypeEvent && message.eventType == UMCEventContentTypeRollback) {
        return UMCLocalizedString(@"udesk_rollback");
    }
    
    switch (message.contentType) {
        case UMCMessageContentTypeText:
            return [UMCHelper filterHTML:message.content];
            break;
        case UMCMessageContentTypeImage:
            return UMCLocalizedString(@"udesk_last_image");
            break;
        case UMCMessageContentTypeVoice:
            return UMCLocalizedString(@"udesk_last_voice");
            break;
        case UMCMessageContentTypeGoods:
            return UMCLocalizedString(@"udesk_last_goods");
            break;
        case UMCMessageContentTypeVideo:
            return UMCLocalizedString(@"udesk_last_video");
            break;
        case UMCMessageContentTypeFile:
            return UMCLocalizedString(@"udesk_last_file");
            break;
            
        default:
            break;
    }
    return message.content;
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
