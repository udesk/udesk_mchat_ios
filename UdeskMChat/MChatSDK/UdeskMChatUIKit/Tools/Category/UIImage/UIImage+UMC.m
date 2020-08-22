//
//  UIImage+UdeskSDK.m
//  UdeskSDK
//
//  Created by Udesk on 16/3/2.
//  Copyright © 2016年 Udesk. All rights reserved.
//

#import "UIImage+UMC.h"
#import "UMCBundleHelper.h"

@implementation UIImage (UMC)

+ (UIImage *)umcBubbleSendImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBubbleSendingSolid.png")];
}

+ (UIImage *)umcBubbleReceiveImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBubbleReceivingSolid.png")];
}

+ (UIImage *)umcDefaultDeleteImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"uddeleteMessageButton@2x.png")];
}

+ (UIImage *)umcDefaultDeleteHighlightedImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"uddeleteMessageButtonH@2x.png")];
}

+ (UIImage *)umcDefaultRefreshImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udRefreshButton.png")];
}

+ (UIImage *)umcDefaultVoiceImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatVoice.png")];
}

+ (UIImage *)umcDefaultVoiceHighlightedImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceHigh.png")];
}
+ (UIImage *)umcDefaultPhotoImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAlbum.png")];
}

+ (UIImage *)umcDefaultPhotoHighlightedImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAlbumHigh.png")];
}

+ (UIImage *)umcDefaultSmileImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSmileButton.png")];
}

+ (UIImage *)umcDefaultSmileHighlightedImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSmileButtonHigh.png")];
}

+ (UIImage *)umcDefaultCustomerImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udCustomerAvatar.png")];
}

+ (UIImage *)umcDefaultAgentImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAgentAvatar.png")];
}

+ (UIImage *)umcDefaultBackImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udblueBack.png")];
}

+ (UIImage *)umcDefaultWhiteBackImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udwhiteBack.png")];
}

+ (UIImage *)umcDefaultVoiceTooShortImageCN {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceTooshort.png")];
}

+ (UIImage *)umcCompressImageWith:(UIImage *)image
{
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    
    if (imageWidth < 400) {
        return image;
    }
    
    float width = 400;
    float height = image.size.height/(image.size.width/width);
    
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    
    // 从当前context中创建一个改变大小后的图片
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    
    return newImage;
    
}

//改变图片颜色
- (UIImage *)umcConvertImageColor:(UIColor *)toColor {
    if (self != nil) {
        CGRect rect = CGRectMake(0, 0, self.size.width, self.size.height);
        UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextClipToMask(context, rect, self.CGImage);
        CGContextSetFillColorWithColor(context, [toColor CGColor]);
        CGContextFillRect(context, rect);
        UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return img;
    } else {
        return nil;
    }
}

+ (UIImage *)umcDefaultAgentOnlineImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAgentStatusOnline.png")];
}

+ (UIImage *)umcDefaultAgentOfflineImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAgentStatusOffline.png")];
}

+ (UIImage *)umcDefaultAgentBusyImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAgentStatusBusy.png")];
}

+ (UIImage *)umcDefaultSurveyImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAgentSurvey.png")];
}

+ (UIImage *)umcDefaultSurveyHighlightedImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAgentSurveyHigh.png")];
}

+ (UIImage *)umcDefaultCameraImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udCamera.png")];
}

+ (UIImage *)umcDefaultCameraHighlightedImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udCameraHigh.png")];
}

+ (UIImage *)umcDefaultAlbumImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAlbum.png")];
}

+ (UIImage *)umcDefaultAlbumHighlightedImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udAlbumHigh.png")];
}

+ (UIImage *)umcDefaultTransferImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udTransfer.png")];
}

+ (UIImage *)umcDefaultLoadingImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udImageLoading.png")];
}

+ (UIImage *)umcDefaultResetButtonImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udRefreshButton.png")];
}

+ (UIImage *)umcDefaultVoiceTooShortImageEN {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceTooshortEn.png")];
}

+ (UIImage *)umcDefaultMarkImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udMark.png")];
}

//im多商户头像
+ (UIImage *)umcIMMerchantAvatarImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udMerchantIM.png")];
}

//最近联系人多商户头像
+ (UIImage *)umcContactsMerchantAvatarImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udMerchantContacts.png")];
}

