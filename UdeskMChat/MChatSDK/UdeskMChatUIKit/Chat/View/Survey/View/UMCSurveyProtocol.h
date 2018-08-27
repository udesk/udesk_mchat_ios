//
//  UMCSurveyProtocol.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/30.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UMCSurveyOption;

@protocol UMCSurveyProtocol <NSObject>

- (void)didSelectExpressionSurveyWithOption:(UMCSurveyOption *)option;

@end
