//
//  UMCIMViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCIMViewController.h"
#import "UMCIMManager.h"
#import "UMCIMDataSource.h"
#import "UMCBaseMessage.h"
#import "UMCImagePicker.h"
#import "UMCAudioPlayerHelper.h"
#import "UMCInputBarHelper.h"
#import "UMCHelper.h"
#import "UMCBundleHelper.h"
#import "UMCProductView.h"
#import "UMCSurveyView.h"
#import "UMCToast.h"
#import "UMCMoreToolBar.h"
#import "UMCVoiceRecord.h"
#import "UMCVoiceRecordView.h"
#import "UMCPrivacyUtil.h"
#import "UMCVideoCell.h"
#import "UMCImageCell.h"
#import "UMCFileCell.h"
#import "UdeskSmallVideoViewController.h"
#import "UdeskSmallVideoNavigationController.h"

#import "Udesk_YYKeyboardManager.h"

static CGFloat const InputBarHeight = 52.0f;

@interface UMCIMViewController ()<UITableViewDelegate,UMCInputBarDelegate,UMCMoreToolBarDelegate,Udesk_YYKeyboardObserver,UDEmotionManagerViewDelegate,UMCBaseCellDelegate,UdeskSmallVideoViewControllerDelegate,UIDocumentPickerDelegate>

/** sdk配置 */
@property (nonatomic, strong) UMCSDKConfig         *sdkConfig;
/** im逻辑处理 */
@property (nonatomic, strong) UMCIMManager         *UIManager;
/** 咨询对象 */
@property (nonatomic, strong) UMCProductView       *productView;
/** 输入框 */
@property (nonatomic, strong) UMCInputBar          *inputBar;
/** 更多 */
@property (nonatomic, strong) UMCMoreToolBar       *moreView;
/** 表情 */
@property (nonatomic, strong) UMCEmojiView         *emojiView;
/** 录音 */
@property (nonatomic, strong) UMCVoiceRecordView   *voiceRecordView;
@property (nonatomic, strong) UMCVoiceRecord       *voiceRecordHelper;
/** im TableView */
@property (nonatomic, strong) UMCIMTableView       *imTableView;
/** TableView DataSource */
@property (nonatomic, strong) UMCIMDataSource      *dataSource;
/** 输入框工具类 */
@property (nonatomic, strong) UMCInputBarHelper    *inputBarHelper;
/** 图片选择类 */
@property (nonatomic, strong) UMCImagePicker       *imagePicker;
/** 商户ID */
@property (nonatomic, copy  ) NSString             *merchantEuid;
/** 离开显示满意度调查 */
@property (nonatomic, assign) BOOL                  afterSession;
/** 返回展示满意度 */
@property (nonatomic, assign) BOOL                  backAlreadyDisplayedSurvey;
//判断是不是超出了录音最大时长
@property (nonatomic, assign) BOOL                 isMaxTimeStop;

@end

@implementation UMCIMViewController

- (instancetype)initWithSDKConfig:(UMCSDKConfig *)config merchantEuid:(NSString *)merchantEuid
{
    self = [super init];
    if (self) {
        
        _sdkConfig = config;
        _merchantEuid = merchantEuid;
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
    
    _inputBar = [[UMCInputBar alloc] initWithFrame:CGRectMake(0.0f,self.view.umcHeight - InputBarHeight - (kUMCIPhoneXSeries?34:0),self.view.umcWidth,InputBarHeight+(kUMCIPhoneXSeries?34:0)) tableView:_imTableView];
    _inputBar.delegate = self;
    _inputBar.customButtonConfigs = self.sdkConfig.customButtons;
    [self.view addSubview:_inputBar];
    
    //根据系统版本去掉自动调整
    if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.navigationController.navigationBar.translucent = NO;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    //获取键盘管理器
    [[Udesk_YYKeyboardManager defaultManager] addObserver:self];
    
    //监听app是否从后台进入前台
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umcIMApplicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
    //登录成功
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umcLoginSuccess) name:UMC_LOGIN_SUCCESS_NOTIFICATION object:nil];
    
    //适配X
    _imTableView.umcHeight -= kUMCIPhoneXSeries?34:0;
    [_imTableView setTableViewInsetsWithBottomValue:self.view.umcHeight - _inputBar.umcTop];
    
    //
    //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:self action:@selector(buttonPressed)];
}

