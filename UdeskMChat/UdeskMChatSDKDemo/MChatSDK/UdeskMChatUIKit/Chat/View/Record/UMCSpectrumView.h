//
//  UMCSpectrumView.h
//  UdeskSDK
//
//  Created by Udesk on 16/8/23.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCTimerLabel.h"

@interface UMCSpectrumView : UIView

@property (nonatomic, copy) void (^itemLevelCallback)(void);

@property (nonatomic) NSUInteger numberOfItems;

@property (nonatomic) UIColor * itemColor;

@property (nonatomic) CGFloat level;

@property (nonatomic) UILabel *timeLabel;

@property (nonatomic) UMCTimerLabel *stopwatch;

@property (nonatomic) NSString *text;

@end
