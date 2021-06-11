//
//  UdeskOneScrollView.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kUMCPhotoScreenWidth  [[UIScreen mainScreen] bounds].size.width
#define kUMCPhotoScreenHeight [[UIScreen mainScreen] bounds].size.height

@protocol UDMOneScrollViewDelegate <NSObject>

- (void)goBack;

@optional

@end
@interface UMCOneScrollView : UIScrollView

//代理
@property(nonatomic,weak)id<UDMOneScrollViewDelegate> mydelegate;

//本地加载图
- (void)setLocalImage:(UIImageView *)imageView withMessageURL:(NSString *)url;

//回复放大缩小前的原状
- (void)reloadFrame;

@end