- (void)buttonPressed{
    [self.navigationController popViewControllerAnimated:YES];
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
//- (void)umcIMApplicationBecomeActive {
//
//    @udWeakify(self);
//    [self.UIManager fetchNewMessages:^{
//        @udStrongify(self);
//        [self reloadIMTableView];
//    }];
//}

#pragma mark - @protocol UMCInputBarDelegate
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index {
    
    NSArray *customButtons = self.sdkConfig.customButtons;
    if (index >= customButtons.count) return;
    
    UMCCustomButtonConfig *customButton = customButtons[index];
    if (customButton.clickBlock) {
        customButton.clickBlock(customButton,self);
    }
}

//发送文本消息，包括系统的表情
- (void)didSendText:(NSString *)text {
    
    [self sendTextMessageWithContent:text];
}

//显示表情
- (void)didSelectEmotion:(UMCButton *)emotionButton {
    
    if (emotionButton.selected) {
        [self emojiView];
        [self inputBarHide:NO];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}

/** 点击更多 */
- (void)didSelectMore:(UMCButton *)moreButton {
    
    if (moreButton.selected) {
        [self inputBarHide:NO];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}

//点击语音
- (void)didSelectVoice:(UMCButton *)voiceButton {
    
    if (voiceButton.selected) {
        [self inputBarHide:YES];
    } else {
        [self.inputBar.inputTextView becomeFirstResponder];
    }
}

/** 准备录音 */
- (void)prepareRecordingVoiceActionWithCompletion:(BOOL (^)(void))completion {
    
    [self.voiceRecordHelper prepareRecordingCompletion:completion];
}

/** 开始录音 */
- (void)didStartRecordingVoiceAction {
    
    [self.voiceRecordView startRecordingAtView:self.view];
    [self.voiceRecordHelper startRecordingWithStartRecorderCompletion:nil];
}

/** 手指向上滑动取消录音 */
- (void)didCancelRecordingVoiceAction {
    
    @udWeakify(self);
    [self.voiceRecordView cancelRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordView = nil;
    }];
    [self.voiceRecordHelper cancelledDeleteWithCompletion:nil];
}

/** 松开手指完成录音 */
- (void)didFinishRecoingVoiceAction {
    
    if (self.isMaxTimeStop == NO) {
        [self finishRecorded];
    } else {
        self.isMaxTimeStop = NO;
    }
}

/** 当手指离开按钮的范围内时 */
- (void)didDragOutsideAction {
    
    [self.voiceRecordView resaueRecord];
}

/** 当手指再次进入按钮的范围内时 */
- (void)didDragInsideAction {
    
    [self.voiceRecordView pauseRecord];
}

//点击空白处隐藏键盘
- (void)didTapChatTableView:(UITableView *)tableView {
    
    if ([self.inputBar.inputTextView resignFirstResponder]) {
        [self inputBarHide:YES];
    }
}

//显示／隐藏
- (void)inputBarHide:(BOOL)hide {
    
    [self.inputBarHelper inputBarHide:hide superView:self.view tableView:self.imTableView inputBar:self.inputBar emojiView:self.emojiView moreView:self.moreView completion:^{
        if (hide) {
            self.inputBar.selectInputBarType = UMCInputBarTypeNormal;
        }
    }];
}

//显示满意度调查
- (void)showSurveyWithWithMerchantEuid:(NSString *)merchantEuid agentInvite:(BOOL)agentInvite {
    
    [self inputBarHide:YES];
    
    if (agentInvite) {
        UMCSurveyView *surveyView = [[UMCSurveyView alloc] initWithMerchantEuid:self.merchantEuid surveyResponseObject:self.UIManager.surveyResponseObject];
        [surveyView show];
        return;
    }
    [UMCManager checkHasSurveyWithMerchantEuid:merchantEuid completion:^(NSString *hasSurvey, NSError *error) {
        
        if ([hasSurvey boolValue]) {
            [UMCToast showToast:UMCLocalizedString(@"udesk_has_survey") duration:0.35 window:self.view];
        }
        else {
            UMCSurveyView *surveyView = [[UMCSurveyView alloc] initWithMerchantEuid:self.merchantEuid surveyResponseObject:self.UIManager.surveyResponseObject];
            [surveyView show];
        }
    }];
}

#pragma mark - @protocol TableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.dataSource.messagesArray.count <= indexPath.row) {
        return 0;
    }
    
    UMCBaseMessage *message = self.dataSource.messagesArray[indexPath.row];
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
    
    //收到满意度调查邀请
    self.UIManager.DidReceiveInviteSurveyBlock = ^(NSString *merchantEuid) {
        @udStrongify(self);
        [self showSurveyWithWithMerchantEuid:merchantEuid agentInvite:YES];
    };
    
    //获取商户信息
    [self.UIManager fetchMerchantWithMerchantEuid:self.merchantEuid completion:^(UMCMerchant *merchant) {
        @udStrongify(self);
        self.title = merchant.name;
        self.sdkConfig.merchantImageURL = merchant.logoURL;
        if (merchant.euid) { self.merchantEuid = merchant.euid;}
        [self checkIsBlocked:merchant.isBlocked];
    }];
    
    //满意度调查信息
    [self.UIManager fetchSurveyConfig:^(BOOL isShowSurvey, BOOL afterSession) {
        self.moreView.enableSurvey = isShowSurvey;
        self.afterSession = afterSession;
    }];
    
    //导航菜单
    [self.UIManager fetchNavigates:^{
        
    }];
}

