//
//  UDPhotoView.h
//  UdeskSDK
//
//  Created by Udesk on 16/1/18.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UMCOneScrollView.h"

@interface UMCPhotoView : UIView<UDMOneScrollViewDelegate>

//获取数据
- (void)setPhotoData:(UIImageView *)photoImageView withMessageURL:(NSString *)url;

@end
