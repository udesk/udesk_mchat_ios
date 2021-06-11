//
//  UMCSurveyContentView.h
//  UdeskSDK
//
//  Created by xuchen on 2018/4/2.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCSurveyTitleView.h"
#import "UMCTextSurveyView.h"
#import "UMCExpressionSurveyView.h"
#import "UMCStarSurveyView.h"
#import "UMCHPGrowingTextView.h"
#import "UMCButton.h"

@class UMCSurveyModel;
@class UMCSurveyContentView;

extern const CGFloat kUDMSurveyRemarkTextViewHeight;
extern const CGFloat kUDMSurveyRemarkTextViewMaxHeight;
extern const CGFloat kUDMSurveySubmitButtonSpacing;
extern const CGFloat kUDMSurveySubmitButtonHeight;
extern const CGFloat kUDMSurveyContentSpacing;
extern const CGFloat kUDMSurveyCollectionViewItemSizeHeight;
extern const CGFloat kUDMSurveyCollectionViewItemSizeWidth;
extern const CGFloat kUDMSurveyCollectionViewItemToVerticalEdgeSpacing;
extern const CGFloat kUDMSurveyTagsCollectionViewMinimumLineSpacing;
extern const CGFloat kUDMSurveyTagsCollectionViewMinimumInteritemSpacing;
extern const CGFloat kUDMSurveyTagsCollectionViewMaxHeight;
extern const CGFloat kUDMSurveyStarOptionHeight;
extern const CGFloat kUDMSurveyExpressionOptionHeight;
extern const CGFloat kUDMSurveyOptionToVerticalEdgeSpacing;
extern const CGFloat kUDMSurveyTitleHeight;
extern const CGFloat kUDMSurveyRemarkRequiredLabelToVerticalEdgeSpacing;

@protocol UMCSurveyViewDelegate <NSObject>

- (void)clickSubmitSurvey:(UMCSurveyContentView *)survey;
- (void)didUpdateContentView:(UMCSurveyContentView *)survey;

@end

@interface UMCSurveyContentView : UIView

/** 载体 */
@property (nonatomic, strong) UIScrollView *contentScrollerView;
/** 文本模式 */
@property (nonatomic, strong) UMCTextSurveyView *textSurveyView;
/** 表情模式 */
@property (nonatomic, strong) UMCExpressionSurveyView *expressionSurveyView;
/** 五星模式 */
@property (nonatomic, strong) UMCStarSurveyView *starSurveyView;
/** 标签 */
@property (nonatomic, strong) UICollectionView *tagsCollectionView;
/** 备注 */
@property (nonatomic, strong) UMCHPGrowingTextView *remarkTextView;
/** 备注必填 */
@property (nonatomic, strong) UILabel           *remarkRequiredLabel;
/** 提交按钮 */
@property (nonatomic, strong) UMCButton            *submitButton;

/** 数据 */
@property (nonatomic, strong) UMCSurveyModel *surveyModel;

@property (nonatomic, strong, readonly) NSNumber *selectedOptionId;
@property (nonatomic, strong, readonly) NSArray  *selectedOptionTags;

@property (nonatomic, assign) CGFloat tagsHeight;
@property (nonatomic, assign) CGFloat surveyOptionHeight;

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, weak  ) id<UMCSurveyViewDelegate> delegate;

@end
