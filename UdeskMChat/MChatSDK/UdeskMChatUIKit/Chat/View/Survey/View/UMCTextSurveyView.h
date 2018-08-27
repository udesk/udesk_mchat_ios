//
//  UMCTextSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCSurveyProtocol.h"
@class UMCTextSurvey;

/** 头像距离屏幕水平边沿距离 */
extern const CGFloat kUDTextSurveyButtonToVerticalEdgeSpacing;
extern const CGFloat kUDTextSurveyButtonHeight;

@interface UMCTextSurveyView : UIView

@property (nonatomic, strong) UMCTextSurvey *textSurvey;
@property (nonatomic, weak  ) id<UMCSurveyProtocol> delegate;

- (instancetype)initWithTextSurvey:(UMCTextSurvey *)textSurvey;

@end
