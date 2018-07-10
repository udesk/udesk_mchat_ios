//
//  UMCIMViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCIMViewController.h"
#import "UMCIMManager.h"
#import "UMCVoiceRecordHUD.h"
#import "UMCIMDataSource.h"
#import "UMCBaseMessage.h"
#import "UMCImagePicker.h"
#import "UMCAudioPlayerHelper.h"
#import "UMCInputBarHelper.h"
#import "UMCHelper.h"
#import "UMCBundleHelper.h"
#import "UMCProductView.h"

#import "YYKeyboardManager.h"

static CGFloat const InputBarHeight = 80.0f;

@interface UMCIMViewController ()<UITableViewDelegate,UMCInputBarDelegate,YYKeyboardObserver,UdeskVoiceRecordViewDelegate,UDEmotionManagerViewDelegate,UMCBaseCellDelegate>

/** sdk配置 */
@property (nonatomic, strong) UMCSDKConfig         *sdkConfig;
/** im逻辑处理 */
@property (nonatomic, strong) UMCIMManager         *UIManager;
/** 咨询对象 */
@property (nonatomic, strong) UMCProductView       *productView;
/** 输入框 */
@property (nonatomic, strong) UMCInputBar          *inputBar;
/** 表情 */
@property (nonatomic, strong) UMCEmojiView         *emojiView;
/** 录音 */
@property (nonatomic, strong) UMCVoiceRecordView   *recordView;
/** im TableView */
@property (nonatomic, strong) UMCIMTableView       *imTableView;
/** TableView DataSource */
@property (nonatomic, strong) UMCIMDataSource      *dataSource;
/** 录音提示HUD */
@property (nonatomic, strong) UMCVoiceRecordHUD    *voiceRecordHUD;
/** 输入框工具类 */
@property (nonatomic, strong) UMCInputBarHelper    *inputBarHelper;
/** 图片选择类 */
@property (nonatomic, strong) UMCImagePicker       *imagePicker;
/** 商户ID */
@property (nonatomic, copy  ) NSString             *merchantId;

@end

@implementation UMCIMViewController

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantId:(NSString *)merchantId
{
    self = [super init];
    if (self) {
        
        _sdkConfig = config;
        _merchantId = merchantId;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setup];
    [self fetchMessages];
}

#pragma mark - UI布局
- (void)setup {
    
    _imTableView = [[UMCIMTableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _imTableView.delegate = self;
    _imTableView.dataSource = self.dataSource;
    [self.view addSubview:_imTableView];
    //EdgeInsets
    [_imTableView setTableViewInsetsWithBottomValue:InputBarHeight];
    [_imTableView finishLoadingMoreMessages:self.UIManager.hasMore];
    
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapChatTableView:)];
    tap.cancelsTouchesInView = false;
    [_imTableView addGestureRecognizer:tap];
    
    //设置颜色
    [self setBackgroundColor];
    
    //咨询对象
    if (_sdkConfig.product) {
        self.productView.productModel = _sdkConfig.product;
        _imTableView.umcTop = self.productView.umcBottom;
        _imTableView.umcHeight = _imTableView.umcHeight - self.productView.umcBottom;
    }
    
    _inputBar = [[UMCInputBar alloc] initWithFrame:CGRectMake(0, self.view.umcHeight - InputBarHeight, self.view.umcWidth,InputBarHeight) tableView:_imTableView];
    _inputBar.delegate = self;
    _inputBar.showCustomButtons = _sdkConfig.showCustomButtons;
    _inputBar.customButtonConfigs = _sdkConfig.customButtons;
    [self.view addSubview:_inputBar];
    //更新功能按钮隐藏属性
    [self updateInputFunctionButtonHidden];
    
    //根据系统版本去掉自动调整
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //获取键盘管理器
    [[YYKeyboardManager defaultManager] addObserver:self];
    
    //监听app是否从后台进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umcIMApplicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    //登录成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umcLoginSuccess) name:UMC_LOGIN_SUCCESS_NOTIFICATION object:nil];
    
    //适配X
    if (kUMCIsIPhoneX) {
        _inputBar.umcBottom -= 34;
        _imTableView.umcHeight -= 34;
        [_imTableView setTableViewInsetsWithBottomValue:self.view.umcHeight - _inputBar.umcTop];
    }
}

