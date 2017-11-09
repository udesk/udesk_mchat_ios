//
//  UIView+UMC.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UMC)

@property (nullable, nonatomic, readonly) UIViewController *viewController;

@property (nonatomic) CGFloat umcLeft;        ///< Shortcut for frame.origin.x.
@property (nonatomic) CGFloat umcTop;         ///< Shortcut for frame.origin.y
@property (nonatomic) CGFloat umcRight;       ///< Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat umcBottom;      ///< Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat umcWidth;       ///< Shortcut for frame.size.width.
@property (nonatomic) CGFloat umcHeight;      ///< Shortcut for frame.size.height.
@property (nonatomic) CGFloat umcCenterX;     ///< Shortcut for center.x
@property (nonatomic) CGFloat umcCenterY;     ///< Shortcut for center.y
@property (nonatomic) CGPoint umcOrigin;      ///< Shortcut for frame.origin.
@property (nonatomic) CGSize  umcSize;        ///< Shortcut for frame.size.

@end
