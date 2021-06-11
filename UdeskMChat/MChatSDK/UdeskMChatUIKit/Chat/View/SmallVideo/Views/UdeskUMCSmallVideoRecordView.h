//
//  UdeskSmallVideoRecordView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/13.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@class UdeskUMCSmallVideoRecordView;
@protocol UdeskUMCSmallVideoRecordViewDelegate <NSObject>

@required
- (void)smallVideoRecordView:(UdeskUMCSmallVideoRecordView *)recordView gestureRecognizer:(UIGestureRecognizer *)gest;
- (void)smallVideoRecordView:(UdeskUMCSmallVideoRecordView *)recordView recordDuration:(CGFloat)recordDuration;

@end

@interface UdeskUMCSmallVideoRecordView : UIView

@property (nonatomic, weak  )id <UdeskUMCSmallVideoRecordViewDelegate>delegate;
@property (nonatomic, assign)NSInteger duration;

@end
