//
//  UMCLanguageTool.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/5.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCLanguageTool.h"
#import "UMCHelper.h"
#import <UdeskMChatSDK/UdeskMChatSDK.h>

static UMCLanguageTool *sharedModel;

@interface UMCLanguageTool()

//默认
@property (nonatomic,strong) NSBundle *udeskPackageBundle;

@end

@implementation UMCLanguageTool

+ (instancetype)sharedInstance{
    if (!sharedModel){
        sharedModel = [[UMCLanguageTool alloc]init];
    }
    
    return sharedModel;
}

- (instancetype)init{
    self = [super init];
    if (self){
        [self initLanguage];
    }
    
    return self;
}

- (NSString *)getProjName:(NSString *)language{
    if ([language.lowercaseString isEqualToString:@"zh-cn"]) {
        return @"zh-Hans";
    }
    else if([language isEqualToString:@"en-us"]){
        return @"en";
    }
    return language;
}

- (NSBundle *)getLanguageBundle{
    //先去用户设置的bundle里面找
    NSBundle *pacageBundle = [UMCLanguage sharedInstance].customBundle;
    NSString *language = [UMCLanguage sharedInstance].language;
    if ([UMCHelper isBlankString:language]) {
        language = @"zh-CN";
    }
    if (pacageBundle) {
        NSString *path = [pacageBundle pathForResource:language ofType:@"lproj"];
        if (path.length > 0) {
            //用户的bundle里面有这个语言包
            return [NSBundle bundleWithPath:path];
        }
    }
    if (self.udeskPackageBundle) {
        NSString *path = [self.udeskPackageBundle pathForResource:[self getProjName:language] ofType:@"lproj"];
        if (path.length > 0) {
            return [NSBundle bundleWithPath:path];
        }
    }
    return nil;
}


- (void)initLanguage{
    
    NSString *path = [[NSBundle bundleForClass:[UMCLanguageTool class]] pathForResource:@"UdeskMChatBundle" ofType:@"bundle"];
    self.udeskPackageBundle = [NSBundle bundleWithPath:path];
}


- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table{
    NSBundle  *bundle = [self getLanguageBundle];
    if (bundle) {
        return NSLocalizedStringFromTableInBundle(key, table, bundle, @"");
    }
    return NSLocalizedStringFromTable(key, table, @"");
}

@end
