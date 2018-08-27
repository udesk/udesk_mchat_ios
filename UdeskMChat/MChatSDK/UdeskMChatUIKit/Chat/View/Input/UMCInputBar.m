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
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/ALAssetsLibrary.h>

/** 按钮大小 */
static CGFloat const UDInputBarViewButtonDiameter = 30.0;
/** 输入框高度 */
static CGFloat const UDInputBarViewHeight = 37.0;
/** 输入框距离顶部的垂直距离 */
static CGFloat const UDInputBarViewToVerticalEdgeSpacing = 5.0;
/** 输入框距离顶部的横行距离 */
static CGFloat const UDInputBarViewToHorizontalEdgeSpacing = 10.0;
/** 输入框功能按钮横行的间距 */
static CGFloat const UDInputBarViewButtonToHorizontalEdgeSpacing = 20.0;
/** 输入框按钮距离顶部的垂直距离 */
static CGFloat const UDInputBarViewButtonToVerticalEdgeSpacing = 45.0;
/** 自定义按钮高度 */
static CGFloat const UDInputBarViewCustomToolBarHeight = 44.0;

@interface UMCInputBar()<UITextViewDelegate,UMCCustomToolBarDelegate>

@property (nonatomic, strong) UIButton *emotionButton;
@property (nonatomic, strong) UIButton *voiceButton;
@property (nonatomic, strong) UIButton *cameraButton;
@property (nonatomic, strong) UIButton *albumButton;
@property (nonatomic, strong) UIButton *surveyButton;
@property (nonatomic, strong) UMCIMTableView *imTableView;
@property (nonatomic, assign) CGRect originalTableViewFrame;
@property (nonatomic, assign) NSInteger textViewHeight;
@property (nonatomic, strong) UMCCustomToolBar *customToolBar;
@property (nonatomic, strong) UIView *defaultToolBar;

@end

@implementation UMCInputBar

- (instancetype)initWithFrame:(CGRect)frame
                    tableView:(UMCIMTableView *)tabelView {
    self = [super initWithFrame:frame];
    if (self) {
        
        _imTableView = tabelView;
        _originalTableViewFrame = tabelView.frame;
        [self setup];
    }
    return self;
}

- (void)setup {
    // 配置自适应
    self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin);
    self.opaque = YES;
    [self loadFuncationView];
}

