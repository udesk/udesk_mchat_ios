//
//  UMCInputBarHelper.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMCInputBar.h"
#import "UMCEmojiView.h"
#import "UMCVoiceRecordView.h"
#import "UMCIMTableView.h"
#import "UIView+UMC.h"

@interface UMCInputBarHelper : NSObject

- (void)inputBarHide:(BOOL)hide
           superView:(UIView *)superView
           tableView:(UMCIMTableView *)tableView
            inputBar:(UMCInputBar *)inputBar
           emojiView:(UMCEmojiView *)emojiView
          recordView:(UMCVoiceRecordView *)recordView
          completion:(void (^)(void))completion;

@end
