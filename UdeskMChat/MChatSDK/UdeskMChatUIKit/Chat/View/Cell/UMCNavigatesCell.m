//
//  UMCNavigatesCell.m
//  UdeskMChat
//
//  Created by xuchen on 2020/8/4.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCNavigatesCell.h"
#import "UMCNavigatesMessage.h"
#import "UMCSDKConfig.h"
#import "UMCBundleHelper.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>

@interface UMCNavigatesCell()

@property (nonatomic, strong) NSArray *menusArray;

@end

@implementation UMCNavigatesCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    _navDescribeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _navDescribeLabel.numberOfLines = 0;
    _navDescribeLabel.font = [UMCSDKConfig sharedConfig].sdkStyle.messageContentFont;
    _navDescribeLabel.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_navDescribeLabel];
    
    _menuView = [[UIView alloc] initWithFrame:CGRectZero];
    _menuView.backgroundColor = [UIColor clearColor];
    [self.bubbleImageView addSubview:_menuView];
    
    _goBackPreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _goBackPreButton.titleLabel.font = [UIFont systemFontOfSize:12];
    [_goBackPreButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [_goBackPreButton setTitle:UMCLocalizedString(@"udesk_navigate_go_back_pre") forState:UIControlStateNormal];
    [_goBackPreButton addTarget:self action:@selector(navGoBackAction:) forControlEvents:UIControlEventTouchUpInside];
    [_goBackPreButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentRight];
    [self.bubbleImageView addSubview:_goBackPreButton];
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UMCNavigatesMessage *navigatesMessage = (UMCNavigatesMessage *)baseMessage;
    if (!navigatesMessage || ![navigatesMessage isKindOfClass:[UMCNavigatesMessage class]]) return;
    
    self.navDescribeLabel.frame = navigatesMessage.describeFrame;
    self.navDescribeLabel.text = navigatesMessage.message.navDescribe;
    
    self.menuView.frame = navigatesMessage.menuFrame;
    if (navigatesMessage.isShowGoBackPre) {
        self.goBackPreButton.frame = navigatesMessage.goBackPreFrame;
    } else {
        self.goBackPreButton.frame = CGRectZero;
    }
    
    self.bubbleImageView.userInteractionEnabled = self.baseMessage.message.navEnabled;
    self.bubbleImageView.alpha = self.baseMessage.message.navEnabled?1:0.5;
    
    self.menusArray = navigatesMessage.message.navigates;
    while (self.menuView.subviews.count) {
        [self.menuView.subviews.lastObject removeFromSuperview];
    }
    for (UMCNavigate *navigate in self.menusArray) {
        NSInteger index = [self.menusArray indexOfObject:navigate];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index+9347;
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 3;
        button.layer.borderWidth = 1;
        button.layer.borderColor = [UIColor blueColor].CGColor;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [button setTitle:navigate.itemName forState:UIControlStateNormal];
        button.frame = CGRectMake(0, kUDNavVerticalEdgeSpacing*index+(index*30), CGRectGetWidth(self.menuView.frame), 30);
        [button addTarget:self action:@selector(menuTapAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.menuView addSubview:button];
    }
}

- (void)menuTapAction:(UIButton *)button {
    
    NSInteger index = button.tag-9347;
    if (!self.menusArray || !self.menusArray.count || self.menusArray.count<index) {
        return;
    }
    UMCNavigate *navigate = self.menusArray[index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapNavigate:navigate:)]) {
        [self.delegate didTapNavigate:self navigate:navigate];
    }
    
    [self updateNavMessageEnabled];
}

- (void)navGoBackAction:(UIButton *)button {
    if (!self.menusArray || !self.menusArray.count) return;
    
    UMCNavigate *navigate = self.menusArray.firstObject;
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapNavGoback:parentId:)]) {
        [self.delegate didTapNavGoback:self parentId:navigate.parentId];
    }
    [self updateNavMessageEnabled];
}

- (void)updateNavMessageEnabled {
    
    self.baseMessage.message.navEnabled = NO;
    self.bubbleImageView.userInteractionEnabled = NO;
    self.bubbleImageView.alpha = 0.5;
    [UMCManager storeMessage:self.baseMessage.message];
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
