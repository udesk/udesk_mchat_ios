//
//  UMCCustomToolBar.h
//  UdeskMChatExample
//
//  Created by xuchen on 2018/6/28.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UMCCustomToolBar;
@class UMCCustomButtonConfig;

@protocol UMCCustomToolBarDelegate <NSObject>

@optional
- (void)didSelectCustomToolBar:(UMCCustomToolBar *)toolBar atIndex:(NSInteger)index;

@end

@interface UMCCustomToolBar : UIView

@property (nonatomic, weak) id<UMCCustomToolBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame customButtonConfigs:(NSArray<UMCCustomButtonConfig *> *)customButtonConfigs;

@end
