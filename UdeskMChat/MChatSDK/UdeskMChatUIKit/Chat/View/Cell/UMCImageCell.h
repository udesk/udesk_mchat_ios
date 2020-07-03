//
//  UMCImageCell.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseCell.h"

@interface UMCImageCell : UMCBaseCell

@property (nonatomic, strong) UILabel *progressLabel;

- (void)uploadImageSuccess;
- (void)imageUploading;

@end
