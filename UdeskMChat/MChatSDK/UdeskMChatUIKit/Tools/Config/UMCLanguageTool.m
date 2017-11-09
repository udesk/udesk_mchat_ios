//
//  UMCLanguageTool.m
//  UdeskSDK
//
//  Created by Udesk on 16/9/5.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UMCLanguageTool.h"
#import "UMCHelper.h"

static UMCLanguageTool *sharedModel;

@interface UMCLanguageTool()

@property (nonatomic,strong) NSBundle *bundle;
@property (nonatomic,copy  ) NSString *language;

@end

@implementation UMCLanguageTool

+ (id)sharedInstance
{
    if (!sharedModel)
    {
        sharedModel = [[UMCLanguageTool alloc]init];
    }
    
    return sharedModel;
}

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        [self initLanguage];
    }
    
    return self;
}

- (void)initLanguage
{
    @try {
        
        NSString *tmp = [[NSUserDefaults standardUserDefaults] objectForKey:LANGUAGE_SET];
        
        //默认是中文
        if ([UMCHelper isBlankString:tmp])
        {
            tmp = @"zh-Hans";
        }
        
        self.language = tmp;
        
        NSString *path = [[NSBundle bundleForClass:[UMCLanguageTool class]] pathForResource:@"UdeskMChatBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath:path];
        
        path = [bundle pathForResource:self.language ofType:@"lproj"];
        
        self.bundle = [NSBundle bundleWithPath:path];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

- (NSString *)getStringForKey:(NSString *)key withTable:(NSString *)table
{
    if (self.bundle)
    {
        return NSLocalizedStringFromTableInBundle(key, table, self.bundle, @"");
    }
    
    return NSLocalizedStringFromTable(key, table, @"");
}

- (void)setNewLanguage:(UMCLanguageType)language
{
    @try {
        
        NSString *languageStr = @"zh-Hans";
        if (language == UMCLanguageTypeEN) {
            languageStr = @"en";
        }
        
        NSString *path = [[NSBundle bundleForClass:[UMCLanguageTool class]] pathForResource:@"UdeskMChatBundle" ofType:@"bundle"];
        NSBundle *bundle = [NSBundle bundleWithPath: path];
        path = [bundle pathForResource:languageStr ofType:@"lproj"];
        self.bundle = [NSBundle bundleWithPath:path];
        
        self.language = languageStr;
        
        [[NSUserDefaults standardUserDefaults]setObject:languageStr forKey:LANGUAGE_SET];
        [[NSUserDefaults standardUserDefaults]synchronize];
    } @catch (NSException *exception) {
        NSLog(@"%@",exception);
    } @finally {
    }
}

@end
