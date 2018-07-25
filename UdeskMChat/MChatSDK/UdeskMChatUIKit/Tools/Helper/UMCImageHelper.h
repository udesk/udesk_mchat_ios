//
//  UMCImageHelper.h
//  UdeskMChatSDKDemo
//
//  Created by xuchen on 2018/7/25.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UMCImageHelper : NSObject

//修改图片转向
+ (UIImage *)fixOrientation:(UIImage *)image;
//压缩
+ (UIImage *)imageWithOriginalImage:(UIImage *)image;
//压缩图片 压缩质量
+ (NSData *)imageWithOriginalImage:(UIImage *)image quality:(CGFloat)quality;

@end
