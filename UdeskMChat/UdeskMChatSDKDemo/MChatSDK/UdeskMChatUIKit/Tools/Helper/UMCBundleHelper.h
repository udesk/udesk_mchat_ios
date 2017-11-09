//
//  UMCBundleHelper.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UMCBundleHelper : NSObject

#define UDBUNDLE_NAME @ "UdeskMChatBundle.bundle"

#define UDBUNDLE_PATH [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent: UDBUNDLE_NAME]

#define UDBUNDLE [NSBundle bundleWithPath: UDBUNDLE_PATH]

NSString *UMCBundlePath(NSString *filename);

NSString *UMCLocalizedString(NSString *key);

@end
