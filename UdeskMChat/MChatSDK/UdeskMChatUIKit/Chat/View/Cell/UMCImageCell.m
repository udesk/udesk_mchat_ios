//
//  UMCImageCell.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCImageCell.h"
#import "FLAnimatedImageView.h"
#import "UdeskPhotoManeger.h"
#import "UMCImageMessage.h"
#import "UMCHelper.h"
#import "FLAnimatedImageView+WebCache.h"

@interface UMCImageCell()

@property (nonatomic, strong) FLAnimatedImageView *chatImageView;

@end

@implementation UMCImageCell

- (FLAnimatedImageView *)chatImageView {
    
    if (!_chatImageView) {
        _chatImageView = [FLAnimatedImageView new];
        _chatImageView.userInteractionEnabled = YES;
        _chatImageView.layer.cornerRadius = 5;
        _chatImageView.layer.masksToBounds  = YES;
        _chatImageView.contentMode = UIViewContentModeScaleAspectFill;
        [self.bubbleImageView addSubview:_chatImageView];
        //添加图片点击手势
        UITapGestureRecognizer *tapContentImage = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapContentImageViewAction:)];
        [_chatImageView addGestureRecognizer:tapContentImage];
    }
    return _chatImageView;
}

//点击图片
- (void)tapContentImageViewAction:(UIGestureRecognizer *)tap {
    
    [self.contentView endEditing:YES];
    
    UdeskPhotoManeger *photoManeger = [UdeskPhotoManeger maneger];
    NSString *url = self.baseMessage.message.content?self.baseMessage.message.content:self.baseMessage.message.UUID;
    
    [photoManeger showLocalPhoto:self.chatImageView withMessageURL:url];
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    
    [super updateCellWithMessage:baseMessage];
    
    UMCImageMessage *imageMessage = (UMCImageMessage *)baseMessage;
    if (!imageMessage || ![imageMessage isKindOfClass:[UMCImageMessage class]]) return;
    
    NSString *imageUrl = imageMessage.message.content;
    if ([UMCHelper isBlankString:imageUrl]) {
        imageUrl = imageMessage.message.UUID;
    }
    
    [[SDWebImageManager sharedManager].imageCache queryImageForKey:imageMessage.message.UUID options:SDWebImageRetryFailed context:nil completion:^(UIImage * _Nullable image, NSData * _Nullable data, SDImageCacheType cacheType) {
        
        if (image) {
            self.chatImageView.image = image;
        }
        else {
            [self.chatImageView sd_setImageWithURL:[NSURL URLWithString:[imageUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        }
    }];
    
    self.chatImageView.frame = imageMessage.imageFrame;
    
    //设置图片全气泡展示
    UIImageView *ImageView = [[UIImageView alloc] init];
    [ImageView setFrame:self.chatImageView.frame];
    [ImageView setImage:self.bubbleImageView.image];
    
    CALayer *layer              = ImageView.layer;
    layer.frame                 = (CGRect){{0,0},ImageView.layer.frame.size};
    self.chatImageView.layer.mask = layer;
    [self.chatImageView setNeedsDisplay];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
