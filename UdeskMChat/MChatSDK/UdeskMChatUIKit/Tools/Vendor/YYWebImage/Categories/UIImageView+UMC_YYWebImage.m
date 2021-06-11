//
//  UIImageView+YYWebImage.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIImageView+UMC_YYWebImage.h"
#import "UMC_YYWebImageOperation.h"
#import "UMC_YYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface UMC_UIImageView_YYWebImage : NSObject @end
@implementation UMC_UIImageView_YYWebImage @end

static int UMC_YYWebImageSetterKey;
static int UMC_YYWebImageHighlightedSetterKey;


@implementation UIImageView (UMC_YYWebImage)

#pragma mark - image

- (NSURL *)udesk_yy_imageURL {
    UMC_YYWebImageSetter *setter = objc_getAssociatedObject(self, &UMC_YYWebImageSetterKey);
    return setter.imageURL;
}

- (void)setUdesk_yy_imageURL:(NSURL *)imageURL {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:nil
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:kNilOptions
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL options:(UMC_YYWebImageOptions)options {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(UMC_YYWebImageOptions)options
                completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(UMC_YYWebImageOptions)options
                  progress:(UMC_YYWebImageProgressBlock)progress
                 transform:(UMC_YYWebImageTransformBlock)transform
                completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setImageWithURL:imageURL
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
               placeholder:(UIImage *)placeholder
                   options:(UMC_YYWebImageOptions)options
                   manager:(UMC_YYWebImageManager *)manager
                  progress:(UMC_YYWebImageProgressBlock)progress
                 transform:(UMC_YYWebImageTransformBlock)transform
                completion:(UMC_YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [UMC_YYWebImageManager sharedManager];
    
    UMC_YYWebImageSetter *setter = objc_getAssociatedObject(self, &UMC_YYWebImageSetterKey);
    if (!setter) {
        setter = [UMC_YYWebImageSetter new];
        objc_setAssociatedObject(self, &UMC_YYWebImageSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _udesk_yy_dispatch_sync_on_main_queue(^{
        if ((options & UMC_YYWebImageOptionSetImageWithFadeAnimation) &&
            !(options & UMC_YYWebImageOptionAvoidSetImage)) {
            if (!self.highlighted) {
                [self.layer removeAnimationForKey:UMC_YYWebImageFadeAnimationKey];
            }
        }
        
        if (!imageURL) {
            if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
                self.image = placeholder;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & UMC_YYWebImageOptionUseNSURLCache) &&
            !(options & UMC_YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:UMC_YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & UMC_YYWebImageOptionAvoidSetImage)) {
                self.image = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, UMC_YYWebImageFromMemoryCacheFast, UMC_YYWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
            self.image = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([UMC_YYWebImageSetter setterQueue], ^{
            UMC_YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            UMC_YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, UMC_YYWebImageFromType from, UMC_YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == UMC_YYWebImageStageFinished || stage == UMC_YYWebImageStageProgress) && image && !(options & UMC_YYWebImageOptionAvoidSetImage);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        BOOL showFade = ((options & UMC_YYWebImageOptionSetImageWithFadeAnimation) && !self.highlighted);
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == UMC_YYWebImageStageFinished ? UMC_YYWebImageFadeTime : UMC_YYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:UMC_YYWebImageFadeAnimationKey];
                        }
                        self.image = image;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, UMC_YYWebImageFromNone, UMC_YYWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)udesk_yy_cancelCurrentImageRequest {
    UMC_YYWebImageSetter *setter = objc_getAssociatedObject(self, &UMC_YYWebImageSetterKey);
    if (setter) [setter cancel];
}


#pragma mark - highlighted image

- (NSURL *)udesk_yy_highlightedImageURL {
    UMC_YYWebImageSetter *setter = objc_getAssociatedObject(self, &UMC_YYWebImageHighlightedSetterKey);
    return setter.imageURL;
}

- (void)setUdesk_yy_highlightedImageURL:(NSURL *)imageURL {
    [self udesk_yy_setHighlightedImageWithURL:imageURL
                            placeholder:nil
                                options:kNilOptions
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:nil];
}

- (void)udesk_yy_setHighlightedImageWithURL:(NSURL *)imageURL placeholder:(UIImage *)placeholder {
    [self udesk_yy_setHighlightedImageWithURL:imageURL
                            placeholder:placeholder
                                options:kNilOptions
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:nil];
}

- (void)udesk_yy_setHighlightedImageWithURL:(NSURL *)imageURL options:(UMC_YYWebImageOptions)options {
    [self udesk_yy_setHighlightedImageWithURL:imageURL
                            placeholder:nil
                                options:options
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:nil];
}

- (void)udesk_yy_setHighlightedImageWithURL:(NSURL *)imageURL
                          placeholder:(UIImage *)placeholder
                              options:(UMC_YYWebImageOptions)options
                           completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setHighlightedImageWithURL:imageURL
                            placeholder:placeholder
                                options:options
                                manager:nil
                               progress:nil
                              transform:nil
                             completion:completion];
}

- (void)udesk_yy_setHighlightedImageWithURL:(NSURL *)imageURL
                          placeholder:(UIImage *)placeholder
                              options:(UMC_YYWebImageOptions)options
                             progress:(UMC_YYWebImageProgressBlock)progress
                            transform:(UMC_YYWebImageTransformBlock)transform
                           completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setHighlightedImageWithURL:imageURL
                            placeholder:placeholder
                                options:options
                                manager:nil
                               progress:progress
                              transform:nil
                             completion:completion];
}

- (void)udesk_yy_setHighlightedImageWithURL:(NSURL *)imageURL
                          placeholder:(UIImage *)placeholder
                              options:(UMC_YYWebImageOptions)options
                              manager:(UMC_YYWebImageManager *)manager
                             progress:(UMC_YYWebImageProgressBlock)progress
                            transform:(UMC_YYWebImageTransformBlock)transform
                           completion:(UMC_YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [UMC_YYWebImageManager sharedManager];
    
    UMC_YYWebImageSetter *setter = objc_getAssociatedObject(self, &UMC_YYWebImageHighlightedSetterKey);
    if (!setter) {
        setter = [UMC_YYWebImageSetter new];
        objc_setAssociatedObject(self, &UMC_YYWebImageHighlightedSetterKey, setter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _udesk_yy_dispatch_sync_on_main_queue(^{
        if ((options & UMC_YYWebImageOptionSetImageWithFadeAnimation) &&
            !(options & UMC_YYWebImageOptionAvoidSetImage)) {
            if (self.highlighted) {
                [self.layer removeAnimationForKey:UMC_YYWebImageFadeAnimationKey];
            }
        }
        if (!imageURL) {
            if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
                self.highlightedImage = placeholder;
            }
            return;
        }
        
        // get the image from memory as quickly as possible
        UIImage *imageFromMemory = nil;
        if (manager.cache &&
            !(options & UMC_YYWebImageOptionUseNSURLCache) &&
            !(options & UMC_YYWebImageOptionRefreshImageCache)) {
            imageFromMemory = [manager.cache getImageForKey:[manager cacheKeyForURL:imageURL] withType:UMC_YYImageCacheTypeMemory];
        }
        if (imageFromMemory) {
            if (!(options & UMC_YYWebImageOptionAvoidSetImage)) {
                self.highlightedImage = imageFromMemory;
            }
            if(completion) completion(imageFromMemory, imageURL, UMC_YYWebImageFromMemoryCacheFast, UMC_YYWebImageStageFinished, nil);
            return;
        }
        
        if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
            self.highlightedImage = placeholder;
        }
        
        __weak typeof(self) _self = self;
        dispatch_async([UMC_YYWebImageSetter setterQueue], ^{
            UMC_YYWebImageProgressBlock _progress = nil;
            if (progress) _progress = ^(NSInteger receivedSize, NSInteger expectedSize) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    progress(receivedSize, expectedSize);
                });
            };
            
            __block int32_t newSentinel = 0;
            __block __weak typeof(setter) weakSetter = nil;
            UMC_YYWebImageCompletionBlock _completion = ^(UIImage *image, NSURL *url, UMC_YYWebImageFromType from, UMC_YYWebImageStage stage, NSError *error) {
                __strong typeof(_self) self = _self;
                BOOL setImage = (stage == UMC_YYWebImageStageFinished || stage == UMC_YYWebImageStageProgress) && image && !(options & UMC_YYWebImageOptionAvoidSetImage);
                BOOL showFade = ((options & UMC_YYWebImageOptionSetImageWithFadeAnimation) && self.highlighted);
                dispatch_async(dispatch_get_main_queue(), ^{
                    BOOL sentinelChanged = weakSetter && weakSetter.sentinel != newSentinel;
                    if (setImage && self && !sentinelChanged) {
                        if (showFade) {
                            CATransition *transition = [CATransition animation];
                            transition.duration = stage == UMC_YYWebImageStageFinished ? UMC_YYWebImageFadeTime : UMC_YYWebImageProgressiveFadeTime;
                            transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
                            transition.type = kCATransitionFade;
                            [self.layer addAnimation:transition forKey:UMC_YYWebImageFadeAnimationKey];
                        }
                        self.highlightedImage = image;
                    }
                    if (completion) {
                        if (sentinelChanged) {
                            completion(nil, url, UMC_YYWebImageFromNone, UMC_YYWebImageStageCancelled, nil);
                        } else {
                            completion(image, url, from, stage, error);
                        }
                    }
                });
            };
            
            newSentinel = [setter setOperationWithSentinel:sentinel url:imageURL options:options manager:manager progress:_progress transform:transform completion:_completion];
            weakSetter = setter;
        });
    });
}

- (void)udesk_yy_cancelCurrentHighlightedImageRequest {
    UMC_YYWebImageSetter *setter = objc_getAssociatedObject(self, &UMC_YYWebImageHighlightedSetterKey);
    if (setter) [setter cancel];
}

@end
