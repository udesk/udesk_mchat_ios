//
//  UMCProductView.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/11/21.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>
@class UMCProduct;

/** 咨询对象height */
static CGFloat const kUDProductHeight = 70;

@interface UMCProductView : UIView

@property (nonatomic, strong) UMCProduct   *productModel;
@property (nonatomic, strong) UIView       *productBackGroundView;
@property (nonatomic, strong) UIImageView  *productImageView;
@property (nonatomic, strong) UILabel      *productTitleLabel;
@property (nonatomic, strong) UILabel      *productDetailLabel;

@end
