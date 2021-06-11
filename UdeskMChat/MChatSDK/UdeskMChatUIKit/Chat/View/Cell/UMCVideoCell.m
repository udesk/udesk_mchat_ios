//
//  UMCVideoCell.m
//  UdeskSDK
//
//  Created by xuchen on 2017/5/15.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCVideoCell.h"
#import "UMCVideoMessage.h"
#import "UMCHelper.h"
#import "UMCBundleHelper.h"
#import "UMCVideoCache.h"
#import "UMC_WHC_HttpManager.h"
#import "UMC_WHC_DownloadObject.h"
#import "UMCToast.h"
#import "UMCUIMacro.h"
#import "UIImage+UMC.h"
#import "UIView+UMC.h"
#import <AVKit/AVKit.h>

@interface UMCVideoCell ()

@property (nonatomic, strong) UIImageView *previewImageView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UILabel  *videoDuration;

@end

@implementation UMCVideoCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        [self initVideoFileView];
    }
    return self;
}

- (void)initVideoFileView {

    _previewImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _previewImageView.userInteractionEnabled = YES;
    _previewImageView.layer.cornerRadius = 5;
    _previewImageView.layer.masksToBounds  = YES;
    _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_previewImageView];
    
    _downloadButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_downloadButton setImage:[UIImage umcDefaultVideoDownload] forState:UIControlStateNormal];
    [_downloadButton addTarget:self action:@selector(downloadAction) forControlEvents:UIControlEventTouchUpInside];
    [_previewImageView addSubview:_downloadButton];
    
    _playButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_playButton setImage:[UIImage umcDefaultVideoPlay] forState:UIControlStateNormal];
    [_playButton addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    [_previewImageView addSubview:_playButton];
    
    _videoDuration = [[UILabel alloc] initWithFrame:CGRectZero];
    _videoDuration.textColor = [UIColor whiteColor];
    _videoDuration.font = [UIFont systemFontOfSize:12];
    _videoDuration.textAlignment = NSTextAlignmentCenter;
    [_previewImageView addSubview:_videoDuration];
    
    _uploadProgressLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _uploadProgressLabel.textColor = [UIColor whiteColor];
    _uploadProgressLabel.layer.masksToBounds = YES;
    _uploadProgressLabel.layer.cornerRadius = 24;
    _uploadProgressLabel.layer.borderWidth = 1;
    _uploadProgressLabel.font = [UIFont systemFontOfSize:12];
    _uploadProgressLabel.textAlignment = NSTextAlignmentCenter;
    _uploadProgressLabel.layer.borderColor = [UIColor whiteColor].CGColor;
    [_previewImageView addSubview:_uploadProgressLabel];
}

- (void)downloadAction {
    
    if (![[UMCHelper internetStatus] isEqualToString:@"wifi"]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:UMCLocalizedString(@"udesk_wwan_tips") message:UMCLocalizedString(@"udesk_video_send_tips") preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:UMCLocalizedString(@"udesk_sure") style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
            [self readyDownloadVideo];
        }]];
        [[UMCHelper currentViewController] presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    [self readyDownloadVideo];
}

- (void)playAction {
    
    UMCVideoMessage *videoMessage = (UMCVideoMessage *)self.baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UMCVideoMessage class]]) return;
    
    [self openVideoWithMessageId:videoMessage.message.UUID contentURL:videoMessage.message.content];
}

