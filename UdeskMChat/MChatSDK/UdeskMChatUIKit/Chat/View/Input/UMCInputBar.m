//
//  UMCInputBar.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCInputBar.h"
#import "UMCIMTableView.h"
#import "UMCUIMacro.h"
#import "UMCBundleHelper.h"
#import "UMCSDKConfig.h"
#import "UMCCustomButtonConfig.h"
#import "UIImage+UMC.h"
#import "UIView+UMC.h"
#import "UMCPrivacyUtil.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

/** 按钮大小 */
static CGFloat const kInputToolBarIconDiameter = 28.0;
/** 输入框距垂直距离 */
static CGFloat const kChatTextViewToVerticalEdgeSpacing = 8.0;
/** 输入框距的横行距离 */
static CGFloat const kChatTextViewToHorizontalEdgeSpacing = 8.0;
/** 输入框功能按钮横行的间距 */
static CGFloat const kInputToolBarIconToHorizontalEdgeSpacing = 10.0;
/** 输入框按钮距离顶部的垂直距离 */
static CGFloat const kInputToolBarIconToVerticalEdgeSpacing = 12.0;

@interface UMCInputBar()<UITextViewDelegate,UMCCustomToolBarDelegate>

@property (nonatomic, strong) UMCButton *voiceButton;
@property (nonatomic, strong) UMCButton *emotionButton;
@property (nonatomic, strong) UMCButton *moreButton;
@property (nonatomic, strong) UMCButton *recordButton;

@property (nonatomic, strong) UIView             *defaultToolBar;
@property (nonatomic, strong) UMCCustomToolBar *customToolBar;

@property (nonatomic, strong) UMCIMTableView *messageTableView;
@property (nonatomic, assign) CGRect  originalChatViewFrame;
@property (nonatomic, assign) CGFloat textViewHeight;

@property (nonatomic, assign) BOOL isCancelled;
@property (nonatomic, assign) BOOL isRecording;

@end

@implementation UMCInputBar