//登录成功
- (void)umcLoginSuccess {
    @udWeakify(self);
    [self.UIManager fetchNewMessages:^{
        @udStrongify(self);
        [self reloadIMTableView];
    }];
}

//监听app是否从后台进入前台
- (void)umcIMApplicationBecomeActive {
    
    @udWeakify(self);
    [self.UIManager fetchNewMessages:^{
        @udStrongify(self);
        [self reloadIMTableView];
    }];
}

#pragma mark - @protocol UMCInputBarDelegate
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    NSArray *customButtons = self.sdkConfig.customButtons;
    if (index >= customButtons.count) return;
    
    UMCCustomButtonConfig *customButton = customButtons[index];
    if (customButton.clickBlock) {
        customButton.clickBlock(customButton,self);
    }
}

//选择图片
- (void)inputBar:(UMCInputBar *)inputBar didSelectImageWithSourceType:(UIImagePickerControllerSourceType)sourceType {
    
    [self inputBarHide:NO];
    [self.imagePicker showWithSourceType:sourceType viewController:self];
    
    //选择了GIF图片
    @udWeakify(self);
    self.imagePicker.FinishGIFImageBlock = ^(NSData *GIFData) {
        @udStrongify(self);
        [self sendGIFMessageWithGIFData:GIFData];
    };
    //选择了普通图片
    self.imagePicker.FinishNormalImageBlock = ^(UIImage *image) {
        @udStrongify(self);
        [self sendImageMessageWithImage:image];
    };
}

//发送文本消息，包括系统的表情
- (void)inputBar:(UMCInputBar *)inputBar didSendText:(NSString *)text {
    
    [self sendTextMessageWithContent:text];
}

//显示表情
- (void)inputBar:(UMCInputBar *)inputBar didSelectEmotion:(UIButton *)emotionButton {
    
    if (emotionButton.selected) {
        [self emojiView];
        [self inputBarHide:NO];
    }
}

//点击语音
- (void)inputBar:(UMCInputBar *)inputBar didSelectVoice:(UIButton *)voiceButton {
    
    if (voiceButton.selected) {
        [self recordView];
        [self inputBarHide:NO];
    }
}

//显示／隐藏
- (void)inputBarHide:(BOOL)hide {
    
    [self.inputBarHelper inputBarHide:hide superView:self.view tableView:self.imTableView inputBar:self.inputBar emojiView:self.emojiView recordView:self.recordView completion:^{
        if (hide) {
            self.inputBar.selectInputBarType = UMCInputBarTypeNormal;
        }
    }];
}

//是否隐藏部分功能
- (void)updateInputFunctionButtonHidden {
    
    _inputBar.hiddenCameraButton = self.sdkConfig.hiddenCameraButton;
    _inputBar.hiddenAlbumButton = self.sdkConfig.hiddenAlbumButton;
    _inputBar.hiddenVoiceButton = self.sdkConfig.hiddenVoiceButton;
    _inputBar.hiddenEmotionButton = self.sdkConfig.hiddenEmotionButton;
}

//点击空白处隐藏键盘
- (void)didTapChatTableView:(UITableView *)tableView {
    
    if ([self.inputBar.inputTextView resignFirstResponder]) {
        [self inputBarHide:YES];
    }
}

