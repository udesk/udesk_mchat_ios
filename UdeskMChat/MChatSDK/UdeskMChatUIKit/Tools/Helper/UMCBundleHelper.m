//
//  UMCBundleHelper.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBundleHelper.h"
#import "UMCLanguageTool.h"

@implementation UMCBundleHelper

NSString *UMCBundlePath( NSString * filename)
{
    
    NSBundle *libBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[UMCLanguageTool class]] pathForResource:@"UdeskMChatBundle" ofType:@"bundle"]];
    
    if ( libBundle && filename ){
        
        NSString *s = [[libBundle resourcePath] stringByAppendingPathComponent : filename];
        
        return s;
    }
    
    return nil ;
}

NSString *UMCLocalizedString( NSString * key) {
    
    return [[UMCLanguageTool sharedInstance] getStringForKey:key withTable:@"UdeskLocalizable"];
}

@end
