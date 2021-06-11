//
//  UMCSurveyView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/4/9.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCSurveyView.h"
#import "UMCSurveyTitleView.h"
#import "UMCSurveyManager.h"
#import "UMCBundleHelper.h"
#import "UIView+UMC.h"
#import "UMCToast.h"
#import "UMCHelper.h"
#import "NSString+UMC.h"
#import "UMCSurveyViewController.h"
#import "UMCUIMacro.h"
#import "UMCIMViewController.h"

@interface UMCSurveyView()<UMCSurveyViewDelegate> {
    
    UMCSurveyViewController *_surveyController;
}

@property (nonatomic, strong) UMCSurveyTitleView *titleView;
@property (nonatomic, strong) UMCSurveyManager *surveyManager;
@property (nonatomic, strong) UMCSurveyModel *surveyModel;

@property (nonatomic, strong) NSArray *options;

@property (nonatomic, copy  ) NSString *merchantEuid;
@property (nonatomic, strong) id surveyResponseObject;

@end

@implementation UMCSurveyView

- (instancetype)initWithMerchantEuid:(NSString *)merchantEuid surveyResponseObject:(id)surveyResponseObject;
{
    self = [super initWithFrame:[[UIScreen mainScreen] bounds]];
    if (self) {
        
        _surveyResponseObject = surveyResponseObject;
        _merchantEuid = merchantEuid;
        
        [self setupUI];
        [self fetchSurveyOptions];
    }
    return self;
}

- (void)setupUI {
    
    self.userInteractionEnabled = YES;
    
    _contentView = [[UIView alloc] initWithFrame:CGRectZero];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self addSubview:_contentView];
    
    _titleView = [[UMCSurveyTitleView alloc] initWithFrame:CGRectZero];
    [_titleView.closeButton addTarget:self action:@selector(closeSurveyViewAction:) forControlEvents:UIControlEventTouchUpInside];
    [_contentView addSubview:_titleView];
    
    _surveyContentView = [[UMCSurveyContentView alloc] init];
    _surveyContentView.delegate = self;
    [_contentView addSubview:_surveyContentView];
}

- (void)fetchSurveyOptions {
    
    [self.surveyManager fetchSurveyOptionsWithMerchantEuid:self.merchantEuid
                                              completion:^(UMCSurveyModel *surveyModel) {
        
        if (!surveyModel) {
            [self closeSurveyViewAction:nil];
            return ;
        }
        self.surveyModel = surveyModel;
        [self reloadSurveyView];
        
    } surveyResponseObject:self.surveyResponseObject];
}

