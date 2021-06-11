//
//  UIButton+YYWebImage.m
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/2/23.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "UIButton+UMC_YYWebImage.h"
#import "UMC_YYWebImageOperation.h"
#import "UMC_YYWebImageSetter.h"
#import <objc/runtime.h>

// Dummy class for category
@interface UMC_UIButton_YYWebImage : NSObject @end
@implementation UMC_UIButton_YYWebImage @end

static inline NSNumber *UdeskUIControlStateSingle(UIControlState state) {
    if (state & UIControlStateHighlighted) return @(UIControlStateHighlighted);
    if (state & UIControlStateDisabled) return @(UIControlStateDisabled);
    if (state & UIControlStateSelected) return @(UIControlStateSelected);
    return @(UIControlStateNormal);
}

static inline NSArray *UdeskUIControlStateMulti(UIControlState state) {
    NSMutableArray *array = [NSMutableArray new];
    if (state & UIControlStateHighlighted) [array addObject:@(UIControlStateHighlighted)];
    if (state & UIControlStateDisabled) [array addObject:@(UIControlStateDisabled)];
    if (state & UIControlStateSelected) [array addObject:@(UIControlStateSelected)];
    if ((state & 0xFF) == 0) [array addObject:@(UIControlStateNormal)];
    return array;
}

static int UMC_YYWebImageSetterKey;
static int _YYWebImageBackgroundSetterKey;


@interface UMC_YYWebImageSetterDicForButton : NSObject
- (UMC_YYWebImageSetter *)setterForState:(NSNumber *)state;
- (UMC_YYWebImageSetter *)lazySetterForState:(NSNumber *)state;
@end

@implementation UMC_YYWebImageSetterDicForButton {
    NSMutableDictionary *_dic;
    dispatch_semaphore_t _lock;
}
- (instancetype)init {
    self = [super init];
    _lock = dispatch_semaphore_create(1);
    _dic = [NSMutableDictionary new];
    return self;
}
- (UMC_YYWebImageSetter *)setterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    UMC_YYWebImageSetter *setter = _dic[state];
    dispatch_semaphore_signal(_lock);
    return setter;
    
}
- (UMC_YYWebImageSetter *)lazySetterForState:(NSNumber *)state {
    dispatch_semaphore_wait(_lock, DISPATCH_TIME_FOREVER);
    UMC_YYWebImageSetter *setter = _dic[state];
    if (!setter) {
        setter = [UMC_YYWebImageSetter new];
        _dic[state] = setter;
    }
    dispatch_semaphore_signal(_lock);
    return setter;
}
@end


@implementation UIButton (UMC_YYWebImage)

#pragma mark - image

