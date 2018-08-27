//
//  UMCStarSurveyView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCSurveyProtocol.h"
@class UMCStarSurvey;

@interface UMCStarSurveyView : UIView

@property (nonatomic, strong) UMCStarSurvey *starSurvey;
@property (nonatomic, weak  ) id<UMCSurveyProtocol> delegate;

- (instancetype)initWithStarSurvey:(UMCStarSurvey *)starSurvey;

@end
