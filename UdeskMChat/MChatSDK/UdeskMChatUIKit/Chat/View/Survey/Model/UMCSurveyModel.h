//
//  UMCSurveyModel.h
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, UMCSurveyOptionType) {
    UMCSurveyOptionTypeText, //文本
    UMCSurveyOptionTypeExpression, //表情
    UMCSurveyOptionTypeStar, //星星
};

typedef NS_ENUM(NSUInteger, UMCRemarkOptionType) {
    UMCRemarkOptionTypeHide, //隐藏
    UMCRemarkOptionTypeRequired, //必填
    UMCRemarkOptionTypeOptional, //选填
};

@interface UMCSurveyOption : NSObject

@property (nonatomic, strong) NSNumber *optionId;
@property (nonatomic, strong) NSNumber *enabled; //是否启用
@property (nonatomic, copy  ) NSString *text;
@property (nonatomic, copy  ) NSString *desc;
@property (nonatomic, copy  ) NSString *tags;
@property (nonatomic, copy  ) NSString *remarkOption;
@property (nonatomic, assign) UMCRemarkOptionType remarkOptionType;

@end

@interface UMCStarSurvey : NSObject

@property (nonatomic, strong) NSNumber *defaultOptionId;
@property (nonatomic, strong) NSArray<UMCSurveyOption *>  *options;

@end

@interface UMCExpressionSurvey : NSObject

@property (nonatomic, strong) NSNumber *defaultOptionId;
@property (nonatomic, strong) NSArray<UMCSurveyOption *>  *options;

@end

@interface UMCTextSurvey : NSObject

@property (nonatomic, strong) NSNumber *defaultOptionId;
@property (nonatomic, strong) NSArray<UMCSurveyOption *>  *options;

@end

@interface UMCSurveyModel : NSObject

@property (nonatomic, strong) NSNumber *enabled; //是否开启
@property (nonatomic, strong) NSNumber *remarkEnabled; //评价备注开关
@property (nonatomic, copy  ) NSString *remark; //评价内容
@property (nonatomic, copy  ) NSString *name;
@property (nonatomic, copy  ) NSString *title;
@property (nonatomic, copy  ) NSString *desc;
@property (nonatomic, copy  ) NSString *showType;
@property (nonatomic, strong) UMCTextSurvey *text;
@property (nonatomic, strong) UMCExpressionSurvey *expression;
@property (nonatomic, strong) UMCStarSurvey *star;

@property (nonatomic, assign) UMCSurveyOptionType optionType;

- (instancetype)initWithDictionary:(NSDictionary *)dictionary;

- (NSString *)stringWithOptionType;

@end
