//
//  UMCVideoCell.h
//  UdeskSDK
//
//  Created by xuchen on 2017/5/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCBaseCell.h"

@interface UMCVideoCell : UMCBaseCell

@property (nonatomic, strong) UIButton *playButton;
@property (nonatomic, strong) UILabel  *uploadProgressLabel;

- (void)videoUploadSuccess;
- (void)videoUploading;

@end
