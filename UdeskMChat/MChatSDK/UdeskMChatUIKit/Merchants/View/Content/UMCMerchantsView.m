//
//  UMCMerchantsView.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCMerchantsView.h"
#import "UMCMerchantsManager.h"
#import "UMCMerchantsDataSource.h"
#import "UMCUIMacro.h"
#import "UIView+UMC.h"
#import "UMCSDKManager.h"
#import "UMCBundleHelper.h"
#import "UIColor+UMC.h"
#import "UMCSDKConfig.h"

static CGFloat const kUDMerchantsSearchHeight = 44;

@interface UMCMerchantsView() <UITableViewDelegate,UMCMerchantsDataSourceDelegate,UISearchBarDelegate,UMCMessageDelegate>

@property (nonatomic, strong) UMCSDKConfig           *sdkConfig;

@property (nonatomic, strong) UMCMerchantsManager    *merchantsManager;
@property (nonatomic, strong) UMCMerchantsDataSource *dataSource;
@property (nonatomic, strong) UITableView            *merchantsTableView;
@property (nonatomic, strong) UISearchBar            *searchBar;
//正在会话的商户ID
@property (nonatomic, strong) NSString               *currentMerchantEuid;

@end

@implementation UMCMerchantsView

- (instancetype)initWithFrame:(CGRect)frame sdkConfig:(UMCSDKConfig *)sdkConfig
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _sdkConfig = sdkConfig;
        [self setup];
        [self fetchMerchants];
        [[UMCDelegate shareInstance] addDelegate:self];
    }
    return self;
}

- (void)setup {
    
    if (!self.sdkConfig.hiddenMerchantsSearch) {
        
        _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kUMCScreenWidth, kUDMerchantsSearchHeight)];
        _searchBar.backgroundImage = [UIImage new];
        _searchBar.backgroundColor = [UIColor whiteColor];
        _searchBar.barTintColor = [UIColor whiteColor];
        _searchBar.tintColor = [UIColor colorWithRed:0.925f  green:0.937f  blue:0.945f alpha:1];
        _searchBar.delegate = self;
        _searchBar.placeholder = UMCLocalizedString(@"udesk_search");
        [_searchBar sizeToFit];
        
        UIView *searchTextField = [[[_searchBar.subviews firstObject] subviews] lastObject];
        
        searchTextField.backgroundColor = [UIColor umcColorWithHexString:@"#E7E7EB"];
        [searchTextField.layer setCornerRadius:3.0f];
        [searchTextField.layer setMasksToBounds:YES];
        
        [self addSubview:_searchBar];
    }
    
    _merchantsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, _searchBar.umcBottom, self.umcWidth, self.umcHeight-kUDMerchantsSearchHeight) style:UITableViewStylePlain];
    _merchantsTableView.delegate = self;
    _merchantsTableView.dataSource = self.dataSource;
    _merchantsTableView.rowHeight = 65;
    _merchantsTableView.tableFooterView = [UIView new];
    [self addSubview:_merchantsTableView];
    
    //添加单击手势
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapMerchantsTableView)];
    tap.cancelsTouchesInView = false;
    [_merchantsTableView addGestureRecognizer:tap];
    
    //监听app是否从后台进入前台
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(umcMerchantsApplicationBecomeActive) name:UIApplicationWillEnterForegroundNotification object:nil];
}

//监听app是否从后台进入前台
- (void)umcMerchantsApplicationBecomeActive {
    
    [self fetchMerchants];
}

- (void)didTapMerchantsTableView {
    [self endEditing:YES];
}

#pragma mark - @protocol UMCMerchantsDataSourceDelegate
- (void)deleteMerchantForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.dataSource.merchantsArray.count <= indexPath.row) {
        return;
    }
    
    UMCMerchant *merchant = self.dataSource.merchantsArray[indexPath.row];
    @udWeakify(self);
    [self.merchantsManager deleteMerchantsWithModel:merchant completion:^(BOOL result) {
        @udStrongify(self);
        //改变未读消息
        [self unreadCountHasChange];
        [self reloadMerchantsTableView];
    }];
}

