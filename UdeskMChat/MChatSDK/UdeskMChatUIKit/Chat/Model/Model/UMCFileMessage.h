//
//  UMCFileMessage.h
//  UdeskMChat
//
//  Created by xuchen on 2020/7/2.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCBaseMessage.h"

NS_ASSUME_NONNULL_BEGIN

@interface UMCFileMessage : UMCBaseMessage

@property (nonatomic, assign, readonly) CGRect iconFrame;
@property (nonatomic, assign, readonly) CGRect nameFrame;
@property (nonatomic, assign, readonly) CGRect sizeFrame;
@property (nonatomic, assign, readonly) CGRect proressFrame;
@property (nonatomic, strong, readonly) UIImage *fileIcon;

@end

NS_ASSUME_NONNULL_END
