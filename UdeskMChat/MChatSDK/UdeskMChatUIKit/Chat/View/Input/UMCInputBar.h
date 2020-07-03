//
//  UMCInputBar.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UdeskHPGrowingTextView.h"
#import "UMCCustomToolBar.h"
#import "UMCButton.h"

@class UMCIMTableView;
@class UMCInputBar;
@class UMCCustomButtonConfig;

typedef NS_ENUM(NSUInteger, UMCInputBarType) {
    UMCInputBarTypeNormal = 0,
    UMCInputBarTypeText,
    UMCInputBarTypeEmotion,
    UMCInputBarTypeVoice,
    UMCInputBarTypeMore,
};

@protocol UMCInputBarDelegate <NSObject>

/** 输入框将要开始编辑 */
//- (void)chatTextViewShouldBeginEditing:(UdeskHPGrowingTextView *)chatTextView;
/** 发送文本消息，包括系统的表情 */
- (void)didSendText:(NSString *)text;
/** 点击语音 */
- (void)didSelectVoice:(UMCButton *)voiceButton;
/** 点击表情 */
- (void)didSelectEmotion:(UMCButton *)emotionButton;
/** 点击更多 */
- (void)didSelectMore:(UMCButton *)moreButton;
/** 点击自定义按钮 */
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index;

/** 准备录音 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion;
/** 开始录音 */
- (void)didStartRecordingVoiceAction;
/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction;
/** 松开手指完成录音 */
- (void)didFinishRecoingVoiceAction;
/** 当手指离开按钮的范围内时 */
- (void)didDragOutsideAction;
/** 当手指再次进入按钮的范围内时 */
- (void)didDragInsideAction;

@end

@interface UMCInputBar : UIView

@property (nonatomic, strong) UdeskHPGrowingTextView *inputTextView;

@property (nonatomic, weak) id <UMCInputBarDelegate> delegate;

@property (nonatomic, assign) UMCInputBarType selectInputBarType;

@property (nonatomic, strong) NSArray<UMCCustomButtonConfig *> *customButtonConfigs;

- (instancetype)initWithFrame:(CGRect)frame tableView:(UMCIMTableView *)tabelView;

//重置录音按钮
- (void)resetRecordButton;
//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage;

@end