- (void)loadFuncationView {
    
    //默认toolbar
    _defaultToolBar = [[UIView alloc] initWithFrame:CGRectMake(0, 1, self.frame.size.width, self.frame.size.height-1)];
    _defaultToolBar.backgroundColor = [UIColor whiteColor];
    [self addSubview:_defaultToolBar];
    
    //初始化输入框
    _inputTextView = [[UdeskHPGrowingTextView  alloc] initWithFrame:CGRectMake(UDInputBarViewToHorizontalEdgeSpacing, UDInputBarViewToVerticalEdgeSpacing, kUMCScreenWidth-UDInputBarViewToHorizontalEdgeSpacing*2, UDInputBarViewHeight)];
    _inputTextView.placeholder = UMCLocalizedString(@"udesk_typing");
    _inputTextView.delegate = (id)self;
    _inputTextView.returnKeyType = UIReturnKeySend;
    _inputTextView.font = [UIFont systemFontOfSize:16];
    _inputTextView.backgroundColor = [UMCSDKConfig sharedConfig].sdkStyle.textViewColor;
    self.backgroundColor = [UMCSDKConfig sharedConfig].sdkStyle.inputViewColor;
    [_defaultToolBar addSubview:_inputTextView];
    
    //表情
    _emotionButton = [self createButtonWithImage:[UIImage umcDefaultSmileImage] HLImage:[UIImage umcDefaultSmileHighlightedImage]];
    _emotionButton.frame = CGRectMake(UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    _emotionButton.hidden = self.hiddenEmotionButton;
    [_emotionButton addTarget:self action:@selector(emotionClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_emotionButton];
    
    //语音
    _voiceButton = [self createButtonWithImage:[UIImage umcDefaultVoiceImage] HLImage:[UIImage umcDefaultVoiceHighlightedImage]];
    CGFloat voiceButtonX = _emotionButton.umcRight + UDInputBarViewButtonToHorizontalEdgeSpacing;
    if (self.hiddenEmotionButton) {
        voiceButtonX = UDInputBarViewButtonToHorizontalEdgeSpacing;
    }
    _voiceButton.frame = CGRectMake(voiceButtonX, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    _voiceButton.hidden = self.hiddenVoiceButton;
    [_voiceButton addTarget:self action:@selector(voiceClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_voiceButton];
    
    //相机
    _cameraButton = [self createButtonWithImage:[UIImage umcDefaultCameraImage] HLImage:[UIImage umcDefaultCameraHighlightedImage]];
    
    CGFloat cameraButtonX = UDInputBarViewButtonToHorizontalEdgeSpacing + _voiceButton.umcRight;
    if (self.hiddenVoiceButton) {
        cameraButtonX = cameraButtonX - _voiceButton.umcRight + _cameraButton.umcRight;
        if (self.hiddenEmotionButton) {
            cameraButtonX = UDInputBarViewButtonToHorizontalEdgeSpacing;
        }
    }
    
    _cameraButton.frame = CGRectMake(cameraButtonX, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    _cameraButton.hidden = self.hiddenCameraButton;
    [_cameraButton addTarget:self action:@selector(cameraClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_cameraButton];
    
    CGFloat albumButtonX = _cameraButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing;
    if (self.hiddenCameraButton) {
        albumButtonX = albumButtonX - _cameraButton.umcRight + _voiceButton.umcRight;
        if (self.hiddenVoiceButton) {
            albumButtonX = albumButtonX - _voiceButton.umcRight + _emotionButton.umcRight;
            if (self.hiddenEmotionButton) {
                albumButtonX = UDInputBarViewButtonToHorizontalEdgeSpacing;
            }
        }
    }
    
    //相册
    _albumButton = [self createButtonWithImage:[UIImage umcDefaultPhotoImage] HLImage:[UIImage umcDefaultPhotoHighlightedImage]];
    _albumButton.frame = CGRectMake(albumButtonX, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    _albumButton.hidden = self.hiddenAlbumButton;
    [_albumButton addTarget:self action:@selector(albumClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_albumButton];
}

#pragma mark - layout subViews UI
- (UIButton *)createButtonWithImage:(UIImage *)image HLImage:(UIImage *)hlImage {
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter)];
    if (image)
        [button setImage:image forState:UIControlStateNormal];
    if (hlImage)
        [button setImage:image forState:UIControlStateHighlighted];
    
    return button;
}

//点击表情按钮
- (void)emotionClick:(UIButton *)button {
    
    self.selectInputBarType = UMCInputBarTypeEmotion;
    button.selected = !button.selected;
    if (!button.selected) {
        [self.inputTextView becomeFirstResponder];
    }
    
    if ([self.delegate respondsToSelector:@selector(inputBar:didSelectEmotion:)]) {
        [self.delegate inputBar:self didSelectEmotion:button];
    }
}

//点击语音
- (void)voiceClick:(UIButton *)button {
    
    self.selectInputBarType = UMCInputBarTypeVoice;
    if (kUMCSystemVersion >= 7.0)
    {
        
        [[AVAudioSession sharedInstance] requestRecordPermission:^(BOOL granted) {
            if (granted) {
                // 用户同意获取数据
                dispatch_async(dispatch_get_main_queue(), ^{
                    button.selected = !button.selected;
                    if (!button.selected) {
                        [self.inputTextView becomeFirstResponder];
                    }
                    
                    if ([self.delegate respondsToSelector:@selector(inputBar:didSelectVoice:)]) {
                        [self.delegate inputBar:self didSelectVoice:button];
                    }
                });
                
            } else {
                // 可以显示一个提示框告诉用户这个app没有得到允许？
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:UMCLocalizedString(@"udesk_microphone_denied")
                                               delegate:nil
                                      cancelButtonTitle:UMCLocalizedString(@"udesk_close")
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                });
                
            }
        }];
    }
    else {
        button.selected = !button.selected;
        if (!button.selected) {
            [self.inputTextView becomeFirstResponder];
        }
        
        if ([self.delegate respondsToSelector:@selector(inputBar:didSelectVoice:)]) {
            [self.delegate inputBar:self didSelectVoice:button];
        }
    }
}

//点击评价
- (void)surveyClick:(UIButton *)survey {
    
    self.selectInputBarType = UMCInputBarTypeNormal;
    if ([self.delegate respondsToSelector:@selector(inputBar:didSelectSurvey:)]) {
        [self.delegate inputBar:self didSelectSurvey:survey];
    }
}

//点击相机按钮
- (void)cameraClick:(UIButton *)button {
    
    self.selectInputBarType = UMCInputBarTypeNormal;
    //模拟器
    if (TARGET_IPHONE_SIMULATOR) {
        NSLog(@"UdeskSDK：模拟器无法使用拍摄功能");
        return;
    }
    
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (granted) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(inputBar:didSelectImageWithSourceType:)]) {
                        [self.delegate inputBar:self didSelectImageWithSourceType:UIImagePickerControllerSourceTypeCamera];
                    }
                });
            }
            else {
                dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                    [[[UIAlertView alloc] initWithTitle:nil
                                                message:UMCLocalizedString(@"udesk_camera_denied")
                                               delegate:nil
                                      cancelButtonTitle:UMCLocalizedString(@"udesk_close")
                                      otherButtonTitles:nil] show];
#pragma clang diagnostic pop
                });
                
            }
        });
    }];
}

