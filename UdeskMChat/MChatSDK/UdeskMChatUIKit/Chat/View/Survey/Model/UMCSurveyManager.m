//
//  UMCSurveyManager.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/24.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCSurveyManager.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>
#import "UMCHelper.h"

@implementation UMCSurveyManager

- (void)fetchSurveyOptionsWithMerchantEuid:(NSString *)merchantEuid
                                completion:(void(^)(UMCSurveyModel *surveyModel))completion
                      surveyResponseObject:(id)surveyResponseObject {
    
    if (surveyResponseObject) {
        UMCSurveyModel *surveyModel = [self surveyModelWithResponseObject:surveyResponseObject];
        if (completion) {
            completion(surveyModel);
        }
        return;
    }
    
    [UMCManager getSurveyOptionsWithMerchantEuid:merchantEuid completion:^(id responseObject, NSError *error) {
        
        @try {
            
            if (error) {
                NSLog(@"%@",error);
                if (completion) {
                    completion(nil);
                }
                return ;
            }
            
            UMCSurveyModel *surveyModel = [self surveyModelWithResponseObject:responseObject];
            if (completion) {
                completion(surveyModel);
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        
    } configHandle:nil];
}

- (UMCSurveyModel *)surveyModelWithResponseObject:(id)responseObject {
    
    NSDictionary *result = responseObject[@"im_survey"];
    if (!result || result == (id)kCFNull) return nil;
    if (![result isKindOfClass:[NSDictionary class]]) return nil;
    
    UMCSurveyModel *surveyModel = [[UMCSurveyModel alloc] initWithDictionary:result];
    return surveyModel;
}


//提交满意度调查
- (void)submitSurveyWithParameters:(NSDictionary *)parameters
                      surveyRemark:(NSString *)surveyRemark
                              tags:(NSArray *)tags
                      merchantEuid:(NSString *)merchantEuid
                        completion:(void(^)(NSError *error))completion {
    
    if (!parameters || parameters == (id)kCFNull) return ;
    if (![parameters isKindOfClass:[NSDictionary class]]) return;
    if (!merchantEuid || merchantEuid == (id)kCFNull) return ;
    
    NSArray *array = [parameters allKeys];
    if (![array containsObject:@"option_id"]) return;
    if (![array containsObject:@"type"]) return;
    
    NSMutableDictionary *mParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    
    if (![UMCHelper isBlankString:surveyRemark]) {
        [mParameters setObject:surveyRemark forKey:@"survey_remark"];
    }
    
    if (tags.count) {
        NSString *tagsString = [tags componentsJoinedByString:@","];
        if (![UMCHelper isBlankString:tagsString]) {
            [mParameters setObject:tagsString forKey:@"tags"];
        }
    }
    
    [UMCManager submitSurveyWithMerchantEuid:merchantEuid parameters:@{@"survey":mParameters} completion:completion];
}

//检查是否已经评价
- (void)checkHasSurveyWithMerchantEuid:(NSString *)merchantEuid
                            completion:(void(^)(BOOL result,NSError *error))completion {
    
    [UMCManager checkHasSurveyWithMerchantEuid:merchantEuid completion:^(NSString *hasSurvey, NSError *error) {
        
        if (completion) {
            completion(hasSurvey.boolValue,error);
        }
    }];
}

@end
