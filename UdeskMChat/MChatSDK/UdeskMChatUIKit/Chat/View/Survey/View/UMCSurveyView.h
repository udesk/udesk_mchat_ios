//
//  UMCSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCSurveyContentView.h"

@interface UMCSurveyView : UIControl

@property (nonatomic, strong) UMCSurveyContentView *surveyContentView;
@property (nonatomic, strong) UIView *contentView;

- (instancetype)initWithMerchantEuid:(NSString *)merchantEuid surveyResponseObject:(id)surveyResponseObject;

- (void)show;
- (void)dismiss;

@end