/** 满意度评价关闭按钮 */
+ (UIImage *)umcDefaultSurveyCloseImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyClose.png")];
}

/** 满意度评价文本模式未选择 */
+ (UIImage *)umcDefaultSurveyTextNotSelectImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyTextNotSelect.png")];
}

/** 满意度评价文本模式选择 */
+ (UIImage *)umcDefaultSurveyTextSelectedImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyTextSelected.png")];
}

/** 满意度评价表情 满意 */
+ (UIImage *)umcDefaultSurveyExpressionSatisfiedImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyExpressionSatisfied.png")];
}

/** 满意度评价表情 一般 */
+ (UIImage *)umcDefaultSurveyExpressionGeneralImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyExpressionGeneral.png")];
}

/** 满意度评价表情 不满意 */
+ (UIImage *)umcDefaultSurveyExpressionUnsatisfactoryImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyExpressionUnsatisfactory.png")];
}

/** 满意度评价表情 空星 */
+ (UIImage *)umcDefaultSurveyStarEmptyImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyStarEmpty.png")];
}

/** 满意度评价表情 实星 */
+ (UIImage *)umcDefaultSurveyStarFilledImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSurveyStarFilled.png")];
}

+ (UIImage *)umcDefaultMoreImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatMore.png")];
}

+ (UIImage *)umcDefaultKeyboardImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatKeyboard.png")];
}

//更多-相册
+ (UIImage *)umcDefaultChatBarMorePhotoImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBarMorePhoto.png")];
}

//更多-相机
+ (UIImage *)umcDefaultChatBarMoreCameraImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBarMoreCamera.png")];
}

//更多-评价
+ (UIImage *)umcDefaultChatBarMoreSurveyImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBarMoreSurvey.png")];
}

//更多-小视频
+ (UIImage *)umcDefaultChatBarMoreSmallVideoImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBarMoreSmallVideo.png")];
}

/** 发送语音时话筒图片 */
+ (UIImage *)umcDefaultVoiceSpeakImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceSpeak.png")];
}

//取消发送
+ (UIImage *)umcDefaultVoiceRevokeImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceRevoke.png")];
}

/** 语音太短 */
+ (UIImage *)umcDefaultVoiceTooShortImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceTooshort.png")];
}

//小视频返回按钮
+ (UIImage *)umcDefaultSmallVideoBack {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udClose.png")];
}

//小视频切换摄像头按钮
+ (UIImage *)umcDefaultSmallVideoCameraSwitch {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udCameraSwitch.png")];
}

//小视频重拍
+ (UIImage *)umcDefaultSmallVideoRetake {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSmallVideoRetake.png")];
}

//小视频完成
+ (UIImage *)umcDefaultSmallVideoDone {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udSmallVideoRight.png")];
}

//小视频下载
+ (UIImage *)umcDefaultVideoDownload {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVideoDownload.png")];
}

//小视频下载
+ (UIImage *)umcDefaultVideoPlay {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVideoPlay.png")];
}

+ (UIImage *)umcDefaultChatBarMoreFile {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udChatBarMoreFile.png")];
}
+ (UIImage *)umcDefaultFileSendOther {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileSendOther.png")];
}
+ (UIImage *)umcDefaultFileReceiveOther {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileReceiveOther.png")];
}
+ (UIImage *)umcDefaultFileSendPDF {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileSendPDF.png")];
}
+ (UIImage *)umcDefaultFileReceivePDF {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileReceivePDF.png")];
}
+ (UIImage *)umcDefaultFileSendPPT {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileSendPPT.png")];
}
+ (UIImage *)umcDefaultFileReceivePPT {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileReceivePPT.png")];
}
+ (UIImage *)umcDefaultFileSendTxt {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileSendTxt.png")];
}
+ (UIImage *)umcDefaultFileReceiveTxt {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileReceiveTxt.png")];
}
+ (UIImage *)umcDefaultFileSendWord {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileSendWord.png")];
}
+ (UIImage *)umcDefaultFileReceiveWord {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileReceiveWord.png")];
}
+ (UIImage *)umcDefaultFileSendExcel {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileSendXLS.png")];
}
+ (UIImage *)umcDefaultFileReceiveExcel {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udFileReceiveXLS.png")];
}

@end
