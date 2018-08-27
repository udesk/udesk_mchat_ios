//
//  UMCSurveyModel.m
//  UdeskSDK
//
//  Created by xuchen on 2018/3/29.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import "UMCSurveyModel.h"

@implementation UMCSurveyOption

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        @try {
            
            NSNumber *enabled = dictionary[@"enabled"];
            if ([enabled isKindOfClass:[NSNumber class]]) {
                self.enabled = enabled;
            }
            
            NSNumber *optionId = dictionary[@"id"];
            if ([optionId isKindOfClass:[NSNumber class]]) {
                self.optionId = optionId;
            }
            
            NSString *text = dictionary[@"text"];
            if ([text isKindOfClass:[NSString class]]) {
                self.text = text;
            }
            
            NSString *desc = dictionary[@"desc"];
            if ([desc isKindOfClass:[NSString class]]) {
                self.desc = desc;
            }
            
            NSString *tags = dictionary[@"tags"];
            if ([tags isKindOfClass:[NSString class]]) {
                self.tags = tags;
            }
            
            NSString *remark_option = dictionary[@"remark_option"];
            if ([remark_option isKindOfClass:[NSString class]]) {
                self.remarkOption = remark_option;
                if ([remark_option isEqualToString:@"hide"]) {
                    self.remarkOptionType = UMCRemarkOptionTypeHide;
                }
                else if ([remark_option isEqualToString:@"required"]) {
                    self.remarkOptionType = UMCRemarkOptionTypeRequired;
                }
                else if ([remark_option isEqualToString:@"optional"]) {
                    self.remarkOptionType = UMCRemarkOptionTypeOptional;
                }
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        
    }
    return self;
}

@end

@implementation UMCStarSurvey

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        @try {
         
            NSNumber *default_option_id = dictionary[@"default_option_id"];
            if ([default_option_id isKindOfClass:[NSNumber class]]) {
                self.defaultOptionId = default_option_id;
            }
            
            NSArray *options = dictionary[@"options"];
            if ([options isKindOfClass:[NSArray class]]) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *option in options) {
                    UMCSurveyOption *optionModel = [[UMCSurveyOption alloc] initWithDictionary:option];
                    [array addObject:optionModel];
                }
                self.options = [array copy];
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

@end

@implementation UMCExpressionSurvey

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        @try {
            
            NSNumber *default_option_id = dictionary[@"default_option_id"];
            if ([default_option_id isKindOfClass:[NSNumber class]]) {
                self.defaultOptionId = default_option_id;
            }
            
            NSArray *options = dictionary[@"options"];
            if ([options isKindOfClass:[NSArray class]]) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *option in options) {
                    UMCSurveyOption *optionModel = [[UMCSurveyOption alloc] initWithDictionary:option];
                    [array addObject:optionModel];
                }
                self.options = [array copy];
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
        
    }
    return self;
}

@end

@implementation UMCTextSurvey

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        @try {
         
            NSNumber *default_option_id = dictionary[@"default_option_id"];
            if ([default_option_id isKindOfClass:[NSNumber class]]) {
                self.defaultOptionId = default_option_id;
            }
            
            NSArray *options = dictionary[@"options"];
            if ([options isKindOfClass:[NSArray class]]) {
                NSMutableArray *array = [NSMutableArray array];
                for (NSDictionary *option in options) {
                    UMCSurveyOption *optionModel = [[UMCSurveyOption alloc] initWithDictionary:option];
                    [array addObject:optionModel];
                }
                self.options = [array copy];
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

@end

@implementation UMCSurveyModel

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if (self) {
        
        @try {
         
            NSNumber *enabled = dictionary[@"enabled"];
            if ([enabled isKindOfClass:[NSNumber class]]) {
                self.enabled = enabled;
            }
            
            NSString *name = dictionary[@"name"];
            if ([name isKindOfClass:[NSString class]]) {
                self.name = name;
            }
            
            NSString *remark = dictionary[@"remark"];
            if ([remark isKindOfClass:[NSString class]]) {
                self.remark = remark;
            }
            
            NSNumber *remark_enabled = dictionary[@"remark_enabled"];
            if ([remark_enabled isKindOfClass:[NSNumber class]]) {
                self.remarkEnabled = remark_enabled;
            }
            
            NSString *show_type = dictionary[@"show_type"];
            if ([show_type isKindOfClass:[NSString class]]) {
                self.showType = show_type;
                if ([show_type isEqualToString:@"expression"]) {
                    self.optionType = UMCSurveyOptionTypeExpression;
                }
                else if ([show_type isEqualToString:@"text"]) {
                    self.optionType = UMCSurveyOptionTypeText;
                }
                else if ([show_type isEqualToString:@"star"]) {
                    self.optionType = UMCSurveyOptionTypeStar;
                }
            }
            
            NSString *title = dictionary[@"title"];
            if ([title isKindOfClass:[NSString class]]) {
                self.title = title;
            }
            
            NSString *desc = dictionary[@"desc"];
            if ([desc isKindOfClass:[NSString class]]) {
                self.desc = desc;
            }
            
            NSDictionary *expression = dictionary[@"expression"];
            if ([expression isKindOfClass:[NSDictionary class]]) {
                self.expression = [[UMCExpressionSurvey alloc] initWithDictionary:expression];
            }
            
            NSDictionary *text = dictionary[@"text"];
            if ([text isKindOfClass:[NSDictionary class]]) {
                self.text = [[UMCTextSurvey alloc] initWithDictionary:text];
            }
            
            NSDictionary *star = dictionary[@"star"];
            if ([star isKindOfClass:[NSDictionary class]]) {
                self.star = [[UMCStarSurvey alloc] initWithDictionary:star];
            }
            
        } @catch (NSException *exception) {
            NSLog(@"%@",exception);
        } @finally {
        }
    }
    return self;
}

- (NSString *)stringWithOptionType {
    
    switch (self.optionType) {
        case UMCSurveyOptionTypeStar:
            return @"star";
            break;
        case UMCSurveyOptionTypeText:
            return @"text";
            break;
        case UMCSurveyOptionTypeExpression:
            return @"expression";
            break;
            
        default:
            break;
    }
}

@end
