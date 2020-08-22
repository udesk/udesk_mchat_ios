//
//  UMCNavigatesMessage.h
//  UdeskMChat
//
//  Created by xuchen on 2020/8/4.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

extern const CGFloat kUDNavHorizontalEdgeSpacing;
extern const CGFloat kUDNavVerticalEdgeSpacing;

@interface UMCNavigatesMessage : UMCBaseMessage

@property (nonatomic, assign, readonly) CGRect describeFrame;
@property (nonatomic, assign, readonly) CGRect menuFrame;
@property (nonatomic, assign, readonly) CGRect goBackPreFrame;
@property (nonatomic, assign, readonly) BOOL isShowGoBackPre;

@end

NS_ASSUME_NONNULL_END