//刷新UI
- (void)reloadIMTableView {
    
    //更新消息内容
    dispatch_async(dispatch_get_main_queue(), ^{
        //是否需要下拉刷新
        self.dataSource.messagesArray = [self.UIManager.messagesArray copy];
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

//检查黑名单
- (void)checkIsBlocked:(BOOL)isBlocked {
    
    if (isBlocked) {
    
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:UMCLocalizedString(@"udesk_alert_view_blocked_list") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_sure") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [self realDismissViewController];
        }]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - UMCBaseCellDelegate
//重发消息
- (void)resendMessageInCell:(UITableViewCell *)cell resendMessage:(UMCMessage *)resendMessage {
    
    @udWeakify(self);
    if (resendMessage.sourceData && [UMCHelper isBlankString:resendMessage.content]) {
        resendMessage.messageStatus = UMCMessageStatusSending;
        [UMCManager uploadFile:resendMessage.sourceData fileName:resendMessage.extras.filename progress:^(float percent) {
            [self updateMediaProgress:percent uploadMessage:resendMessage];
        } completion:^(NSString *address, NSError *error) {
            if (!error) {
                resendMessage.content = address;
                resendMessage.messageStatus = UMCMessageStatusSuccess;
                [UMCManager createMessageWithMerchantsEuid:self.merchantEuid menuId:self.UIManager.menuId message:resendMessage completion:^(UMCMessage *message) {
                    
                    [self.UIManager updateCache:resendMessage newMessage:message];
                    [self updateSendCompletedMessage:resendMessage];
                    [self updateMediaProgress:1 uploadMessage:resendMessage];
                }];
            } else {
                resendMessage.messageStatus = UMCMessageStatusFailed;
                [self updateMediaProgress:0 uploadMessage:resendMessage];
            }
        }];
        return;
    }
    
    [UMCManager createMessageWithMerchantsEuid:self.merchantEuid menuId:self.UIManager.menuId message:resendMessage completion:^(UMCMessage *message) {
        @udStrongify(self);
        [self.UIManager updateCache:resendMessage newMessage:message];
        [self updateSendCompletedMessage:resendMessage];
    }];
}

//点击商品消息
- (void)didTapGoodsMessageCell:(UITableViewCell *)cell goodsURL:(NSString *)goodsURL {
    
    if (self.sdkConfig.clickGoodsBlock) {
        self.sdkConfig.clickGoodsBlock(self,goodsURL);
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

//点击导航
- (void)didTapNavigate:(UITableViewCell *)cell navigate:(UMCNavigate *)navigate {
    
    if (navigate.itemName && [navigate.itemName isKindOfClass:[NSString class]] && navigate.itemName.length>0) {
        [self.UIManager sendNavigateMessage:navigate.itemName completion:^(UMCMessage *message) {
            [self updateSendCompletedMessage:message];
        }];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.UIManager receiveMessageWithNavigateModel:navigate];
    });
}

- (void)didTapNavGoback:(UITableViewCell *)cell parentId:(NSString *)parentId {
    
    [self.UIManager sendLocalTextMessage:UMCLocalizedString(@"udesk_navigate_go_back_pre")];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.UIManager receiveMessageWithParentId:parentId];
    });
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//vc逻辑处理
- (UMCIMManager *)UIManager {
    if (!_UIManager) {
        _UIManager = [[UMCIMManager alloc] initWithSDKConfig:_sdkConfig merchantEuid:_merchantEuid];
    }
    return _UIManager;
}

#pragma mark - 录音动画view
- (UMCVoiceRecordView *)voiceRecordView {
    if (!_voiceRecordView) {
        _voiceRecordView = [[UMCVoiceRecordView alloc] initWithFrame:CGRectMake(0, 0, 150, 150)];
    }
    return _voiceRecordView;
}

- (UMCVoiceRecord *)voiceRecordHelper {
    if (!_voiceRecordHelper) {
        _isMaxTimeStop = NO;
        @udWeakify(self);
        _voiceRecordHelper = [[UMCVoiceRecord alloc] init];
        _voiceRecordHelper.maxTimeStopRecorderCompletion = ^{
            @udStrongify(self);
            self.isMaxTimeStop = YES;
            [self.inputBar resetRecordButton];
            [self finishRecorded];
        };
        
        _voiceRecordHelper.peakPowerForChannel = ^(float peakPowerForChannel) {
            @udStrongify(self);
            self.voiceRecordView.peakPower = peakPowerForChannel;
        };
        
        _voiceRecordHelper.tooShortRecorderFailue = ^{
            @udStrongify(self);
            [self.voiceRecordView speakDurationTooShort];
        };
        
        _voiceRecordHelper.maxRecordTime = kUMCVoiceRecorderTotalTime;
    }
    return _voiceRecordHelper;
}

//咨询对象
- (UMCProductView *)productView {
    
    if (!_productView) {
        _productView = [[UMCProductView alloc] initWithFrame:CGRectMake(0, 0, kUMCScreenWidth, kUDProductHeight)];
        [self.view addSubview:_productView];
    }
    return _productView;
}

//录音完成
- (void)finishRecorded {
    @udWeakify(self);
    [self.voiceRecordView stopRecordCompled:^(BOOL fnished) {
        @udStrongify(self);
        self.voiceRecordView = nil;
    }];
    
    [self.voiceRecordHelper stopRecordingWithStopRecorderCompletion:^{
        @udStrongify(self);
        [self sendVoiceMessageWithVoicePath:self.voiceRecordHelper.recordPath voiceDuration:self.voiceRecordHelper.recordDuration];
    }];
}

#pragma mark - 更多
- (UMCMoreToolBar *)moreView {
    
    if (!_moreView) {
        _moreView = [[UMCMoreToolBar alloc] init];
        _moreView.customMenuItems = self.sdkConfig.customButtons;
        _moreView.backgroundColor = [UIColor colorWithWhite:0.961 alpha:1.000];
        _moreView.alpha = 0.0;
        _moreView.delegate = self;
        [self.view addSubview:_moreView];
    }
    return _moreView;
}

#pragma mark - UdeskChatToolBarMoreViewDelegate
//点击自定义的按钮
- (void)didSelectCustomMoreMenuItem:(UMCMoreToolBar *)moreMenuItem atIndex:(NSInteger)index {
    
    [self callbackCustomButtonActionWithIndex:index];
}

//回调
- (void)callbackCustomButtonActionWithIndex:(NSInteger)index {
    
    NSArray *customButtons = self.sdkConfig.customButtons;
    if (index >= customButtons.count) return;
    
    UMCCustomButtonConfig *customButton = customButtons[index];
    if (customButton.clickBlock) {
        customButton.clickBlock(customButton,self);
    }
}

//点击默认的按钮
- (void)didSelectMoreMenuItem:(UMCMoreToolBar *)moreMenuItem itemType:(UMCMoreToolBarType)itemType {
    
    switch (itemType) {
        case UMCMoreToolBarTypeAlubm:
            
            //打开相册
            [self openCustomerAlubm];
            break;
        case UMCMoreToolBarTypeShoot:
            
            //打开拍摄
            [self openShoot];
            break;
        case UMCMoreToolBarTypeSurvey:
            
            //评价
            [self showSurveyWithWithMerchantEuid:self.merchantEuid agentInvite:NO];
            break;
        case UMCMoreToolBarTypeShootVideo:
            
            //拍视频
            [self openShootSmallVideo];
            break;
        case UMCMoreToolBarTypeFile:
            
            //打开文件
            [self openDocument];
            break;
            
        default:
            break;
    }
}

//选择图片
- (void)openCustomerAlubm {
    
    [self inputBarHide:NO];
    [self.imagePicker showWithSourceType:UIImagePickerControllerSourceTypePhotoLibrary viewController:self];
    
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
    //选择了视频
    self.imagePicker.FinishVideoBlock = ^(NSString *filePath, NSString *fileName) {
        @udStrongify(self);
        [self sendVideoMessageWithVideoFile:filePath];
    };
}

//选择拍摄
- (void)openShoot {
    
    [self inputBarHide:NO];
    [self.imagePicker showWithSourceType:UIImagePickerControllerSourceTypeCamera viewController:self];
    
    //选择了普通图片
    @udWeakify(self);
    self.imagePicker.FinishNormalImageBlock = ^(UIImage *image) {
        @udStrongify(self);
        [self sendImageMessageWithImage:image];
    };
}

//开启用户相机
- (void)openShootSmallVideo {
    
    //检查权限
    [UMCPrivacyUtil checkPermissionsOfCamera:^{
        
        if ([[UMCHelper currentViewController] isKindOfClass:[UdeskSmallVideoViewController class]]) {
            return ;
        }
        
        [UMCPrivacyUtil checkPermissionsOfAudio:^{
            
            UdeskSmallVideoViewController *smallVideoVC = [[UdeskSmallVideoViewController alloc] init];
            smallVideoVC.delegate = self;
            
            UdeskSmallVideoNavigationController *nav = [[UdeskSmallVideoNavigationController alloc] initWithRootViewController:smallVideoVC];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        }];
    }];
}

//打开文件
- (void)openDocument {
    // 根据需求添加具体文件格式
    NSArray *documentTypes = @[@"public.content",
                               @"public.text",
                               @"public.source-code",
                               @"public.image",
                               @"public.archive",
                               @"public.data",
                               @"public.audiovisual-content",
                               @"com.adobe.pdf",
                               @"com.apple.keynote.key",
                               @"com.microsoft.word.doc",
                               @"com.microsoft.excel.xls",
                               @"com.microsoft.powerpoint.ppt"];
    UIDocumentPickerViewController *documentPicker = [[UIDocumentPickerViewController alloc] initWithDocumentTypes:documentTypes inMode:UIDocumentPickerModeImport];
    documentPicker.delegate = self;
    documentPicker.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

#pragma mark - UIDocumentPickerDelegate
- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    
    NSFileCoordinator *coordinator = [[NSFileCoordinator alloc] initWithFilePresenter:nil];
    NSError *error = nil;
    [coordinator coordinateReadingItemAtURL:url options:0 error:&error byAccessor:^(NSURL *newURL) {
        NSData *data = [NSData dataWithContentsOfURL:newURL];
        if (data.length <= 0) {
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"udesk_file_not_exist",@"") message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"udesk_sure",@"") style:(UIAlertActionStyleDefault) handler:^(UIAlertAction * _Nonnull action) {

            }];
            [alertCtrl addAction:confirmAction];
            [self presentViewController:alertCtrl animated:YES completion:nil];
            return;
        }

        [self sendFileMessageWithFilePath:[newURL path]];
        [controller dismissViewControllerAnimated:YES completion:nil];
    }];
    if (error) {
        NSLog(@"ERROR: read data with DocumentAtURL failed");
    }
}

