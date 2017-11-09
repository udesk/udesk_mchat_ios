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
 *  地理位置
 *
 *  @return 地理位置
 */
+ (UIImage *)umcDefaultLocationImage;
/**
 *  地理位置高亮
 *
 *  @return 地理位置高亮
 */
+ (UIImage *)umcDefaultLocationHighlightedImage;
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
 *  录制语音显示图片
 *
 *  @return 录制语音显示图片
 */
+ (UIImage *)umcDefaultRecordVoiceImage;
/**
 *  录制语音高亮显示图片
 *
 *  @return 录制语音高亮显示图片
 */
+ (UIImage *)umcDefaultRecordVoiceHighImage;
/**
 *  删除录制语音显示图片
 *
 *  @return 录制语音高亮显示图片
 */
+ (UIImage *)umcDefaultDeleteRecordVoiceImage;
/**
 *  删除录制语音高亮显示图片
 *
 *  @return 录制语音高亮显示图片
 */
+ (UIImage *)umcDefaultDeleteRecordVoiceHighImage;

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

//地图大头针
+ (UIImage *)umcDefaultLocationPinImage;

//打勾
+ (UIImage *)umcDefaultMarkImage;

//im多商户头像
+ (UIImage *)umcIMMerchantAvatarImage;

//最近联系人多商户头像
+ (UIImage *)umcContactsMerchantAvatarImage;

@end
