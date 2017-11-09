//
//  UMCIMTableView.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UMCIMTableView : UITableView

/**
 *  头视图
 */
@property (nonatomic, strong) UIView                  *headView;
/**
 *  loading
 */
@property (nonatomic, strong) UIActivityIndicatorView *loadingView;
/**
 *  记录刷新状态
 */
@property (nonatomic, assign) BOOL                    isRefresh;

/**
 *  开始加载更多消息
 */
- (void)startLoadingMoreMessages;
/**
 *  加载结束更多消息
 */
- (void)finishLoadingMoreMessages:(BOOL)isShowRefresh;
/**
 *  设置TableView bottom
 *
 *  @param bottom bottom
 */
- (void)setTableViewInsetsWithBottomValue:(CGFloat)bottom;
/**
 *  TableView 滚到底部
 *
 *  @param animated 是否动画
 */
- (void)scrollToBottomAnimated:(BOOL)animated;

@end
