//
//  UMCBaseCell.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCBaseMessage.h"

@protocol UMCBaseCellDelegate <NSObject>

//重发消息
- (void)resendMessageInCell:(UITableViewCell *)cell resendMessage:(UMCMessage *)resendMessage;

@end

@interface UMCBaseCell : UITableViewCell

@property (nonatomic, weak) id<UMCBaseCellDelegate> delegate;

/** 客户头像 */
@property (nonatomic, strong) UIImageView *avatarImageView;
/** 气泡 */
@property (nonatomic, strong) UIImageView *bubbleImageView;
/** 时间 */
@property (nonatomic, strong) UILabel     *dateLabel;
/** 重发 */
@property (nonatomic, strong) UIButton    *resetButton;
/** loading */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
/** 数据 */
@property (nonatomic, strong) UMCBaseMessage  *baseMessage;

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage;

//更新loding
- (void)updateLoding:(UMCMessageStatus)sendStatus;

@end
