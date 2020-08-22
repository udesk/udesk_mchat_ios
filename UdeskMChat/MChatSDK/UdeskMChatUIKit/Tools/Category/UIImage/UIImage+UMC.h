//
//  UIImage+UdeskSDK.h
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (UMC)

/**
 *  发送消息气泡图片
 *
 *  @return 气泡图片
 */
+ (UIImage *)umcBubbleSendImage;
/**
 *  接收消息气泡图片
 *
 *  @return 气泡图片
 */
+ (UIImage *)umcBubbleReceiveImage;
/**
 *  删除图片
 *
 *  @return 删除图片
 */
+ (UIImage *)umcDefaultDeleteImage;
/**
 *  删除高亮图片
 *
 *  @return 删除高亮图片
 */
+ (UIImage *)umcDefaultDeleteHighlightedImage;
/**
 *  重发图片
 *
 *  @return 重发图片
 */
+ (UIImage *)umcDefaultRefreshImage;
/**
 *  语音图片
 *
 *  @return 语音图片
 */
+ (UIImage *)umcDefaultVoiceImage;
/**
 *  语音高亮图片
 *
 *  @return 语音高亮图片
 */
+ (UIImage *)umcDefaultVoiceHighlightedImage;
/**
 *  图片选择图片
 *
 *  @return 图片选择图片
 */
+ (UIImage *)umcDefaultPhotoImage;
/**
 *  图片选择高亮图片
 *
 *  @return 图片选择图片
 */
+ (UIImage *)umcDefaultPhotoHighlightedImage;
/**
 *  表情图片
 *
 *  @return 表情图片
 */
+ (UIImage *)umcDefaultSmileImage;
/**
 *  表情高亮图片
 *
 *  @return 表情高亮图片
 */
+ (UIImage *)umcDefaultSmileHighlightedImage;
/**
 *  评价图片
 *
 *  @return 评价图片
 */
+ (UIImage *)umcDefaultSurveyImage;
/**
 *  评价高亮图片
 *
 *  @return 评价高亮图片
 */
+ (UIImage *)umcDefaultSurveyHighlightedImage;
/**
 *  用户头像图片
 *
 *  @return 用户头像图片
 */
+ (UIImage *)umcDefaultCustomerImage;
/**
 *  客服头像图片
 *
 *  @return 客服头像图片
 */
+ (UIImage *)umcDefaultAgentImage;
/**
 *  提示语音过短图片(中文)
 *
 *  @return 短
 */
+ (UIImage *)umcDefaultVoiceTooShortImageCN;

/**
 *  提示语音过短图片(英文)
 *
 *  @return 短
 */
+ (UIImage *)umcDefaultVoiceTooShortImageEN;

/**
 *  导航栏左侧返回图片
 *
 *  @return 返回图片
 */
+ (UIImage *)umcDefaultBackImage;

/**
 *  导航栏左侧返回图片
 *
 *  @return 返回图片
 */
+ (UIImage *)umcDefaultWhiteBackImage;

/**
 *  客服在线绿点
 *
 *  @return 返回图片
 */
+ (UIImage *)umcDefaultAgentOnlineImage;
/**
 *  客服离线灰点
 *
 *  @return 返回图片
 */
+ (UIImage *)umcDefaultAgentOfflineImage;
/**
 *  客服繁忙红点
 *
 *  @return 返回图片
 */
+ (UIImage *)umcDefaultAgentBusyImage;

/**
 *  压缩图片
 *
 *  @param image 要压缩的图片
 *
 *  @return 已经压缩的图片
 */
+ (UIImage *)umcCompressImageWith:(UIImage *)image;
/**
 *  相机图片
 *
 *  @return 相机图片
 */
+ (UIImage *)umcDefaultCameraImage;
/**
 *  相机高亮图片
 *
 *  @return 相机高亮图片
 */
+ (UIImage *)umcDefaultCameraHighlightedImage;
/**
 *  相册图片
 *
 *  @return 相机图片
 */
