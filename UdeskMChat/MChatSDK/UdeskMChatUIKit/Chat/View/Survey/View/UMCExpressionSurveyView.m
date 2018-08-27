//
//  UMCExpressionSurveyView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCExpressionSurveyView.h"
#import "UMCSurveyModel.h"
#import "UMCButton.h"
#import "UIImage+UMC.h"
#import "UMCBundleHelper.h"
#import "UIView+UMC.h"
#import "UMCUIMacro.h"

static CGFloat kUDSurveyExpressionSize = 90;
static CGFloat kUDSurveyExpressionSpacing = 13;
static CGFloat kUDSurveyExpressionToVerticalEdgeSpacing = 10;

@interface UMCExpressionSurveyView()

@property (nonatomic, strong) UIImageView *satisfiedImageView;
@property (nonatomic, strong) UIImageView *generalImageView;
@property (nonatomic, strong) UIImageView *unsatisfactoryImageView;

@property (nonatomic, strong) UILabel *satisfiedLabel;
@property (nonatomic, strong) UILabel *generalLabel;
@property (nonatomic, strong) UILabel *unsatisfactoryLabel;

@property (nonatomic, strong) UIView  *satisfiedView;
@property (nonatomic, strong) UIView  *generalView;
@property (nonatomic, strong) UIView  *unsatisfactoryView;

@end

@implementation UMCExpressionSurveyView

- (instancetype)initWithExpressionSurvey:(UMCExpressionSurvey *)expressionSurvey
{
    self = [super init];
    if (self) {
        _expressionSurvey = expressionSurvey;
    }
    return self;
}

- (void)setExpressionSurvey:(UMCExpressionSurvey *)expressionSurvey {
    if (!expressionSurvey || expressionSurvey == (id)kCFNull) return ;
    _expressionSurvey = expressionSurvey;
    
    _satisfiedView = [self expressionView];
    [_satisfiedView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapSatisfiedAction)]];
    [self addSubview:_satisfiedView];
    _satisfiedImageView = [self expressionImageViewWithImage:[UIImage umcDefaultSurveyExpressionSatisfiedImage]];
    [_satisfiedView addSubview:_satisfiedImageView];
    _satisfiedLabel = [self expressionLabelWithTitle:UMCLocalizedString(@"udesk_survey_satisfied")];
    [_satisfiedView addSubview:_satisfiedLabel];
    
    _generalView = [self expressionView];
    [_generalView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapGeneralAction)]];
    [self addSubview:_generalView];
    _generalImageView = [self expressionImageViewWithImage:[UIImage umcDefaultSurveyExpressionGeneralImage]];
    [_generalView addSubview:_generalImageView];
    _generalLabel = [self expressionLabelWithTitle:UMCLocalizedString(@"udesk_survey_general")];
    [_generalView addSubview:_generalLabel];
    
    _unsatisfactoryView = [self expressionView];
    [_unsatisfactoryView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapUnsatisfactoryAction)]];
    [self addSubview:_unsatisfactoryView];
    _unsatisfactoryImageView = [self expressionImageViewWithImage:[UIImage umcDefaultSurveyExpressionUnsatisfactoryImage]];
    [_unsatisfactoryView addSubview:_unsatisfactoryImageView];
    _unsatisfactoryLabel = [self expressionLabelWithTitle:UMCLocalizedString(@"udesk_survey_unsatisfactory")];
    [_unsatisfactoryView addSubview:_unsatisfactoryLabel];
    
    NSArray *optionIds = [expressionSurvey.options valueForKey:@"optionId"];
    if ([optionIds containsObject:expressionSurvey.defaultOptionId]) {
        NSInteger index = [optionIds indexOfObject:expressionSurvey.defaultOptionId];
        [self updateSelectedViewWithIndex:index];
    }
}

//满意
- (void)didTapSatisfiedAction {
    
    [self updateViewUIWithFirstView:self.generalView secondView:self.unsatisfactoryView];
    [self updateSelectedViewWithIndex:0];
    
    [self callbackClickWithIndex:0];
}

//一般
- (void)didTapGeneralAction {
    
    [self updateViewUIWithFirstView:self.satisfiedView secondView:self.unsatisfactoryView];
    [self updateSelectedViewWithIndex:1];
    
    [self callbackClickWithIndex:1];
}

//不满意
- (void)didTapUnsatisfactoryAction {
    
    [self updateViewUIWithFirstView:self.satisfiedView secondView:self.generalView];
    [self updateSelectedViewWithIndex:2];
    
    [self callbackClickWithIndex:2];
}