- (void)readyDownloadVideo {

    UMCVideoMessage *videoMessage = (UMCVideoMessage *)self.baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UMCVideoMessage class]]) return;
    
    self.uploadProgressLabel.hidden = NO;
    self.downloadButton.hidden = YES;
    
    @udWeakify(self);
    [[UMC_WHC_HttpManager shared] download:videoMessage.message.content
                                    savePath:[[UMCVideoCache sharedManager] filePath]
                                saveFileName:videoMessage.message.UUID
                                    response:^(UMC_WHC_BaseOperation *operation, NSError *error, BOOL isOK) {
                                  
                                  @try {
                                      
                                      @udStrongify(self);
                                      if (isOK) {
                                          UMC_WHC_DownloadOperation * downloadOperation = (UMC_WHC_DownloadOperation*)operation;
                                          UMC_WHC_DownloadObject * downloadObject = [UMC_WHC_DownloadObject readDiskCache:operation.strUrl];
                                          if (downloadObject == nil) {
                                              downloadObject = [UMC_WHC_DownloadObject new];
                                          }
                                          downloadObject.fileName = downloadOperation.saveFileName;
                                          downloadObject.downloadPath = downloadOperation.strUrl;
                                          downloadObject.downloadState = UMC_WHCDownloading;
                                          downloadObject.currentDownloadLenght = downloadOperation.recvDataLenght;
                                          downloadObject.totalLenght = downloadOperation.fileTotalLenght;
                                          
                                          [downloadObject writeDiskCache];
                                      }else {
                                          [self errorHandle:(UMC_WHC_DownloadOperation *)operation error:error];
                                      }
                                  } @catch (NSException *exception) {
                                      NSLog(@"%@",exception);
                                  } @finally {
                                  }
                              } process:^(UMC_WHC_BaseOperation *operation, uint64_t recvLength, uint64_t totalLength, NSString *speed) {
                                  
                                  dispatch_async(dispatch_get_main_queue(), ^{
                                      @udStrongify(self);
                                      self.uploadProgressLabel.hidden = NO;
                                      self.playButton.hidden = YES;
                                      double progress = (double)recvLength / ((double)totalLength == 0 ? 1 : totalLength);
                                      self.uploadProgressLabel.text = [NSString stringWithFormat:@"%.f%%",progress*100];
                                  });
                                  
                              } didFinished:^(UMC_WHC_BaseOperation *operation, NSData *data, NSError *error, BOOL isSuccess) {
                                  
                                  @udStrongify(self);
                                  if (isSuccess) {
                                      NSLog(@"UdeskSDK：视频下载成功");
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          self.uploadProgressLabel.hidden = YES;
                                          self.playButton.hidden = NO;
                                      });
                                      [self saveDownloadStateOperation:(UMC_WHC_DownloadOperation *)operation];
                                  }
                                  else {
                                      [self errorHandle:(UMC_WHC_DownloadOperation *)operation error:error];
                                  }
                              }];
}

