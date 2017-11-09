//
//  UMCIMDataSource.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UMCBaseCell.h"

@interface UMCIMDataSource : NSObject <UITableViewDataSource>

@property (nonatomic, strong) NSArray *messagesArray;
@property (nonatomic, weak  ) id<UMCBaseCellDelegate> delegate;

@end
