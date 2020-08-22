//
//  UMCNavigatesCell.h
//  UdeskMChat
//
//  Created by xuchen on 2020/8/4.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface UMCNavigatesCell : UMCBaseCell

@property (nonatomic, strong) UILabel *navDescribeLabel;
@property (nonatomic, strong) UIView  *menuView;
@property (nonatomic, strong) UIButton  *goBackPreButton;

@end

NS_ASSUME_NONNULL_END
