//
//  UMCOrderTestViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMCGoodsModel;

typedef NS_ENUM(NSUInteger, UMCSendType) {
    UMCSendTypeText,
    UMCSendTypeImage,
    UMCSendTypeGIF,
    UMCSendTypeVoice,
    UMCSendTypeGoods,
};

@interface UMCOrderTestViewController : UITableViewController

@property (nonatomic, copy) void(^didSendOrderBlock)(UMCSendType sendType,UMCGoodsModel *goodsModel);

@end