//点击相册按钮
- (void)albumClick:(UIButton *)button {
    
    self.selectInputBarType = UMCInputBarTypeNormal;
    if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusNotDetermined) {
        
        ALAssetsLibrary *assetsLibrary = [[ALAssetsLibrary alloc] init];
        
        [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
            
            if (*stop) {
                //点击“好”回调方法
                //检查客服状态
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([self.delegate respondsToSelector:@selector(inputBar:didSelectImageWithSourceType:)]) {
                        [self.delegate inputBar:self didSelectImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
                    }
                });
                return;
            }
            *stop = TRUE;
            
        } failureBlock:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                [[[UIAlertView alloc] initWithTitle:nil
                                            message:UMCLocalizedString(@"udesk_album_denied")
                                           delegate:nil
                                  cancelButtonTitle:UMCLocalizedString(@"udesk_close")
                                  otherButtonTitles:nil] show];
#pragma clang diagnostic pop
            });
        }];
    }
    else if ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized) {
        
        if ([self.delegate respondsToSelector:@selector(inputBar:didSelectImageWithSourceType:)]) {
            [self.delegate inputBar:self didSelectImageWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        }
    }
    else if([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusDenied){
        
        dispatch_async(dispatch_get_main_queue(), ^{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
            [[[UIAlertView alloc] initWithTitle:nil
                                        message:UMCLocalizedString(@"udesk_album_denied")
                                       delegate:nil
                              cancelButtonTitle:UMCLocalizedString(@"udesk_close")
                              otherButtonTitles:nil] show];
#pragma clang diagnostic pop
        });
    }
    
}

#pragma mark - Text view delegate
- (BOOL)growingTextViewShouldBeginEditing:(UdeskHPGrowingTextView *)growingTextView {

    if ([self.delegate respondsToSelector:@selector(inputBar:willBeginEditing:)]) {
        [self.delegate inputBar:self willBeginEditing:growingTextView];
    }
    _emotionButton.selected = NO;
    _voiceButton.selected = NO;

    self.selectInputBarType = UMCInputBarTypeText;

    return YES;
}

- (void)growingTextViewDidBeginEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView becomeFirstResponder];
}