#pragma mark - @protocol TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UMCBaseMessage *message = self.UIManager.messagesArray[indexPath.row];
    return message ? message.cellHeight : 0;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    
    //滑动表隐藏Menu
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (menu.isMenuVisible) {
        [menu setMenuVisible:NO animated:YES];
    }
    
    if (self.inputBar.selectInputBarType != UMCInputBarTypeNormal) {
        [self inputBarHide:YES];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    @try {
        
        if (scrollView.contentOffset.y<0 && self.imTableView.isRefresh) {
            //开始刷新
            [self.imTableView startLoadingMoreMessages];
            //获取更多数据
            [self.UIManager nextMessages:^{
                //延迟0.8，提高用户体验
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //关闭刷新、刷新数据
                    [self.imTableView finishLoadingMoreMessages:self.UIManager.hasMore];
                });
            }];
        }
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - 获取消息数据
- (void)fetchMessages {
    
    @udWeakify(self);
    [self.UIManager fetchMessages:^{
        @udStrongify(self);
        [self reloadIMTableView];
    }];
    
    //刷新消息
    self.UIManager.ReloadMessagesBlock = ^{
        @udStrongify(self);
        [self reloadIMTableView];
    };
    
    //获取商户信息
    [self.UIManager fetchMerchantWithMerchantId:self.merchantId completion:^(UMCMerchant *merchant) {
        @udStrongify(self);
        self.title = merchant.name;
        if (merchant.euid) { self.merchantId = merchant.euid;}
    }];
}

//刷新UI
- (void)reloadIMTableView {
    
    //更新消息内容
    dispatch_async(dispatch_get_main_queue(), ^{
        //是否需要下拉刷新
        self.dataSource.messagesArray = self.UIManager.messagesArray;
        [self.imTableView finishLoadingMoreMessages:self.UIManager.hasMore];
        [self.imTableView reloadData];
    });
}

//TableView DataSource
- (UMCIMDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[UMCIMDataSource alloc] init];
        _dataSource.delegate = self;
    }
    return _dataSource;
}

#pragma mark - UMCBaseCellDelegate
//重发消息
- (void)resendMessageInCell:(UITableViewCell *)cell resendMessage:(UMCMessage *)resendMessage {
    
    @udWeakify(self);
    [UMCManager createMessageWithMerchantsEuid:self.merchantId message:resendMessage completion:^(UMCMessage *message) {
        @udStrongify(self);
        [self.UIManager updateCache:resendMessage newMessage:message];
        [self updateSendCompletedMessage:resendMessage];
    }];
}

//点击商品消息
- (void)didTapGoodsMessageCell:(UITableViewCell *)cell goodsURL:(NSString *)goodsURL goodsId:(NSString *)goodsId {
    
    if (self.sdkConfig.clickGoodsBlock) {
        self.sdkConfig.clickGoodsBlock(self,goodsURL,goodsId);
        return;
    }
    
    //跳转浏览器展示
    if (!goodsURL || goodsURL == (id)kCFNull) return ;
    if (![goodsURL isKindOfClass:[NSString class]]) return ;
    if (goodsURL.length > 0) {
        if ([goodsURL rangeOfString:@"://"].location == NSNotFound) {
            goodsURL = [NSString stringWithFormat:@"http://%@",goodsURL];
        }
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:goodsURL]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//vc逻辑处理
- (UMCIMManager *)UIManager {
    if (!_UIManager) {
        _UIManager = [[UMCIMManager alloc] initWithSDKConfig:_sdkConfig merchantId:_merchantId];
    }
    return _UIManager;
}

//吐司提示view
- (UMCVoiceRecordHUD *)voiceRecordHUD {
    
    if (!_voiceRecordHUD) {
        _voiceRecordHUD = [[UMCVoiceRecordHUD alloc] init];
    }
    return _voiceRecordHUD;
}

//录音动画view
- (UMCVoiceRecordView *)recordView {
    
    if (!_recordView) {
        _recordView = [[UMCVoiceRecordView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), 200)];
        _recordView.alpha = 0.0;
        _recordView.delegate = self;
        [self.view addSubview:_recordView];
    }
    return _recordView;
}

//咨询对象
- (UMCProductView *)productView {
    
    if (!_productView) {
        _productView = [[UMCProductView alloc] initWithFrame:CGRectMake(0, 0, kUMCScreenWidth, kUDProductHeight)];
        [self.view addSubview:_productView];
    }
    return _productView;
}