- (void)errorHandle:(UMC_WHC_DownloadOperation *)operation error:(NSError *)error {
    NSString * errInfo = error.userInfo[NSLocalizedDescriptionKey];
    if (!errInfo || errInfo == (id)kCFNull) return ;
    if (![errInfo isKindOfClass:[NSString class]]) return ;
    
    if ([errInfo containsString:@"404"]) {
        [UMCToast showToast:UMCLocalizedString(@"udesk_file_not_exist") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
    else if([errInfo isEqualToString:@"下载失败"]){
        [UMCToast showToast:UMCLocalizedString(@"udesk_download_failed") duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
    else {
        [UMCToast showToast:errInfo duration:1.0f window:[UIApplication sharedApplication].keyWindow];
    }
    
    _uploadProgressLabel.hidden = YES;
    _downloadButton.hidden = NO;
    _playButton.hidden = YES;
    
    [[UMCVideoCache sharedManager] udRemoveObjectForKey:self.baseMessage.messageId];
    [self removeDownloadStateOperation:operation];
}

- (void)saveDownloadStateOperation:(UMC_WHC_DownloadOperation *)operation {
    UMC_WHC_DownloadObject * downloadObject = [UMC_WHC_DownloadObject readDiskCache:operation.saveFileName];
    if (downloadObject != nil) {
        downloadObject.currentDownloadLenght = operation.recvDataLenght;
        downloadObject.totalLenght = operation.fileTotalLenght;
        [downloadObject writeDiskCache];
    }
}

- (void)removeDownloadStateOperation:(UMC_WHC_DownloadOperation *)operation {
    UMC_WHC_DownloadObject * downloadObject = [UMC_WHC_DownloadObject readDiskCache:operation.saveFileName];
    if (downloadObject != nil) {
        [downloadObject removeFromDisk];
    }
}

- (void)openVideoWithMessageId:(NSString *)messageId contentURL:(NSString *)contentURL {
    
    NSURL *url = [NSURL URLWithString:@"https://www.udesk.cn"];
    if ([[UMCVideoCache sharedManager] containsObjectForKey:messageId]) {
        NSString *path = [[UMCVideoCache sharedManager] filePathForkey:messageId];
        url = [NSURL fileURLWithPath:path];
    }
    else {
        url = [NSURL URLWithString:[contentURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
     
    AVPlayerViewController *playerVC = [[AVPlayerViewController alloc] init];
    playerVC.player = [AVPlayer playerWithURL:url];
    playerVC.showsPlaybackControls = YES;
    playerVC.modalPresentationStyle = UIModalPresentationOverFullScreen;
    if (@available(iOS 11.0, *)) {
        playerVC.entersFullScreenWhenPlaybackBegins = YES;
    }
    //开启这个播放的时候支持（全屏）横竖屏哦
    if (@available(iOS 11.0, *)) {
        playerVC.exitsFullScreenWhenPlaybackEnds = YES;
    }
    
    [[UMCHelper currentViewController] presentViewController:playerVC animated:YES completion:^{
        if (playerVC.readyForDisplay) {
            [playerVC.player play];
        }
    }];
}

- (void)dealloc
{
    [[UMC_WHC_HttpManager shared] cancelAllDownloadTaskAndDelFile:YES];
}

- (void)updateCellWithMessage:(UMCBaseMessage *)baseMessage {

    [super updateCellWithMessage:baseMessage];
    
    UMCVideoMessage *videoMessage = (UMCVideoMessage *)baseMessage;
    if (!videoMessage || ![videoMessage isKindOfClass:[UMCVideoMessage class]]) return;
    
    self.bubbleImageView.hidden = YES;
    
    _previewImageView.image = videoMessage.previewImage;
    _previewImageView.frame = videoMessage.previewFrame;
    
    _playButton.frame = videoMessage.playFrame;
    _downloadButton.frame = videoMessage.downloadFrame;
    _videoDuration.frame = videoMessage.videoDurationFrame;
    _uploadProgressLabel.frame = videoMessage.uploadProgressFrame;
    
    _videoDuration.text = videoMessage.videoDuration;
    
    if (videoMessage.message.direction == UMCMessageDirectionIn) {
        _downloadButton.hidden = YES;
        if (videoMessage.message.messageStatus == UMCMessageStatusSending) {
            _uploadProgressLabel.hidden = NO;
            _playButton.hidden = YES;
        }
        else {
            _uploadProgressLabel.hidden = YES;
            _playButton.hidden = NO;
        }
        
        //检查是否有缓存
        if (![[UMCVideoCache sharedManager] containsObjectForKey:videoMessage.message.UUID]) {
            _downloadButton.hidden = NO;
            _playButton.hidden = YES;
        }
    }
    else {
        
        _uploadProgressLabel.hidden = YES;
        if ([[UMCVideoCache sharedManager] containsObjectForKey:videoMessage.message.UUID]) {
            _downloadButton.hidden = YES;
            _playButton.hidden = NO;
        }
        else {
            _downloadButton.hidden = NO;
            _playButton.hidden = YES;
        }
    }
}

- (void)videoUploadSuccess {
    
    self.uploadProgressLabel.hidden = YES;
    self.playButton.hidden = NO;
}

- (void)videoUploading {
    
    self.uploadProgressLabel.hidden = NO;
    self.playButton.hidden = YES;
}

@end