- (void)_udesk_yy_setImageWithURL:(NSURL *)imageURL
             forSingleState:(NSNumber *)state
                placeholder:(UIImage *)placeholder
                    options:(UMC_YYWebImageOptions)options
                    manager:(UMC_YYWebImageManager *)manager
                   progress:(UMC_YYWebImageProgressBlock)progress
                  transform:(UMC_YYWebImageTransformBlock)transform
                 completion:(UMC_YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [UMC_YYWebImageManager sharedManager];
    
    UMC_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &UMC_YYWebImageSetterKey);
    if (!dic) {
        dic = [UMC_YYWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &UMC_YYWebImageSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UMC_YYWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _udesk_yy_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
                [self setImage:placeholder forState:state.integerValue];
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
                [self setImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, UMC_YYWebImageFromMemoryCacheFast, UMC_YYWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
            [self setImage:placeholder forState:state.integerValue];
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
                        [self setImage:image forState:state.integerValue];
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

- (void)_udesk_yy_cancelImageRequestForSingleState:(NSNumber *)state {
    UMC_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &UMC_YYWebImageSetterKey);
    UMC_YYWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)udesk_yy_imageURLForState:(UIControlState)state {
    UMC_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &UMC_YYWebImageSetterKey);
    UMC_YYWebImageSetter *setter = [dic setterForState:UdeskUIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder {
    [self udesk_yy_setImageWithURL:imageURL
                 forState:state
              placeholder:placeholder
                  options:kNilOptions
                  manager:nil
                 progress:nil
                transform:nil
               completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
                   options:(UMC_YYWebImageOptions)options {
    [self udesk_yy_setImageWithURL:imageURL
                    forState:state
                 placeholder:nil
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:nil];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(UMC_YYWebImageOptions)options
                completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:nil
                   transform:nil
                  completion:completion];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(UMC_YYWebImageOptions)options
                  progress:(UMC_YYWebImageProgressBlock)progress
                 transform:(UMC_YYWebImageTransformBlock)transform
                completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setImageWithURL:imageURL
                    forState:state
                 placeholder:placeholder
                     options:options
                     manager:nil
                    progress:progress
                   transform:transform
                  completion:completion];
}

- (void)udesk_yy_setImageWithURL:(NSURL *)imageURL
                  forState:(UIControlState)state
               placeholder:(UIImage *)placeholder
                   options:(UMC_YYWebImageOptions)options
                   manager:(UMC_YYWebImageManager *)manager
                  progress:(UMC_YYWebImageProgressBlock)progress
                 transform:(UMC_YYWebImageTransformBlock)transform
                completion:(UMC_YYWebImageCompletionBlock)completion {
    for (NSNumber *num in UdeskUIControlStateMulti(state)) {
        [self _udesk_yy_setImageWithURL:imageURL
                   forSingleState:num
                      placeholder:placeholder
                          options:options
                          manager:manager
                         progress:progress
                        transform:transform
                       completion:completion];
    }
}

- (void)udesk_yy_cancelImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UdeskUIControlStateMulti(state)) {
        [self _udesk_yy_cancelImageRequestForSingleState:num];
    }
}


#pragma mark - background image

- (void)_udesk_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                       forSingleState:(NSNumber *)state
                          placeholder:(UIImage *)placeholder
                              options:(UMC_YYWebImageOptions)options
                              manager:(UMC_YYWebImageManager *)manager
                             progress:(UMC_YYWebImageProgressBlock)progress
                            transform:(UMC_YYWebImageTransformBlock)transform
                           completion:(UMC_YYWebImageCompletionBlock)completion {
    if ([imageURL isKindOfClass:[NSString class]]) imageURL = [NSURL URLWithString:(id)imageURL];
    manager = manager ? manager : [UMC_YYWebImageManager sharedManager];
    
    UMC_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_YYWebImageBackgroundSetterKey);
    if (!dic) {
        dic = [UMC_YYWebImageSetterDicForButton new];
        objc_setAssociatedObject(self, &_YYWebImageBackgroundSetterKey, dic, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    UMC_YYWebImageSetter *setter = [dic lazySetterForState:state];
    int32_t sentinel = [setter cancelWithNewURL:imageURL];
    
    _udesk_yy_dispatch_sync_on_main_queue(^{
        if (!imageURL) {
            if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
                [self setBackgroundImage:placeholder forState:state.integerValue];
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
                [self setBackgroundImage:imageFromMemory forState:state.integerValue];
            }
            if(completion) completion(imageFromMemory, imageURL, UMC_YYWebImageFromMemoryCacheFast, UMC_YYWebImageStageFinished, nil);
            return;
        }
        
        
        if (!(options & UMC_YYWebImageOptionIgnorePlaceHolder)) {
            [self setBackgroundImage:placeholder forState:state.integerValue];
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
                        [self setBackgroundImage:image forState:state.integerValue];
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

- (void)_udesk_yy_cancelBackgroundImageRequestForSingleState:(NSNumber *)state {
    UMC_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_YYWebImageBackgroundSetterKey);
    UMC_YYWebImageSetter *setter = [dic setterForState:state];
    if (setter) [setter cancel];
}

- (NSURL *)udesk_yy_backgroundImageURLForState:(UIControlState)state {
    UMC_YYWebImageSetterDicForButton *dic = objc_getAssociatedObject(self, &_YYWebImageBackgroundSetterKey);
    UMC_YYWebImageSetter *setter = [dic setterForState:UdeskUIControlStateSingle(state)];
    return setter.imageURL;
}

- (void)udesk_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder {
    [self udesk_yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:kNilOptions
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)udesk_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                             options:(UMC_YYWebImageOptions)options {
    [self udesk_yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:nil
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:nil];
}

- (void)udesk_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(UMC_YYWebImageOptions)options
                          completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:nil
                             transform:nil
                            completion:completion];
}

- (void)udesk_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(UMC_YYWebImageOptions)options
                            progress:(UMC_YYWebImageProgressBlock)progress
                           transform:(UMC_YYWebImageTransformBlock)transform
                          completion:(UMC_YYWebImageCompletionBlock)completion {
    [self udesk_yy_setBackgroundImageWithURL:imageURL
                              forState:state
                           placeholder:placeholder
                               options:options
                               manager:nil
                              progress:progress
                             transform:transform
                            completion:completion];
}

- (void)udesk_yy_setBackgroundImageWithURL:(NSURL *)imageURL
                            forState:(UIControlState)state
                         placeholder:(UIImage *)placeholder
                             options:(UMC_YYWebImageOptions)options
                             manager:(UMC_YYWebImageManager *)manager
                            progress:(UMC_YYWebImageProgressBlock)progress
                           transform:(UMC_YYWebImageTransformBlock)transform
                          completion:(UMC_YYWebImageCompletionBlock)completion {
    for (NSNumber *num in UdeskUIControlStateMulti(state)) {
        [self _udesk_yy_setBackgroundImageWithURL:imageURL
                             forSingleState:num
                                placeholder:placeholder
                                    options:options
                                    manager:manager
                                   progress:progress
                                  transform:transform
                                 completion:completion];
    }
}

- (void)udesk_yy_cancelBackgroundImageRequestForState:(UIControlState)state {
    for (NSNumber *num in UdeskUIControlStateMulti(state)) {
        [self _udesk_yy_cancelBackgroundImageRequestForSingleState:num];
    }
}

@end
