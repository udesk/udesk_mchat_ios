//
//  UMCUIMacro.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#ifndef UMCUIMacro_h
#define UMCUIMacro_h

//语音缓存地址
#define UMCVoiceCache @"UMCVoiceCache"

#define kUMCDateFormat @"yyyy-MM-dd'T'HH:mm:ss.SSSZ"
#define kUMCShowDateFormat @"yyyy-MM-dd HH:mm:ss"

// block self

#ifndef    udWeakify
#if __has_feature(objc_arc)

#define udWeakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __weak __typeof__(x) __weak_##x##__ = x; \
_Pragma("clang diagnostic pop")

#else

#define udWeakify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
autoreleasepool{} __block __typeof__(x) __block_##x##__ = x; \
_Pragma("clang diagnostic pop")

#endif
#endif

#ifndef    udStrongify
#if __has_feature(objc_arc)

#define udStrongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __weak_##x##__; \
_Pragma("clang diagnostic pop")

#else

#define udStrongify( x ) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
try{} @finally{} __typeof__(x) x = __block_##x##__; \
_Pragma("clang diagnostic pop")

#endif
#endif

// Size
#define kUMCScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kUMCScreenHeight [[UIScreen mainScreen] bounds].size.height

// 颜色(RGB)
#define kUMCRGBCOLOR(r, g, b)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define kUMCRGBACOLOR(r, g, b, a)   [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

// 当前版本
#define kUMCSystemVersion          ([[[UIDevice currentDevice] systemVersion] floatValue])

// 是否iPad
#define kUMCIsPad                   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//刘海系列
#define kUMCIPhoneXSeries ([UIScreen instancesRespondToSelector:@selector(currentMode)] ?\
(\
CGSizeEqualToSize(CGSizeMake(375, 812),[UIScreen mainScreen].bounds.size)\
||\
CGSizeEqualToSize(CGSizeMake(414, 896),[UIScreen mainScreen].bounds.size)\
)\
:\
NO)

// View 圆角和加边框
#define kUMCViewBorderRadius(View, Radius, Width, Color)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES];\
[View.layer setBorderWidth:(Width)];\
[View.layer setBorderColor:[Color CGColor]]

// View 圆角
#define kUMCViewRadius(View, Radius)\
\
[View.layer setCornerRadius:(Radius)];\
[View.layer setMasksToBounds:YES]

#endif /* UMCUIMacro_h */