- (instancetype)initWithFrame:(CGRect)frame tableView:(UMCIMTableView *)tabelView {
    self = [super initWithFrame:frame];
    if (self) {
        
        _messageTableView = tabelView;
        _originalChatViewFrame = tabelView.frame;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    UMCSDKConfig *sdkConfig = [UMCSDKConfig sharedConfig];
    
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    self.backgroundColor = sdkConfig.sdkStyle.inputViewColor;
    
    //默认toolbar
    _defaultToolBar = [[UIView alloc] init];
    _defaultToolBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:_defaultToolBar];
    
    //语音
    _voiceButton = [[UMCButton alloc] init];
    _voiceButton.hidden = sdkConfig.hiddenVoiceButton;
    [_voiceButton setImage:[UIImage umcDefaultVoiceImage] forState:UIControlStateNormal];
    [_voiceButton setImage:[UIImage umcDefaultKeyboardImage] forState:UIControlStateSelected];
    [_voiceButton addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    if (!sdkConfig.hiddenVoiceButton) {
        [_defaultToolBar addSubview:_voiceButton];
    }
    
    //初始化输入框
    _inputTextView = [[UdeskHPGrowingTextView alloc] initWithFrame:CGRectZero];
    _inputTextView.placeholder = UMCLocalizedString(@"udesk_typing");
    _inputTextView.delegate = (id)self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.backgroundColor = sdkConfig.sdkStyle.textViewColor;
    [_defaultToolBar addSubview:_inputTextView];
    kUMCViewBorderRadius(_inputTextView, 5, 0.5, [UIColor colorWithRed:0.831f  green:0.835f  blue:0.843f alpha:1]);
    
    _recordButton = [[UMCButton alloc] init];
    _recordButton.alpha = _voiceButton.selected;
    _recordButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [_recordButton setTitleColor:[UIColor colorWithRed:0.392f  green:0.392f  blue:0.396f alpha:1] forState:UIControlStateNormal];
    [_recordButton setTitle:UMCLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchDown:) forControlEvents:UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchUpOutside:) forControlEvents:UIControlEventTouchUpOutside];
    [_recordButton addTarget:self action:@selector(holdDownButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    [_recordButton addTarget:self action:@selector(holdDownDragOutside:) forControlEvents:UIControlEventTouchDragExit];
    [_recordButton addTarget:self action:@selector(holdDownDragInside:) forControlEvents:UIControlEventTouchDragEnter];
    [_defaultToolBar addSubview:_recordButton];
    kUMCViewBorderRadius(_recordButton, 5, 0.5, [UIColor colorWithRed:0.831f  green:0.835f  blue:0.843f alpha:1]);
    
    //表情
    _emotionButton = [[UMCButton alloc] init];
    _emotionButton.hidden = sdkConfig.hiddenEmotionButton;
    [_emotionButton setImage:[UIImage umcDefaultSmileImage] forState:UIControlStateNormal];
    [_emotionButton setImage:[UIImage umcDefaultKeyboardImage] forState:UIControlStateSelected];
    [_emotionButton addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
    if (!sdkConfig.hiddenEmotionButton) {
        [_defaultToolBar addSubview:_emotionButton];
    }
    
    //更多
    _moreButton = [[UMCButton alloc] init];
    [_moreButton setImage:[UIImage umcDefaultMoreImage] forState:UIControlStateNormal];
    [_moreButton addTarget:self action:@selector(moreClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_moreButton];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    UMCSDKConfig *sdkConfig = [UMCSDKConfig sharedConfig];
    
    //用户自定义按钮
    CGFloat customToolBarHeight = 0;
    if (_customToolBar) {
        if (!_customToolBar.hidden) {
            _customToolBar.frame = CGRectMake(0, 0, self.umcWidth, 44);
            customToolBarHeight = 44;
        }
    }
    
    _defaultToolBar.frame = CGRectMake(0, customToolBarHeight, self.umcWidth, self.umcHeight - customToolBarHeight - (kUMCIPhoneXSeries?34:0));
    
    //计算textview的width
    CGFloat textViewWidth = self.umcWidth - (kInputToolBarIconToHorizontalEdgeSpacing*2);
    
    if (!sdkConfig.hiddenVoiceButton && !_voiceButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    if (!sdkConfig.hiddenEmotionButton && !_emotionButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    if (!_moreButton.hidden) {
        textViewWidth -= kInputToolBarIconDiameter;
        textViewWidth -= kInputToolBarIconToHorizontalEdgeSpacing;
    }
    
    //当textview height发生改变时button位置不改变
    if (_defaultToolBar.umcHeight <= 52) {
        
        if (!sdkConfig.hiddenVoiceButton && !_voiceButton.hidden) {
            _voiceButton.frame = CGRectMake(kInputToolBarIconToHorizontalEdgeSpacing, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
        
        if (!_moreButton.hidden) {
            _moreButton.frame = CGRectMake(_defaultToolBar.umcRight-kInputToolBarIconToHorizontalEdgeSpacing-kInputToolBarIconDiameter, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
        
        if (!sdkConfig.hiddenEmotionButton && !_emotionButton.hidden) {
            _emotionButton.frame = CGRectMake(_moreButton.umcLeft - kInputToolBarIconToHorizontalEdgeSpacing - kInputToolBarIconDiameter, kInputToolBarIconToVerticalEdgeSpacing, kInputToolBarIconDiameter, kInputToolBarIconDiameter);
        }
    }
    
    _inputTextView.frame = CGRectMake((_voiceButton.hidden?0:_voiceButton.umcRight) + kChatTextViewToHorizontalEdgeSpacing, kChatTextViewToVerticalEdgeSpacing, textViewWidth, _defaultToolBar.umcHeight - kChatTextViewToVerticalEdgeSpacing - kChatTextViewToHorizontalEdgeSpacing);
    _recordButton.frame = _inputTextView.frame;
}

//点击语音
- (void)voiceClick:(UMCButton *)button {
    
    [UMCPrivacyUtil checkPermissionsOfMicrophone:^{
        
        button.selected = !button.selected;
        self.selectInputBarType = UMCInputBarTypeVoice;
        self.emotionButton.selected = NO;
        self.moreButton.selected = NO;
        self.recordButton.alpha = button.selected;
        self.inputTextView.alpha = !button.selected;
        if ([self.delegate respondsToSelector:@selector(didSelectVoice:)]) {
            [self.delegate didSelectVoice:button];
        }
    }];
}

//点击表情按钮
- (void)emotionClick:(UMCButton *)button {
    
    button.selected = !button.selected;
    self.selectInputBarType = UMCInputBarTypeEmotion;
    self.voiceButton.selected = NO;
    self.moreButton.selected = NO;
    if (button.selected) {
        self.recordButton.alpha = 0;
        self.inputTextView.alpha = 1;
    }
    if ([self.delegate respondsToSelector:@selector(didSelectEmotion:)]) {
        [self.delegate didSelectEmotion:button];
    }
}

//点击更多
- (void)moreClick:(UMCButton *)button {
    
    button.selected = !button.selected;
    self.selectInputBarType = UMCInputBarTypeMore;
    self.voiceButton.selected = NO;
    self.emotionButton.selected = NO;
    if (button.selected) {
        self.recordButton.alpha = 0;
        self.inputTextView.alpha = 1;
    }
    if ([self.delegate respondsToSelector:@selector(didSelectMore:)]) {
        [self.delegate didSelectMore:button];
    }
}

//按下
- (void)holdDownButtonTouchDown:(UMCButton *)button {
    
    [button setTitle:UMCLocalizedString(@"udesk_release_to_send") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor colorWithRed:0.776f  green:0.78f  blue:0.792f alpha:1];
    
    self.isCancelled = NO;
    self.isRecording = NO;
    if ([self.delegate respondsToSelector:@selector(prepareRecordingVoiceActionWithCompletion:)]) {
        @udWeakify(self);
        [self.delegate prepareRecordingVoiceActionWithCompletion:^BOOL{
            @udStrongify(self);
            if (self && !self.isCancelled) {
                self.isRecording = YES;
                [self.delegate didStartRecordingVoiceAction];
                return YES;
            } else {
                return NO;
            }
        }];
    }
}

//在按钮边界外松开
- (void)holdDownButtonTouchUpOutside:(UMCButton *)button {
    
    [button setTitle:UMCLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didCancelRecordingVoiceAction)]) {
            [self.delegate didCancelRecordingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

//松开
- (void)holdDownButtonTouchUpInside:(UMCButton *)button {
    
    [button setTitle:UMCLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    button.backgroundColor = [UIColor whiteColor];
    
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didFinishRecoingVoiceAction)]) {
            [self.delegate didFinishRecoingVoiceAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

//离开按钮边界
- (void)holdDownDragOutside:(UMCButton *)button {
    
    [button setTitle:UMCLocalizedString(@"udesk_release_to_cancel") forState:UIControlStateNormal];
    
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragOutsideAction)]) {
            [self.delegate didDragOutsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

//进入按钮区域
- (void)holdDownDragInside:(UMCButton *)button {
    
    [button setTitle:UMCLocalizedString(@"udesk_release_to_send") forState:UIControlStateNormal];
    if (self.isRecording) {
        if ([self.delegate respondsToSelector:@selector(didDragInsideAction)]) {
            [self.delegate didDragInsideAction];
        }
    } else {
        self.isCancelled = YES;
    }
}

#pragma mark - Text view delegate
- (BOOL)growingTextViewShouldBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    
    self.selectInputBarType = UMCInputBarTypeText;
    
    if ([self.inputTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.inputTextView.text isEqualToString:UMCLocalizedString(@"udesk_typing")]) {
        self.inputTextView.text = @"";
        self.inputTextView.textColor = [UIColor blackColor];
    }
    
    self.emotionButton.selected = NO;
    self.voiceButton.selected = NO;
    
    return YES;
}

- (void)growingTextViewDidBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView becomeFirstResponder];
}

- (void)growingTextViewDidEndEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView resignFirstResponder];
}

- (BOOL)growingTextView:(UdeskHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    self.selectInputBarType = UMCInputBarTypeText;
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(didSendText:)]) {
            [self.delegate didSendText:growingTextView.text];
        }
        self.inputTextView.text = @"";
        return NO;
    }
    return YES;
}

- (void)growingTextView:(UdeskHPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    
    float diff = (self.inputTextView.frame.size.height - height);
    //确保tableView的y不大于原始的y
    CGFloat tableViewOriginY = self.messageTableView.frame.origin.y + diff;
    if (tableViewOriginY > self.originalChatViewFrame.origin.y) {
        tableViewOriginY = self.originalChatViewFrame.origin.y;
    }
    
    self.messageTableView.frame = CGRectMake(self.messageTableView.frame.origin.x, tableViewOriginY, self.messageTableView.frame.size.width, self.messageTableView.frame.size.height);
    self.frame = CGRectMake(0, self.frame.origin.y + diff, self.frame.size.width, self.frame.size.height - diff);
    //按钮靠下
    [self updateButtonBottom:-diff];
}

- (void)updateButtonBottom:(CGFloat)diff {
    
    self.emotionButton.umcTop += diff;
    self.voiceButton.umcTop += diff;
    self.moreButton.umcTop += diff;
}

- (void)setCustomButtonConfigs:(NSArray<UMCCustomButtonConfig *> *)customButtonConfigs {
    if (!customButtonConfigs || customButtonConfigs == (id)kCFNull) return ;
    if (![customButtonConfigs isKindOfClass:[NSArray class]]) return ;
    if (![customButtonConfigs.firstObject isKindOfClass:[UMCCustomButtonConfig class]]) return ;
    if (![UMCSDKConfig sharedConfig].showCustomButtons) return;
    
    //没有在输入框上方的自定义按钮
    NSArray *types = [customButtonConfigs valueForKey:@"type"];
    if (![types containsObject:@0]) return;
    
    _customButtonConfigs = customButtonConfigs;
    
    _customToolBar = [[UMCCustomToolBar alloc] initWithFrame:CGRectZero customButtonConfigs:customButtonConfigs];
    _customToolBar.delegate = self;
    [self addSubview:_customToolBar];
    
    self.frame = CGRectMake(0, self.frame.origin.y - 44, self.frame.size.width, self.frame.size.height + 44);
    [self.messageTableView setTableViewInsetsWithBottomValue:self.umcHeight];
}

#pragma mark - @protocol UMCCustomToolBarDelegate
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomToolBar:atIndex:)]) {
        [self.delegate didSelectCustomToolBar:toolBar atIndex:index];
    }
}

//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage {
    
    self.voiceButton.hidden = YES;
    self.emotionButton.hidden = YES;
    self.moreButton.hidden = YES;
    self.recordButton.alpha = 0;
    self.inputTextView.alpha = 1;
    self.selectInputBarType = UMCInputBarTypeText;
    
    if (self.customToolBar) {
        self.customToolBar.hidden = YES;
        self.frame = CGRectMake(0, self.frame.origin.y + 44, self.frame.size.width, self.frame.size.height - 44);
        [self.messageTableView setTableViewInsetsWithBottomValue:self.umcHeight];
    }
}

//重置录音按钮
- (void)resetRecordButton {
    [self.recordButton setTitle:UMCLocalizedString(@"udesk_hold_to_talk") forState:UIControlStateNormal];
    self.recordButton.backgroundColor = [UIColor whiteColor];
}

@end
