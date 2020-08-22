//
//  UMCMoreToolBar.h
//  UdeskMChatExample
//
//  Created by xuchen on 2018/3/20.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMCMoreToolBar;

typedef NS_ENUM(NSUInteger, UMCMoreToolBarType) {
    UMCMoreToolBarTypeAlubm,      //相册
    UMCMoreToolBarTypeShoot,      //拍摄
    UMCMoreToolBarTypeSurvey,     //评价
    UMCMoreToolBarTypeShootVideo, //拍摄视频
    UMCMoreToolBarTypeFile,       //文件
};

@protocol UMCMoreToolBarDelegate <NSObject>

@optional
- (void)didSelectMoreMenuItem:(UMCMoreToolBar *)moreMenuItem itemType:(UMCMoreToolBarType)itemType;
- (void)didSelectCustomMoreMenuItem:(UMCMoreToolBar *)moreMenuItem atIndex:(NSInteger)index;

@end

@interface UMCMoreToolBar : UIView

@property (nonatomic, assign) BOOL enableSurvey;
@property (nonatomic, strong) NSArray *customMenuItems;
@property (nonatomic, weak  ) id<UMCMoreToolBarDelegate> delegate;

@end
