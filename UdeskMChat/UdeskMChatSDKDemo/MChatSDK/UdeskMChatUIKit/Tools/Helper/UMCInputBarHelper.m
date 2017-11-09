//
//  UMCInputBarHelper.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCInputBarHelper.h"

@implementation UMCInputBarHelper

#pragma mark - 显示功能面板
- (void)inputBarHide:(BOOL)hide
           superView:(UIView *)superView
           tableView:(UMCIMTableView *)tableView
            inputBar:(UMCInputBar *)inputBar
           emojiView:(UMCEmojiView *)emojiView
          recordView:(UMCVoiceRecordView *)recordView
          completion:(void (^)(void))completion {
    
    //根据textViewInputViewType切换功能面板
    [inputBar.inputTextView resignFirstResponder];
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        __block CGRect inputViewFrame = inputBar.frame;
        __block CGRect otherMenuViewFrame = CGRectMake(0, 0, 0, 0);
        
        void (^InputViewAnimation)(BOOL hide) = ^(BOOL hide) {
            inputViewFrame.origin.y = (hide ? (CGRectGetHeight(superView.bounds) - CGRectGetHeight(inputViewFrame)) : (CGRectGetMinY(otherMenuViewFrame) - CGRectGetHeight(inputViewFrame)));
            inputBar.frame = inputViewFrame;
        };
        
        void (^EmotionManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = emojiView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(superView.frame) : (CGRectGetHeight(superView.frame) - CGRectGetHeight(otherMenuViewFrame)));
            emojiView.alpha = !hide;
            emojiView.frame = otherMenuViewFrame;
        };
        
        void (^VoiceManagerViewAnimation)(BOOL hide) = ^(BOOL hide) {
            otherMenuViewFrame = recordView.frame;
            otherMenuViewFrame.origin.y = (hide ? CGRectGetHeight(superView.frame) : (CGRectGetHeight(superView.frame) - CGRectGetHeight(otherMenuViewFrame)));
            recordView.alpha = !hide;
            recordView.frame = otherMenuViewFrame;
            
        };
        
        if (hide) {
            switch (inputBar.selectInputBarType) {
                case UMCInputBarTypeEmotion: {
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UMCInputBarTypeVoice: {
                    VoiceManagerViewAnimation(hide);
                    break;
                }
                case UMCInputBarTypeNormal: {
                    VoiceManagerViewAnimation(hide);
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                default:
                    break;
            }
        } else {
            
            // 这里需要注意block的执行顺序，因为otherMenuViewFrame是公用的对象，所以对于被隐藏的Menu的frame的origin的y会是最大值
            switch (inputBar.selectInputBarType) {
                case UMCInputBarTypeEmotion: {
                    // 1、先隐藏和自己无关的View
                    VoiceManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    EmotionManagerViewAnimation(hide);
                    break;
                }
                case UMCInputBarTypeVoice: {
                    // 1、先隐藏和自己无关的View
                    EmotionManagerViewAnimation(!hide);
                    // 2、再显示和自己相关的View
                    VoiceManagerViewAnimation(hide);
                    break;
                }
                case UMCInputBarTypeNormal: {
                    VoiceManagerViewAnimation(!hide);
                    EmotionManagerViewAnimation(!hide);
                    break;
                }
                default:
                    break;
            }
        }
        
        InputViewAnimation(hide);
        
        [tableView setTableViewInsetsWithBottomValue:superView.umcHeight - inputBar.umcTop];
        [tableView scrollToBottomAnimated:NO];
        
    } completion:^(BOOL finished) {
        if (completion) {
            completion();
        }
    }];
}

@end