+ (UIImage *)umcDefaultAlbumImage;
/**
 *  相册高亮图片
 *
 *  @return 相机高亮图片
 */
+ (UIImage *)umcDefaultAlbumHighlightedImage;

/**
 *  转人工
 *
 *  @return 转人工
 */
+ (UIImage *)umcDefaultTransferImage;
/**
 *  默认图片
 *
 *  @return 图片
 */
+ (UIImage *)umcDefaultLoadingImage;

/**
 默认重发图片

 @return 图片
 */
+ (UIImage *)umcDefaultResetButtonImage;
/**
 *  修改图片颜色
 *
 *  @param toColor 颜色
 *
 *  @return 图片
 */
- (UIImage *)umcConvertImageColor:(UIColor *)toColor;

//打勾
+ (UIImage *)umcDefaultMarkImage;

//im多商户头像
+ (UIImage *)umcIMMerchantAvatarImage;

//最近联系人多商户头像
+ (UIImage *)umcContactsMerchantAvatarImage;

/** 满意度评价关闭按钮 */
+ (UIImage *)umcDefaultSurveyCloseImage;

/** 满意度评价文本模式未选择 */
+ (UIImage *)umcDefaultSurveyTextNotSelectImage;

/** 满意度评价文本模式选择 */
+ (UIImage *)umcDefaultSurveyTextSelectedImage;

/** 满意度评价表情 满意 */
+ (UIImage *)umcDefaultSurveyExpressionSatisfiedImage;

/** 满意度评价表情 一般 */
+ (UIImage *)umcDefaultSurveyExpressionGeneralImage;

/** 满意度评价表情 不满意 */
+ (UIImage *)umcDefaultSurveyExpressionUnsatisfactoryImage;

/** 满意度评价表情 空星 */
+ (UIImage *)umcDefaultSurveyStarEmptyImage;

/** 满意度评价表情 实星 */
+ (UIImage *)umcDefaultSurveyStarFilledImage;

+ (UIImage *)umcDefaultMoreImage;

+ (UIImage *)umcDefaultKeyboardImage;

//更多-相册
+ (UIImage *)umcDefaultChatBarMorePhotoImage;

//更多-相机
+ (UIImage *)umcDefaultChatBarMoreCameraImage;

//更多-评价
+ (UIImage *)umcDefaultChatBarMoreSurveyImage;

//更多-小视频
+ (UIImage *)umcDefaultChatBarMoreSmallVideoImage;

/** 发送语音时话筒图片 */
+ (UIImage *)umcDefaultVoiceSpeakImage;

//取消发送
+ (UIImage *)umcDefaultVoiceRevokeImage;

/** 语音太短 */
+ (UIImage *)umcDefaultVoiceTooShortImage;

//小视频返回按钮
+ (UIImage *)umcDefaultSmallVideoBack;

//小视频切换摄像头按钮
+ (UIImage *)umcDefaultSmallVideoCameraSwitch;

//小视频重拍
+ (UIImage *)umcDefaultSmallVideoRetake;

//小视频完成
+ (UIImage *)umcDefaultSmallVideoDone;

//小视频下载
+ (UIImage *)umcDefaultVideoDownload;

//小视频下载
+ (UIImage *)umcDefaultVideoPlay;

//文件
+ (UIImage *)umcDefaultChatBarMoreFile;
+ (UIImage *)umcDefaultFileSendOther;
+ (UIImage *)umcDefaultFileReceiveOther;
+ (UIImage *)umcDefaultFileSendPDF;
+ (UIImage *)umcDefaultFileReceivePDF;
+ (UIImage *)umcDefaultFileSendPPT;
+ (UIImage *)umcDefaultFileReceivePPT;
+ (UIImage *)umcDefaultFileSendTxt;
+ (UIImage *)umcDefaultFileReceiveTxt;
+ (UIImage *)umcDefaultFileSendWord;
+ (UIImage *)umcDefaultFileReceiveWord;
+ (UIImage *)umcDefaultFileSendExcel;
+ (UIImage *)umcDefaultFileReceiveExcel;

@end