#pragma mark - @protocol UdeskSmallVideoViewControllerDelegate
//拍摄视频
- (void)didFinishRecordSmallVideo:(NSDictionary *)videoInfo {
    
    if (![videoInfo.allKeys containsObject:@"videoURL"]) {
        return;
    }
    NSString *url = videoInfo[@"videoURL"];
    [self sendVideoMessageWithVideoFile:url];
}

//拍摄图片
- (void)didFinishCaptureImage:(UIImage *)image {
    
    [self sendImageMessageWithImage:image];
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
- (void)keyboardChangedWithTransition:(UdeskYYKeyboardTransition)transition {
    
    if (self.inputBar.selectInputBarType != UMCInputBarTypeText) {
        return;
    }
    
    CGRect toFrame =  [[Udesk_YYKeyboardManager defaultManager] convertRect:transition.toFrame toView:self.view];
    [UIView animateWithDuration:0.35 animations:^{
        self.inputBar.umcBottom = CGRectGetMinY(toFrame) + (kUMCIPhoneXSeries?34:0);
        if (!transition.toVisible && kUMCIPhoneXSeries) {
            self.inputBar.umcBottom -= 34;
        }
        self.imTableView.umcTop = self.sdkConfig.product?self.productView.umcBottom:0;
        self.imTableView.contentInset = UIEdgeInsetsMake(0, 0, self.view.umcHeight - CGRectGetMinY(self.inputBar.frame), 0);
        if (transition.toVisible) {
            [self.imTableView scrollToBottomAnimated:NO];
            self.emojiView.alpha = 0.0;
            self.moreView.alpha = 0.0;
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
    
    [self.UIManager sendImageMessage:image progress:^(UMCMessage *message, float percent) {
        [self updateMediaProgress:percent uploadMessage:message];
    } completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
        [self updateMediaProgress:message.messageStatus == UMCMessageStatusSuccess?1:0 uploadMessage:message];
    }];
}

//发送GIF图片
- (void)sendGIFMessageWithGIFData:(NSData *)gifData {
    if (!gifData || gifData == (id)kCFNull) return ;
    
    [self.UIManager sendGIFImageMessage:gifData progress:^(UMCMessage *message, float percent) {
        [self updateMediaProgress:percent uploadMessage:message];
    } completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
        [self updateMediaProgress:message.messageStatus == UMCMessageStatusSuccess?1:0 uploadMessage:message];
    }];
}

#pragma mark - 发送视频
- (void)sendVideoMessageWithVideoFile:(NSString *)videoFile {
    if (!videoFile || videoFile == (id)kCFNull) return ;
    if (![videoFile isKindOfClass:[NSString class]]) return ;
    
    NSData *videoData = [NSData dataWithContentsOfFile:videoFile];
    if (!videoData || videoData == (id)kCFNull) {
        videoData = [NSData dataWithContentsOfURL:[NSURL URLWithString:videoFile]];
    }

    if (!videoData || videoData == (id)kCFNull) return ;
    if (![videoData isKindOfClass:[NSData class]]) return ;
    
    [self.UIManager sendVideoMessage:videoData progress:^(UMCMessage *message, float percent) {
        [self updateMediaProgress:percent uploadMessage:message];
    } completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
        [self updateMediaProgress:message.messageStatus == UMCMessageStatusSuccess?1:0 uploadMessage:message];
    }];
}

#pragma mark - 发送文件
- (void)sendFileMessageWithFilePath:(NSString *)filePath {
    if (!filePath || filePath == (id)kCFNull) return ;
    if (![filePath isKindOfClass:[NSString class]]) return ;
    
    [self.UIManager sendFileMessage:filePath progress:^(UMCMessage *message, float percent) {
        [self updateMediaProgress:percent uploadMessage:message];
    } completion:^(UMCMessage *message) {
        [self updateSendCompletedMessage:message];
        [self updateMediaProgress:message.messageStatus == UMCMessageStatusSuccess?1:0 uploadMessage:message];
    }];
}

//更新上传进度
- (void)updateMediaProgress:(float)progress uploadMessage:(UMCMessage *)message {
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSArray *array = [self.UIManager.messagesArray valueForKey:@"messageId"];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[array indexOfObject:message.UUID] inSection:0];
        UMCBaseCell *cell = [self.imTableView cellForRowAtIndexPath:indexPath];
        [cell updateLoding:UMCMessageStatusSending];
        
        if (message.contentType == UMCMessageContentTypeImage) {
            UMCImageCell *imageCell = (UMCImageCell *)cell;
            if ([imageCell isKindOfClass:[UMCImageCell class]]) {
                if (progress > 0.0f && progress < 1.0f) {
                    [imageCell imageUploading];
                    imageCell.progressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                } else {
                    [imageCell uploadImageSuccess];
                    [imageCell updateLoding:message.messageStatus];
                }
            }
            
        } else if (message.contentType == UMCMessageContentTypeVideo) {
            UMCVideoCell *videoCell = (UMCVideoCell *)cell;
            if ([videoCell isKindOfClass:[UMCVideoCell class]]) {
                if (progress > 0.0f && progress < 1.0f) {
                    [videoCell videoUploading];
                    videoCell.uploadProgressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                } else {
                    [videoCell videoUploadSuccess];
                    [videoCell updateLoding:message.messageStatus];
                }
            }
        } else if (message.contentType == UMCMessageContentTypeFile) {
            UMCFileCell *fileCell = (UMCFileCell *)cell;
            if ([fileCell isKindOfClass:[UMCFileCell class]]) {
                [fileCell updataProgress:progress];
            }
        }
    });
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
    
    message.merchantEuid = self.merchantEuid;
    //更新商户列表最后一条消息
    if (self.UpdateLastMessageBlock) {
        self.UpdateLastMessageBlock(message);
    }
    
    NSArray *array = [self.dataSource.messagesArray valueForKey:@"messageId"];
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

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    CGFloat spacing = kUMCIPhoneXSeries?34:0;
    
    CGFloat moreViewY = CGRectGetHeight(self.view.bounds);
    if (self.inputBar.selectInputBarType == UMCInputBarTypeMore) {
        moreViewY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.moreView.frame);
    }
    self.moreView.frame = CGRectMake(0, moreViewY, CGRectGetWidth(self.view.bounds), 230 + spacing);
    
    CGFloat emotionViewY = CGRectGetHeight(self.view.bounds);
    if (self.inputBar.selectInputBarType == UMCInputBarTypeEmotion) {
        emotionViewY = CGRectGetHeight(self.view.frame) - CGRectGetHeight(self.emojiView.frame);
    }
    self.emojiView.frame = CGRectMake(0, emotionViewY, CGRectGetWidth(self.view.bounds), 230 + spacing);
}