- (void)updateSelectedViewWithIndex:(NSInteger)index {
    
    if (index == 0) {
        self.satisfiedView.backgroundColor = [UIColor colorWithRed:0.914f  green:0.98f  blue:0.937f alpha:1];
        self.satisfiedView.layer.borderColor = [UIColor colorWithRed:0.576f  green:0.902f  blue:0.682f alpha:1].CGColor;
    }
    else if (index == 1) {
        self.generalView.backgroundColor = [UIColor colorWithRed:1  green:0.969f  blue:0.89f alpha:1];
        self.generalView.layer.borderColor = [UIColor colorWithRed:1  green:0.835f  blue:0.478f alpha:1].CGColor;
    }
    else if (index == 2) {
        self.unsatisfactoryView.backgroundColor = [UIColor colorWithRed:1  green:0.922f  blue:0.922f alpha:1];
        self.unsatisfactoryView.layer.borderColor = [UIColor colorWithRed:1  green:0.608f  blue:0.6f alpha:1].CGColor;
    }
}

- (void)updateViewUIWithFirstView:(UIView *)firstView secondView:(UIView *)secondView {
    
    firstView.backgroundColor = [UIColor whiteColor];
    firstView.layer.borderColor = [UIColor colorWithRed:1  green:0.969f  blue:0.89f alpha:1].CGColor;
    
    secondView.backgroundColor = [UIColor whiteColor];
    secondView.layer.borderColor = [UIColor colorWithRed:1  green:0.969f  blue:0.89f alpha:1].CGColor;
}

- (void)callbackClickWithIndex:(NSInteger)index {
    
    if (self.expressionSurvey.options.count > index) {
     
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectExpressionSurveyWithOption:)]) {
            [self.delegate didSelectExpressionSurveyWithOption:self.expressionSurvey.options[index]];
        }
    }
}

- (UIView *)expressionView {
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    kUMCViewBorderRadius(view, 2, 1, [UIColor colorWithRed:0.937f  green:0.937f  blue:0.937f alpha:1]);
    
    return view;
}

- (UIImageView *)expressionImageViewWithImage:(UIImage *)image {
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    return imageView;
}

- (UILabel *)expressionLabelWithTitle:(NSString *)title {
    
    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor colorWithRed:0.6f  green:0.6f  blue:0.6f alpha:1];
    label.font = [UIFont systemFontOfSize:12.0];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _satisfiedView.frame = CGRectMake((self.umcWidth-(kUDSurveyExpressionSize*3 + kUDSurveyExpressionSpacing*2))/2, kUDSurveyExpressionToVerticalEdgeSpacing, kUDSurveyExpressionSize, kUDSurveyExpressionSize);
    
    CGSize satisfiedSize = _satisfiedImageView.image.size;
    _satisfiedImageView.frame = CGRectMake((_satisfiedView.umcWidth-satisfiedSize.width)/2, kUDSurveyExpressionToVerticalEdgeSpacing, satisfiedSize.width, satisfiedSize.height);
    _satisfiedLabel.frame = CGRectMake(0, _satisfiedImageView.umcBottom+16, _satisfiedView.umcWidth, 20);
    
    
    _generalView.frame = CGRectMake(_satisfiedView.umcRight+kUDSurveyExpressionSpacing, kUDSurveyExpressionToVerticalEdgeSpacing, kUDSurveyExpressionSize, kUDSurveyExpressionSize);
    
    CGSize generalSize = _generalImageView.image.size;
    _generalImageView.frame = CGRectMake((_satisfiedView.umcWidth-generalSize.width)/2, kUDSurveyExpressionToVerticalEdgeSpacing, generalSize.width, generalSize.height);
    _generalLabel.frame = CGRectMake(0, _generalImageView.umcBottom+16, _generalView.umcWidth, 20);
    
    _unsatisfactoryView.frame = CGRectMake(_generalView.umcRight+kUDSurveyExpressionSpacing, kUDSurveyExpressionToVerticalEdgeSpacing, kUDSurveyExpressionSize, kUDSurveyExpressionSize);
    
    CGSize unsatisfactorySize = _unsatisfactoryImageView.image.size;
    _unsatisfactoryImageView.frame = CGRectMake((_satisfiedView.umcWidth-unsatisfactorySize.width)/2, kUDSurveyExpressionToVerticalEdgeSpacing, unsatisfactorySize.width, unsatisfactorySize.height);
    _unsatisfactoryLabel.frame = CGRectMake(0, _unsatisfactoryImageView.umcBottom+16, _unsatisfactoryView.umcWidth, 20);
    
}

@end
