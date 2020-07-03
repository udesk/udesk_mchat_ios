//
//  UMCImagePicker.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/19.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UMCImagePicker : NSObject<UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@property (nonatomic, copy) void(^FinishNormalImageBlock)(UIImage *image);
@property (nonatomic, copy) void(^FinishGIFImageBlock)(NSData *GIFData);
@property (nonatomic, copy) void(^FinishVideoBlock)(NSString *filePath,NSString *fileName);

- (void)showWithSourceType:(UIImagePickerControllerSourceType)sourceType viewController:(UIViewController *)viewController;

@end
