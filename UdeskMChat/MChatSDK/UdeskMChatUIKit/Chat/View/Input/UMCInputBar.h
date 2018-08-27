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
@class UMCIMTableView;
@class UMCInputBar;
@class UMCCustomButtonConfig;

typedef NS_ENUM(NSUInteger, UMCInputBarType) {
    UMCInputBarTypeNormal = 0,
    UMCInputBarTypeText,
    UMCInputBarTypeEmotion,
    UMCInputBarTypeImage,
    UMCInputBarTypeVoice,
};

@protocol UMCInputBarDelegate <NSObject>

@optional
/**
 *  输入框将要开始编辑
 *
 *  @param textView 输入框对象
 */
- (void)inputBar:(UMCInputBar *)inputBar willBeginEditing:(UdeskHPGrowingTextView *)textView;
/** 点击自定义按钮 */
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index;

@required
/**
 *  选择图片
 *
 *  @param sourceType 相册or相机
 */
- (void)inputBar:(UMCInputBar *)inputBar didSelectImageWithSourceType:(UIImagePickerControllerSourceType)sourceType;

/**
 *  发送文本消息，包括系统的表情
 *
 *  @param text 目标文本消息
 */
- (void)inputBar:(UMCInputBar *)inputBar didSendText:(NSString *)text;

/**
 *  显示表情
 */
- (void)inputBar:(UMCInputBar *)inputBar didSelectEmotion:(UIButton *)emotionButton;

/**
 *  点击语音
 */
- (void)inputBar:(UMCInputBar *)inputBar didSelectVoice:(UIButton *)voiceButton;

/**
 *  点击评价
 */
- (void)inputBar:(UMCInputBar *)inputBar didSelectSurvey:(UIButton *)surveyButton;

@end

@interface UMCInputBar : UIView

@property (nonatomic, strong) UdeskHPGrowingTextView *inputTextView;

@property (nonatomic, weak) id <UMCInputBarDelegate> delegate;

@property (nonatomic, assign) UMCInputBarType selectInputBarType;

@property (nonatomic, strong) NSArray<UMCCustomButtonConfig *> *customButtonConfigs;

@property (nonatomic, assign) BOOL     hiddenVoiceButton;
@property (nonatomic, assign) BOOL     hiddenEmotionButton;
@property (nonatomic, assign) BOOL     hiddenCameraButton;
@property (nonatomic, assign) BOOL     hiddenAlbumButton;
@property (nonatomic, assign) BOOL     showCustomButtons;
@property (nonatomic, assign) BOOL     isShowSurvey;

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UMCIMTableView *)tabelView;

//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage;

@end