#pragma mark - @protocol UdeskVoiceRecordViewDelegate
//完成录音
- (void)finishRecordedWithVoicePath:(NSString *)voicePath withAudioDuration:(NSString *)duration {
    
    [self sendVoiceMessageWithVoicePath:voicePath voiceDuration:duration];
}

//录音时间太短
- (void)speakDurationTooShort {
    [self.voiceRecordHUD showTooShortRecord:self.view];
}

#pragma mark - 表情view
- (UMCEmojiView *)emojiView {
    
    if (!_emojiView) {
        CGFloat emotionHeight = kUMCScreenWidth<375?200:216;
        _emojiView = [[UMCEmojiView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds), CGRectGetWidth(self.view.bounds), emotionHeight)];
        _emojiView.delegate = self;
        _emojiView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        _emojiView.alpha = 0.0;
        [self.view addSubview:_emojiView];
    }
    return _emojiView;
}

#pragma mark - @protocol UDEmotionManagerViewDelegate
- (void)emojiViewDidPressDeleteButton:(UIButton *)deletebutton {
    
    if (self.inputBar.inputTextView.text.length > 0) {
        NSRange lastRange = [self.inputBar.inputTextView.text rangeOfComposedCharacterSequenceAtIndex:self.inputBar.inputTextView.text.length-1];
        self.inputBar.inputTextView.text = [self.inputBar.inputTextView.text substringToIndex:lastRange.location];
    }
}

//点击表情
- (void)emojiViewDidSelectEmoji:(NSString *)emoji {
    if ([self.inputBar.inputTextView.textColor isEqual:[UIColor lightGrayColor]] && [self.inputBar.inputTextView.text isEqualToString:@"输入消息..."]) {
        self.inputBar.inputTextView.text = nil;
        self.inputBar.inputTextView.textColor = [UIColor blackColor];
    }
    self.inputBar.inputTextView.text = [self.inputBar.inputTextView.text stringByAppendingString:emoji];
}

//点击表情面板的发送按钮
- (void)didEmotionViewSendAction {
    
    [self sendTextMessageWithContent:self.inputBar.inputTextView.text];
    self.inputBar.inputTextView.text = @"";
}

#pragma mark - @protocol YYKeyboardObserver
- (void)keyboardChangedWithTransition:(YYKeyboardTransition)transition {
    
    if (self.inputBar.selectInputBarType != UMCInputBarTypeText) {
        return;
    }
    
    CGRect toFrame =  [[YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    [UIView animateWithDuration:0.35 animations:^{
        self.inputBar.umcBottom = CGRectGetMinY(toFrame);
        if (!transition.toVisible && kUMCIsIPhoneX) {
            self.inputBar.umcBottom -= 34;
        }
        self.imTableView.umcTop = self.sdkConfig.product?self.productView.umcBottom:0;
        self.imTableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.umcHeight - CGRectGetMinY(self.inputBar.frame), 0);
        if (transition.toVisible) {
            [self.imTableView scrollToBottomAnimated:NO];
            self.emojiView.alpha = 0.0;
            self.recordView.alpha = 0.0;
        }
    }];
}

//input工具类
- (UMCInputBarHelper *)inputBarHelper {
    if (!_inputBarHelper) {
        _inputBarHelper = [[UMCInputBarHelper alloc] init];
    }
    return _inputBarHelper;
}

//图片选择工具类
- (UMCImagePicker *)imagePicker {
    if (!_imagePicker) {
        _imagePicker = [[UMCImagePicker alloc] init];
    }
    return _imagePicker;
}

#pragma mark - 发送文字
- (void)sendTextMessageWithContent:(NSString *)content {
    if (!content || content == (id)kCFNull) return ;
    
    if ([UMCHelper isBlankString:content]) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:UMCLocalizedString(@"udesk_no_send_empty") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_cancel") style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    [self.UIManager sendTextMessage:content completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
    }];
}