- (void)growingTextViewDidEndEditing:(UdeskHPGrowingTextView *)growingTextView {
    [growingTextView resignFirstResponder];
}

- (BOOL)growingTextView:(UdeskHPGrowingTextView *)growingTextView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if ([text isEqualToString:@"\n"]) {
        if ([self.delegate respondsToSelector:@selector(inputBar:didSendText:)]) {
            [self.delegate inputBar:self didSendText:growingTextView.text];
        }
        self.inputTextView.text = @"";
        return NO;
    }
    return YES;
}

- (void)growingTextView:(UdeskHPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff     = (self.inputTextView.frame.size.height - height);
    //确保tableView的y不大于原始的y
    CGFloat tableViewOriginY = self.imTableView.frame.origin.y + diff;
    if (tableViewOriginY > self.originalTableViewFrame.origin.y) {
        tableViewOriginY = self.originalTableViewFrame.origin.y;
    }
    self.imTableView.frame = CGRectMake(self.imTableView.frame.origin.x, tableViewOriginY, self.imTableView.frame.size.width, self.imTableView.frame.size.height);
    self.frame     = CGRectMake(0, self.frame.origin.y + diff, self.frame.size.width, self.frame.size.height - diff);
    
    //按钮靠下
    [self reFramefunctionBtnAfterTextViewChange];
}

- (void)reFramefunctionBtnAfterTextViewChange
{
    CGFloat buttonY = self.umcHeight-UDInputBarViewToVerticalEdgeSpacing-UDInputBarViewButtonDiameter;
    
    CGFloat customToolBarHeight = 0;
    if (self.customToolBar) {
        self.customToolBar.umcTop = 0;
        customToolBarHeight = UDInputBarViewCustomToolBarHeight;
        _defaultToolBar.umcTop = self.customToolBar.umcBottom;
    }
    
    _emotionButton.umcTop = buttonY - customToolBarHeight;
    _voiceButton.umcTop = buttonY - customToolBarHeight;
    _cameraButton.umcTop = buttonY - customToolBarHeight;
    _albumButton.umcTop = buttonY - customToolBarHeight;
    _surveyButton.umcTop = buttonY - customToolBarHeight;
}

//隐藏相册
- (void)setHiddenAlbumButton:(BOOL)hiddenAlbumButton {
    
    _hiddenAlbumButton = hiddenAlbumButton;
    if (_albumButton) {
        _albumButton.hidden = hiddenAlbumButton;
    }
}