#pragma mark - 设置背景颜色
- (void)setBackgroundColor {
    self.view.backgroundColor = self.sdkConfig.sdkStyle.chatViewControllerBackGroundColor;
    self.imTableView.backgroundColor = self.sdkConfig.sdkStyle.tableViewBackGroundColor;
}

#pragma mark - dismissChatViewController
- (void)dismissChatViewController {
    
    [UMCManager updateCustomerStatusInQueueWithMerchantEuid:self.merchantEuid
                                                 completion:^(NSError *error) {
        
    }];
    
    //已提示过满意度调查
    if (!self.afterSession) {
        [self realDismissViewController];
        return;
    }
    
    //有客服ID才弹出评价
    if (!self.merchantEuid) {
        [self realDismissViewController];
        return;
    }
    
    //已提示过满意度调查
    if (self.backAlreadyDisplayedSurvey) {
        [self realDismissViewController];
        return;
    }
    
    //检查是否已经评价
    [UMCManager checkHasSurveyWithMerchantEuid:self.merchantEuid completion:^(NSString *hasSurvey, NSError *error) {
       
        //失败
        if (error) {
            [self realDismissViewController];
            return ;
        }
        //还未评价
        if (![hasSurvey boolValue]) {
            //标记满意度只显示一次
            self.backAlreadyDisplayedSurvey = YES;
            [self showSurveyWithWithMerchantEuid:self.merchantEuid agentInvite:NO];
        }
        else {
            [self realDismissViewController];
        }
    }];
}

- (void)realDismissViewController {
    
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
    [UMCManager readMerchantsWithEuid:self.merchantEuid completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [UMCManager enterChatViewController];
}

- (void)dealloc {
    NSLog(@"%@销毁了",[self class]);
    [[Udesk_YYKeyboardManager defaultManager] removeObserver:self];
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
