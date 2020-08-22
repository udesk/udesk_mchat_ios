//
//  UMCFileCell.m
//  UdeskMChat
//
//  Created by xuchen on 2020/7/2.
//  Copyright © 2020 Udesk. All rights reserved.
//

#import "UMCFileCell.h"
#import "UMCFileMessage.h"
#import "UMCHelper.h"
#import "UIView+UMC.h"
#import <SafariServices/SafariServices.h>

@interface UMCFileCell()

@property (nonatomic, strong) UIImageView *fileIconView;
@property (nonatomic, strong) UILabel     *fileNameLabel;
@property (nonatomic, strong) UILabel     *fileSizeLabel;

@property (nonatomic, strong) UIProgressView *progressView;

@end

@implementation UMCFileCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self setupFileView];
    }
    return self;
}

- (void)setupFileView {
    
    _fileIconView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self.bubbleImageView addSubview:_fileIconView];
    
    _fileNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _fileNameLabel.numberOfLines = 2;
    _fileNameLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    _fileNameLabel.font = [UIFont systemFontOfSize:13];
    [self.bubbleImageView addSubview:_fileNameLabel];
    
    _fileSizeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _fileSizeLabel.font = [UIFont systemFontOfSize:11];
    [self.bubbleImageView addSubview:_fileSizeLabel];
    
    //进度条
    _progressView = [[UIProgressView alloc] initWithFrame:CGRectZero];
    _progressView.progress = 0.0f;
    _progressView.trackTintColor = [UIColor colorWithRed:0.922f  green:0.929f  blue:0.941f alpha:0.4f];
    _progressView.tintColor = [UIColor whiteColor];
    [self.bubbleImageView addSubview:_progressView];
    
    UITapGestureRecognizer *tapPressBubbleGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapVoicePlay:)];
    tapPressBubbleGesture.cancelsTouchesInView = false;
    [self.bubbleImageView addGestureRecognizer:tapPressBubbleGesture];
}

- (void)updataProgress:(CGFloat)progress {
    [self.progressView setProgress:progress animated:YES];
}

- (void)tapVoicePlay:(UITapGestureRecognizer *)tap {
    
    NSString *url = [[self.baseMessage.message.content stringByRemovingPercentEncoding] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (@available(iOS 9.0, *)) {
        SFSafariViewController *sfVC = [[SFSafariViewController alloc] initWithURL:[NSURL URLWithString:url]];
        [[UMCHelper currentViewController] presentViewController:sfVC animated:YES completion:nil];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {
    [super updateCellWithMessage:baseMessage];
    
    UMCFileMessage *fileMessage = (UMCFileMessage *)baseMessage;
    if (!fileMessage || ![fileMessage isKindOfClass:[UMCFileMessage class]]) return;
    
    self.fileIconView.image = fileMessage.fileIcon;
    self.fileIconView.frame = fileMessage.iconFrame;
    
    self.fileNameLabel.text = fileMessage.message.extras.filename;
    self.fileNameLabel.frame = fileMessage.nameFrame;
    self.fileNameLabel.textColor = fileMessage.message.direction == UMCMessageDirectionIn?[UIColor whiteColor]:[UIColor blackColor];
    
    self.fileSizeLabel.text = fileMessage.message.extras.filesize;
    self.fileSizeLabel.frame = fileMessage.sizeFrame;
    self.fileSizeLabel.textColor = fileMessage.message.direction == UMCMessageDirectionIn?[UIColor whiteColor]:[UIColor blackColor];
    
    self.progressView.frame = fileMessage.proressFrame;
    self.progressView.progress = 0.0f;
    self.progressView.hidden = baseMessage.message.messageStatus == UMCMessageStatusSending?NO:YES;
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
