//
//  UMCExpressionSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCSurveyProtocol.h"
@class UMCExpressionSurvey;

@interface UMCExpressionSurveyView : UIView

@property (nonatomic, strong) UMCExpressionSurvey *expressionSurvey;
@property (nonatomic, weak  ) id<UMCSurveyProtocol> delegate;

- (instancetype)initWithExpressionSurvey:(UMCExpressionSurvey *)expressionSurvey;

@end
