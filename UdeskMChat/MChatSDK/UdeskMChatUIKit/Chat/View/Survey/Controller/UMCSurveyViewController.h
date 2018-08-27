//
//  UMCSurveyViewController.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMCSurveyView;

@interface UMCSurveyViewController : UIViewController

@property(nonatomic, strong, readonly) UMCSurveyView *surveyView;

- (void)showSurveyView:(UMCSurveyView *)surveyView completion:(void (^)(void))completion;
- (void)dismissWithCompletion:(void (^)(void))completion;

@end