//隐藏相机
- (void)setHiddenCameraButton:(BOOL)hiddenCameraButton {
    
    _hiddenCameraButton = hiddenCameraButton;
    if (_cameraButton) {
        _cameraButton.hidden = hiddenCameraButton;
        _albumButton.frame = CGRectMake(_voiceButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    }
}

//隐藏语音
- (void)setHiddenVoiceButton:(BOOL)hiddenVoiceButton {
    
    _hiddenVoiceButton = hiddenVoiceButton;
    if (_voiceButton) {
        _voiceButton.hidden = hiddenVoiceButton;
        _cameraButton.frame = CGRectMake(_emotionButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
        _albumButton.frame = CGRectMake(_cameraButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    }
}

//隐藏表情
- (void)setHiddenEmotionButton:(BOOL)hiddenEmotionButton {
    
    _hiddenEmotionButton = hiddenEmotionButton;
    if (_emotionButton) {
        _emotionButton.hidden = hiddenEmotionButton;
        _voiceButton.frame = CGRectMake(_emotionButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
        _cameraButton.frame = CGRectMake(_voiceButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
        _albumButton.frame = CGRectMake(_cameraButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    }
}

//离线留言不显示任何功能按钮
- (void)updateInputBarForLeaveMessage {
    
    if (self.umcHeight == 50.f) {
        return;
    }
    if (self.emotionButton) {
        self.emotionButton.hidden = YES;
    }
    if (self.voiceButton) {
        self.voiceButton.hidden = YES;
    }
    if (self.cameraButton) {
        self.cameraButton.hidden = YES;
    }
    if (self.albumButton) {
        self.albumButton.hidden = YES;
    }
    if (self.surveyButton) {
        self.surveyButton.hidden = YES;
    }
    
    CGFloat inputViewHeight = 50.f;
    self.umcHeight = inputViewHeight;
    self.umcTop += 30;
    [self.imTableView setTableViewInsetsWithBottomValue:inputViewHeight];
}

- (void)setCustomButtonConfigs:(NSArray<UMCCustomButtonConfig *> *)customButtonConfigs {
    if (!customButtonConfigs || customButtonConfigs == (id)kCFNull) return ;
    if (![customButtonConfigs isKindOfClass:[NSArray class]]) return ;
    if (![customButtonConfigs.firstObject isKindOfClass:[UMCCustomButtonConfig class]]) return ;
    if (customButtonConfigs.count <= 0) return;
    
    _customButtonConfigs = customButtonConfigs;
    
    if (!self.showCustomButtons) {
        return;
    }
    
    self.frame = CGRectMake(0, self.frame.origin.y - UDInputBarViewCustomToolBarHeight, self.frame.size.width, self.frame.size.height + UDInputBarViewCustomToolBarHeight);
    self.defaultToolBar.umcTop = UDInputBarViewCustomToolBarHeight;
    [self.imTableView setTableViewInsetsWithBottomValue:self.umcHeight];
    
    _customToolBar = [[UMCCustomToolBar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, UDInputBarViewCustomToolBarHeight) customButtonConfigs:customButtonConfigs];
    _customToolBar.delegate = self;
    [self addSubview:_customToolBar];
}

#pragma mark - @protocol UMCCustomToolBarDelegate
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectCustomToolBar:atIndex:)]) {
        [self.delegate didSelectCustomToolBar:toolBar atIndex:index];
    }
}

- (void)setIsShowSurvey:(BOOL)isShowSurvey {
    _isShowSurvey = isShowSurvey;
    
    if (!isShowSurvey) {
        return;
    }
    
    CGFloat surveyButtonX = _albumButton.umcRight+UDInputBarViewButtonToHorizontalEdgeSpacing;
    if (self.hiddenAlbumButton) {
        surveyButtonX = surveyButtonX - _albumButton.umcRight + _cameraButton.umcRight;
        if (self.hiddenCameraButton) {
            surveyButtonX = surveyButtonX - _cameraButton.umcRight + _voiceButton.umcRight;
            if (self.hiddenVoiceButton) {
                surveyButtonX = surveyButtonX - _voiceButton.umcRight + _emotionButton.umcRight;
                if (self.hiddenEmotionButton) {
                    surveyButtonX = UDInputBarViewButtonToHorizontalEdgeSpacing;
                }
            }
        }
    }
    
    //相册
    _surveyButton = [self createButtonWithImage:[UIImage umcDefaultSurveyImage] HLImage:[UIImage umcDefaultSurveyHighlightedImage]];
    _surveyButton.frame = CGRectMake(surveyButtonX, UDInputBarViewButtonToVerticalEdgeSpacing, UDInputBarViewButtonDiameter, UDInputBarViewButtonDiameter);
    _surveyButton.hidden = self.hiddenAlbumButton;
    [_surveyButton addTarget:self action:@selector(surveyClick:) forControlEvents:UIControlEventTouchUpInside];
    [_defaultToolBar addSubview:_surveyButton];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(ctx, 1.0);
    CGContextSetStrokeColorWithColor(ctx, [UIColor colorWithWhite:0.8 alpha:1].CGColor);
    CGContextMoveToPoint(ctx, 0, 0);
    CGContextAddLineToPoint(ctx, rect.size.width, 0);
    
    CGContextClosePath(ctx);
    CGContextStrokePath(ctx);
}

- (void)dealloc
{
    NSLog(@"%@销毁了",[self class]);
}
@end
