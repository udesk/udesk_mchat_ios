//
//  UMCSurveyManager.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UMCSurveyModel.h"

@interface UMCSurveyManager : NSObject

//满意度调查配置选项
- (void)fetchSurveyOptionsWithMerchantId:(NSString *)merchantId
                              completion:(void(^)(UMCSurveyModel *surveyModel))completion
                    surveyResponseObject:(id)surveyResponseObject;
//提交满意度调查
- (void)submitSurveyWithParameters:(NSDictionary *)parameters
                      surveyRemark:(NSString *)surveyRemark
                              tags:(NSArray *)tags
                        merchantId:(NSString *)merchantId
                        completion:(void(^)(NSError *error))completion;
//检查是否已经评价
- (void)checkHasSurveyWithMerchantId:(NSString *)merchantId
                          completion:(void(^)(BOOL result,NSError *error))completion;

@end