//刷新UI
- (void)reloadSurveyView {
    
    self.surveyContentView.surveyModel = self.surveyModel;
    self.titleView.titleLabel.text = self.surveyModel.title;
    [self setNeedsLayout];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.surveyContentView.remarkTextView resignFirstResponder];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (!self.surveyModel || self.surveyModel == (id)kCFNull) return ;
    
    CGFloat surveyOptionHeight = 0;
    
    switch (self.surveyModel.optionType) {
        case UMCSurveyOptionTypeStar:{
            
            if (!self.surveyModel.star || self.surveyModel.star == (id)kCFNull) return ;
            if (!self.surveyModel.star.options || self.surveyModel.star.options == (id)kCFNull) return ;
            
            surveyOptionHeight = kUDMSurveyStarOptionHeight;
            self.options = self.surveyModel.star.options;
            
            break;
        }
        case UMCSurveyOptionTypeText:{
            
            if (!self.surveyModel.text || self.surveyModel.text == (id)kCFNull) return ;
            if (!self.surveyModel.text.options || self.surveyModel.text.options == (id)kCFNull) return ;
            
            NSArray *array = [self.surveyModel.text.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"enabled>0"]];
            surveyOptionHeight = array.count * ((kUDMTextSurveyButtonToVerticalEdgeSpacing+kUDMTextSurveyButtonHeight)) - kUDMTextSurveyButtonToVerticalEdgeSpacing;
            self.options = self.surveyModel.text.options;
            
            break;
        }
        case UMCSurveyOptionTypeExpression:{
            
            if (!self.surveyModel.expression || self.surveyModel.expression == (id)kCFNull) return ;
            if (!self.surveyModel.expression.options || self.surveyModel.expression.options == (id)kCFNull) return ;
            
            surveyOptionHeight = kUDMSurveyExpressionOptionHeight;
            self.options = self.surveyModel.expression.options;
            
            break;
        }
        default:
            break;
    }
    
    CGFloat tagsHeight = [self tagsHeight];
    
    CGFloat tagsCollectionHeight = tagsHeight > kUDMSurveyTagsCollectionViewMaxHeight ? kUDMSurveyTagsCollectionViewMaxHeight : tagsHeight;
    
    CGFloat surveyButtonSpacing = surveyOptionHeight ? kUDMTextSurveyButtonToVerticalEdgeSpacing : 0;
    CGFloat tagsCollectionViewSpacing = tagsCollectionHeight ? kUDMSurveyCollectionViewItemToVerticalEdgeSpacing : 0;
    
    CGFloat remarkHeight = kUDMSurveyRemarkTextViewMaxHeight;
    CGFloat remarkPlaceholderHeight = [self.surveyContentView.remarkTextView.placeholder umcSizeForFont:[UIFont systemFontOfSize:15] size:CGSizeMake(self.contentView.umcWidth-(kUDMSurveyContentSpacing*3), MAXFLOAT) mode:NSLineBreakByTruncatingTail].height + 15;
    
    if (!self.surveyContentView.remarkTextView.text.length) {
        remarkHeight = MAX(remarkPlaceholderHeight, kUDMSurveyRemarkTextViewHeight);
    }
    
    CGFloat contentHeight = kUDMSurveyTitleHeight + kUDMTextSurveyButtonToVerticalEdgeSpacing + surveyOptionHeight + surveyButtonSpacing + tagsCollectionHeight + tagsCollectionViewSpacing + remarkHeight + kUDMSurveySubmitButtonSpacing + kUDMSurveySubmitButtonHeight + kUDMSurveySubmitButtonSpacing;
    
    if (!self.surveyModel.remarkEnabled.boolValue) {
        contentHeight -= (remarkHeight+kUDMSurveySubmitButtonSpacing);
    }
    else {
        
        UMCSurveyOption *option = [self selectedOption];
        if (option) {
            if (option.remarkOptionType == UMCRemarkOptionTypeHide) {
                contentHeight -= (remarkHeight+kUDMSurveySubmitButtonSpacing);
            }
        }
        else {
            contentHeight -= (remarkHeight+kUDMSurveySubmitButtonSpacing);
        }
    }
    
    contentHeight = kUMCIPhoneXSeries ? contentHeight+34 : contentHeight;
    
    CGFloat contentY = kUMCScreenHeight > contentHeight ? kUMCScreenHeight-contentHeight : 0;
    self.contentView.frame = CGRectMake(0, contentY, self.umcWidth, contentHeight);
    self.titleView.frame = CGRectMake(0, 0, self.contentView.umcWidth, kUDMSurveyTitleHeight);
    self.surveyContentView.frame = CGRectMake(0, self.titleView.umcBottom, self.contentView.umcWidth, contentHeight - kUDMSurveyTitleHeight);
}