#pragma mark - 发送图片
- (void)sendImageMessageWithImage:(UIImage *)image {
    if (!image || image == (id)kCFNull) return ;
    
    [self.UIManager sendImageMessage:image completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
    }];
}

//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData {
    if (!gifData || gifData == (id)kCFNull) return ;
    
    [self.UIManager sendGIFImageMessage:gifData completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
    }];
}

#pragma mark - 发送语音
- (void)sendVoiceMessageWithVoicePath:(NSString *)voicePath voiceDuration:(NSString *)voiceDuration {
    if (!voicePath || voicePath == (id)kCFNull) return ;
    if (!voiceDuration || voiceDuration == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.UIManager sendVoiceMessage:voicePath voiceDuration:voiceDuration completion:^(UMCMessage *message) {
        @udStrongify(self);
        [self updateSendCompletedMessage:message];
    }];
}

#pragma mark - 发送商品信息
- (void)sendGoodsMessageWithModel:(UMCGoodsModel *)goodsModel {
    if (!goodsModel || goodsModel == (id)kCFNull) return ;
    
    @udWeakify(self);
    [self.UIManager sendGoodsMessage:goodsModel completion:^(UMCMessage *message) {
        @udStrongify(self);
        [self updateSendCompletedMessage:message];
    }];
}

#pragma mark - 消息发送完成回调
- (void)updateSendCompletedMessage:(UMCMessage *)message {
    
    message.merchantEuid = self.merchantId;
    //更新商户列表最后一条消息
    if (self.UpdateLastMessageBlock) {
        self.UpdateLastMessageBlock(message);
    }
    
    NSArray *array = [self.UIManager.messagesArray valueForKey:@"messageId"];
    if ([array containsObject:message.UUID]) {
        [self didUpdateCellModelWithIndexPath:[NSIndexPath indexPathForRow:[array indexOfObject:message.UUID] inSection:0]];
    }
}

- (void)didUpdateCellModelWithIndexPath:(NSIndexPath *)indexPath {
    dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f/*延迟执行时间*/ * NSEC_PER_SEC));
    dispatch_after(delayTime, dispatch_get_main_queue(), ^{
        [self safeCellUpdate:indexPath.section row:indexPath.row];
    });
}

- (void)safeCellUpdate:(NSUInteger)section row: (NSUInteger) row {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger lastSection = [self.imTableView numberOfSections];
        if (lastSection == 0) {
            return;
        }
        lastSection -= 1;
        if (section > lastSection) {
            return;
        }
        NSUInteger lastRowNumber = [self.imTableView numberOfRowsInSection:section];
        if (lastRowNumber == 0) {
            return;
        }
        lastRowNumber -= 1;
        if (row > lastRowNumber) {
            return;
        }
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
        @try {
            if ([[self.imTableView indexPathsForVisibleRows] indexOfObject:indexPath] == NSNotFound) {
                return;
            }
            [self.imTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        @catch (NSException *exception) {
            NSLog(@"%@",exception);
            return;
        }
    });
}


#pragma mark - 设置背景颜色
- (void)setBackgroundColor {
    self.view.backgroundColor = self.sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
    self.imTableView.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
}

#pragma mark - dismissChatViewController
- (void)dismissChatViewController {
    
    //离开页面回调
    if (self.sdkConfig.leaveChatViewController) {
        self.sdkConfig.leaveChatViewController();
    }
    
    [_sdkConfig setConfigToDefault];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    // 停止播放语音
    [[UMCAudioPlayerHelper shareInstance] stopAudio];
    [UMCManager leaveChatViewController];
    //离开页面 标记已读
    [UMCManager readMerchantsWithEuid:self.merchantId completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UMCManager enterChatViewController];
}

- (void)dealloc {
    NSLog(@"%@销毁了",[self class]);
    [[YYKeyboardManager defaultManager] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UMC_LOGIN_SUCCESS_NOTIFICATION object:nil];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
