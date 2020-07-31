//
//  UMCStarSurveyView.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCStarSurveyView.h"
#import "Udesk_HCSStarRatingView.h"
#import "UMCSurveyModel.h"
#import "UIImage+UMC.h"
#import "UIView+UMC.h"

static CGFloat kUDSurveyStarViewToVerticalEdgeSpacing = 12;
static CGFloat kUDSurveyStarViewWidth = 215;
static CGFloat kUDSurveyStarViewHeight = 28;
static CGFloat kUDSurveyTipLabelHeight = 18;

@interface UMCStarSurveyView()

@property (nonatomic, strong) Udesk_HCSStarRatingView *starRatingView;
@property (nonatomic, strong) UILabel *tipLabel;

@end

@implementation UMCStarSurveyView

- (instancetype)initWithStarSurvey:(UMCStarSurvey *)starSurvey
{
    self = [super init];
    if (self) {
        _starSurvey = starSurvey;
    }
    return self;
}

- (void)setStarSurvey:(UMCStarSurvey *)starSurvey {
    if (!starSurvey || starSurvey == (id)kCFNull) return ;
    _starSurvey = starSurvey;
    
    _starRatingView = [[Udesk_HCSStarRatingView alloc] init];
    _starRatingView.maximumValue = 5;
    _starRatingView.allowsHalfStars = NO;
    _starRatingView.emptyStarImage = [UIImage umcDefaultSurveyStarEmptyImage];
    _starRatingView.filledStarImage = [UIImage umcDefaultSurveyStarFilledImage];
    [_starRatingView addTarget:self action:@selector(didChangeValue:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:_starRatingView];
    
    _tipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _tipLabel.textColor = [UIColor colorWithRed:0.165f  green:0.576f  blue:0.98f alpha:1];
    _tipLabel.font = [UIFont systemFontOfSize:14];
    _tipLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:_tipLabel];
    
    NSArray *optionIds = [starSurvey.options valueForKey:@"optionId"];
    if ([optionIds containsObject:starSurvey.defaultOptionId]) {
        NSInteger index = [optionIds indexOfObject:starSurvey.defaultOptionId];
        UMCSurveyOption *option = starSurvey.options[index];
        _tipLabel.text = option.text;
        
        int newIndex = fabs((CGFloat)index - 5);
        _starRatingView.value = newIndex;
    }
}

- (void)didChangeValue:(Udesk_HCSStarRatingView *)sender {
    
    int index = fabs(sender.value - 5);
    if (index >=0 && self.starSurvey.options.count > index) {
        UMCSurveyOption *option = self.starSurvey.options[index];
        _tipLabel.text = option.text;
    }
    
    if (index >=0 && self.starSurvey.options.count > index) {
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectExpressionSurveyWithOption:)]) {
            [self.delegate didSelectExpressionSurveyWithOption:self.starSurvey.options[index]];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _starRatingView.frame = CGRectMake((self.umcWidth-kUDSurveyStarViewWidth)/2, kUDSurveyStarViewToVerticalEdgeSpacing, kUDSurveyStarViewWidth, kUDSurveyStarViewHeight);
    _tipLabel.frame = CGRectMake(0, _starRatingView.umcBottom+kUDSurveyStarViewHeight, self.umcWidth, kUDSurveyTipLabelHeight);
}

@end