//标签高度
- (CGFloat)tagsHeight {
    
    @try {
        
        NSArray *selectedOption = [self.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"optionId = %@",self.surveyContentView.selectedOptionId]];
        if (!selectedOption.count) {
            return 0;
        }
        UMCSurveyOption *optionModel = selectedOption.firstObject;
        if (!optionModel || optionModel == (id)kCFNull) return 0;
        
        if (!optionModel.enabled.boolValue) {
            return 0;
        }
        
        if ([UMCHelper isBlankString:optionModel.tags]) {
            return 0;
        }
        NSArray *array = [optionModel.tags componentsSeparatedByString:@","];
        return (ceilf(array.count/2.0)) * (kUDMSurveyCollectionViewItemSizeHeight+kUDMSurveyCollectionViewItemToVerticalEdgeSpacing) - kUDMSurveyCollectionViewItemToVerticalEdgeSpacing;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

//选择的选项
- (UMCSurveyOption *)selectedOption {
    
    @try {
        
        NSArray *selectedOption = [self.options filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"optionId = %@",self.surveyContentView.selectedOptionId]];
        UMCSurveyOption *optionModel = selectedOption.firstObject;
        if (optionModel) {
            if ([optionModel isKindOfClass:[UMCSurveyOption class]]) {
                return optionModel;
            }
        }
        return nil;
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

#pragma mark - lazy
- (UMCSurveyManager *)surveyManager {
    if (!_surveyManager) {
        _surveyManager = [[UMCSurveyManager alloc] init];
    }
    return _surveyManager;
}

#pragma mark - Button Action
- (void)clickSubmitSurvey:(UMCSurveyContentView *)survey {
    
    [self.surveyContentView.remarkTextView resignFirstResponder];
    if (!self.merchantEuid || self.merchantEuid == (id)kCFNull) return ;
    
    @try {
        
        if (!survey.selectedOptionId || survey.selectedOptionId == (id)kCFNull) {
            [UMCToast showToast:UMCLocalizedString(@"udesk_survey_tips") duration:0.5f window:self];
            return;
        }
        
        UMCSurveyOption *option = [self selectedOption];
        if (self.surveyModel.remarkEnabled.boolValue && option && option.remarkOptionType == UMCRemarkOptionTypeRequired) {
            if (!self.surveyContentView.remarkTextView.text.length) {
                [UMCToast showToast:UMCLocalizedString(@"udesk_survey_remark_required") duration:0.5f window:self];
                return;
            }
        }
        
        NSDictionary *parameters = @{
                                     @"option_id":survey.selectedOptionId,
                                     @"type":[self.surveyModel stringWithOptionType],
                                     };
        
        [self.surveyManager submitSurveyWithParameters:parameters surveyRemark:survey.remarkTextView.text tags:survey.selectedOptionTags merchantEuid:self.merchantEuid completion:^(NSError *error) {
            NSString *string = UMCLocalizedString(@"udesk_top_view_thanks_evaluation");
            if (error) {
                string = UMCLocalizedString(@"udesk_top_view_failure");
            }
            [UMCToast showToast:string duration:0.5f window:self];
            dispatch_time_t delayTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6/*延迟执行时间*/ * NSEC_PER_SEC));
            dispatch_after(delayTime, dispatch_get_main_queue(), ^{
                [self closeSurveyViewAction:nil];
            });
        }];
        
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (void)didUpdateContentView:(UMCSurveyContentView *)survey {
    [self setNeedsLayout];
}

- (void)closeSurveyViewAction:(UMCButton *)button {
    [self.surveyContentView.remarkTextView resignFirstResponder];
    [self dismiss];
}

- (void)dismiss {
    [_surveyController dismissWithCompletion:nil];
}

- (void)dismissWithCompletion:(void (^)(void))completion {
    [_surveyController dismissWithCompletion:completion];
}

- (void)show {
    [self showWithCompletion:nil];
}

- (void)showWithCompletion:(void (^)(void))completion {
    
    if ([[UMCHelper currentViewController] isKindOfClass:[UMCSurveyViewController class]]) {
        return;
    }
    
    if (![[UMCHelper currentViewController] isKindOfClass:[UMCIMViewController class]]) {
        return;
    }
    
    _surveyController = [[UMCSurveyViewController alloc] init];
    [_surveyController showSurveyView:self completion:completion];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
