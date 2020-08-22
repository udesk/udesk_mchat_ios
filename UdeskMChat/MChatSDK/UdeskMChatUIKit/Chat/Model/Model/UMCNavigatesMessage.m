//
//  UMCNavigatesMessage.m
//  UdeskMChat
//
//  Created by xuchen on 2020/8/4.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCNavigatesMessage.h"
#import "UMCNavigatesCell.h"
#import "NSString+UMC.h"
#import "UMCSDKConfig.h"

const CGFloat kUDNavHorizontalEdgeSpacing = 10;
const CGFloat kUDNavVerticalEdgeSpacing = 10;
static CGFloat const kUDNavGoBackPreWidth = 100.0;
static CGFloat const kUDNavGoBackPreHeight = 25.0;

@interface UMCNavigatesMessage()

@property (nonatomic, assign, readwrite) CGRect describeFrame;
@property (nonatomic, assign, readwrite) CGRect menuFrame;
@property (nonatomic, assign, readwrite) CGRect goBackPreFrame;
@property (nonatomic, assign, readwrite) BOOL isShowGoBackPre;

@end

@implementation UMCNavigatesMessage

- (instancetype)initWithMessage:(UMCMessage *)message
{
    self = [super initWithMessage:message];
    if (self) {
        
        [self layoutNavigatesMessage];
    }
    return self;
}

- (void)layoutNavigatesMessage {
    
    if (!self.message || !self.message.navigates || self.message.navigates.count<=0) return;
    
    CGFloat navWidth = kUMCScreenWidth>320?235:180;
    if (self.message.navDescribe && [self.message.navDescribe isKindOfClass:[NSString class]] && self.message.navDescribe.length) {
        CGFloat descHeight = [self.message.navDescribe umcHeightForFont:[UMCSDKConfig sharedConfig].sdkStyle.messageContentFont width:navWidth];
        self.describeFrame = CGRectMake(kUDNavHorizontalEdgeSpacing*2, kUDNavVerticalEdgeSpacing, navWidth, descHeight);
    }
    
    self.menuFrame = CGRectMake(kUDNavHorizontalEdgeSpacing*2, CGRectGetMaxY(self.describeFrame)+kUDNavVerticalEdgeSpacing, navWidth, self.message.navigates.count*30+(kUDNavVerticalEdgeSpacing*(self.message.navigates.count-1)));
    
    for (UMCNavigate *navigate in self.message.navigates) {
        if (![navigate.parentId isEqualToString:@"item_0"]) {
            self.isShowGoBackPre = YES;
            continue;
        }
    }
    
    if (self.isShowGoBackPre) {
        self.goBackPreFrame = CGRectMake(CGRectGetMaxX(self.menuFrame)-kUDNavGoBackPreWidth, CGRectGetMaxY(self.menuFrame)+kUDNavVerticalEdgeSpacing, kUDNavGoBackPreWidth, kUDNavGoBackPreHeight);
    } else {
        self.goBackPreFrame = CGRectZero;
    }
    
    CGFloat bubbleHeight = self.isShowGoBackPre ? CGRectGetMaxY(self.goBackPreFrame) : CGRectGetMaxY(self.menuFrame);
    self.bubbleFrame = CGRectMake(self.avatarFrame.origin.x+kUDAvatarDiameter+kUDAvatarToBubbleSpacing, self.dateFrame.origin.y+self.dateFrame.size.height+kUDAvatarToVerticalEdgeSpacing, navWidth+(kUDNavHorizontalEdgeSpacing*3), bubbleHeight+kUDNavVerticalEdgeSpacing);
    
    //cell高度
    self.cellHeight = self.bubbleFrame.size.height+self.bubbleFrame.origin.y+kUDCellBottomMargin;
}

- (UITableViewCell *)getCellWithReuseIdentifier:(NSString *)cellReuseIdentifer {
    return [[UMCNavigatesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellReuseIdentifer];
}

@end