#pragma mark - @protocol UITableViewDelegate
//设置滑动显示的文字
- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UMCLocalizedString(@"udesk_delete");
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (self.dataSource.merchantsArray.count <= indexPath.row) {
        return;
    }
    
    UMCMerchant *merchant = self.dataSource.merchantsArray[indexPath.row];
    
    //清空未读消息
    if (merchant.unreadCount.integerValue > 0) {
        merchant.unreadCount = @"";
        [self.merchantsTableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    _currentMerchantEuid = merchant.euid;
    _sdkConfig.imTitle = merchant.name;
    UMCSDKManager *sdkManager = [[UMCSDKManager alloc] initWithMerchantEuid:merchant.euid];
    sdkManager.sdkConfig = _sdkConfig;
    [sdkManager pushUdeskInViewController:self.viewController completion:nil];
    
    @udWeakify(self);
    sdkManager.UpdateLastMessageBlock = ^(UMCMessage *message) {
        @udStrongify(self);
        [self didReceiveMessage:message];
    };
    
    self.sdkConfig.leaveChatViewController = ^{
        @udStrongify(self);
        self.currentMerchantEuid = nil;
    };
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self endEditing:YES];
}

#pragma mark - UISearchBarDelegate
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self.merchantsManager searchMerchants:searchText completion:^(NSArray *resultArray) {
        self.dataSource.merchantsArray = resultArray;
        [self.merchantsTableView reloadData];
    }];
}

#pragma mark - UMCManagerDelegate
- (void)didReceiveMessage:(UMCMessage *)message {
    
    NSArray *euidArray = [self.dataSource.merchantsArray valueForKey:@"euid"];
    if ([euidArray containsObject:message.merchantEuid]) {
        NSInteger index = [euidArray indexOfObject:message.merchantEuid];
        UMCMerchant *merchant = [self.dataSource.merchantsArray objectAtIndex:index];
        if (!merchant) return;
        
        if (![message.merchantEuid isEqualToString:self.currentMerchantEuid]) {
            merchant.unreadCount = [NSString stringWithFormat:@"%ld",merchant.unreadCount.integerValue + 1];
        }
        
        //撤回消息
        if (message.category == UMCMessageCategoryTypeEvent && message.eventType == UMCEventContentTypeRollback) {
            [self fetchMerchants];
        }
        else {
            merchant.lastMessage = message;
        }
        
        [self.merchantsTableView reloadData];
    }
    else {
        [self fetchMerchants];
    }
}

- (void)unreadCountHasChange {
    
    [[NSNotificationCenter defaultCenter] postNotificationName:UMC_UNREAD_MSG_HAS_CHANED_NOTIFICATION object:nil userInfo:nil];
}

#pragma mark - DATA
- (void)fetchMerchants {
    
    @udWeakify(self);
    [self.merchantsManager fetchMerchants:^{
        @udStrongify(self);
        [self reloadMerchantsTableView];
    }];
}

- (void)reloadMerchantsTableView {
    
    if (self.currentMerchantEuid) {
        [self.merchantsManager.merchantsArray enumerateObjectsUsingBlock:^(UMCMerchant *merchant, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([merchant.euid isEqualToString:self.currentMerchantEuid]) {
                merchant.unreadCount = @"";
                *stop = YES;
            }
        }];
    }
    
    self.dataSource.merchantsArray = self.merchantsManager.merchantsArray;
    [self.merchantsTableView reloadData];
}

- (UMCMerchantsManager *)merchantsManager {
    if (!_merchantsManager) {
        _merchantsManager = [[UMCMerchantsManager alloc] init];
    }
    return _merchantsManager;
}

- (UMCMerchantsDataSource *)dataSource {
    if (!_dataSource) {
        _dataSource = [[UMCMerchantsDataSource alloc] init];
        _dataSource.delegate = self;
    }
    return _dataSource;
}

- (void)dealloc
{
    [_sdkConfig setConfigToDefault];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
}

@end

