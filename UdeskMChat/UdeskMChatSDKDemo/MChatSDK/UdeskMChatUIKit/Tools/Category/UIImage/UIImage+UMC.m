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

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udrefreshButton.png")];
}

+ (UIImage *)umcDefaultVoiceImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoice.png")];
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

+ (UIImage *)umcDefaultLocationImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udLocation.png")];
}

+ (UIImage *)umcDefaultLocationHighlightedImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udLocationHigh.png")];
}

+ (UIImage *)umcDefaultRecordVoiceImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udRecordVoice.png")];
}

+ (UIImage *)umcDefaultRecordVoiceHighImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udRecordVoiceHigh.png")];
}

+ (UIImage *)umcDefaultDeleteRecordVoiceImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udDeleteRecordVoice.png")];
}

+ (UIImage *)umcDefaultDeleteRecordVoiceHighImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udDeleteRecordVoiceHigh.png")];
}

+ (UIImage *)umcDefaultTransferImage {
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udTransfer.png")];
}

+ (UIImage *)umcDefaultLoadingImage {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udImageLoading.png")];
}

+ (UIImage *)umcDefaultResetButtonImage {

    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udrefreshButton.png")];
}

+ (UIImage *)umcDefaultVoiceTooShortImageEN {
	return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udVoiceTooshortEn.png")];
}

+ (UIImage *)umcDefaultLocationPinImage {
    
    return [UIImage imageWithContentsOfFile:UMCBundlePath(@"udMapLocation.png")];
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


@end
