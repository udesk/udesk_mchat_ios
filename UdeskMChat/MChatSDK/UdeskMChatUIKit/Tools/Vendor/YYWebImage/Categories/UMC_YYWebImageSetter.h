//
//  _YYWebImageSetter.h
//  YYWebImage <https://github.com/ibireme/YYWebImage>
//
//  Created by ibireme on 15/7/15.
//  Copyright (c) 2015 ibireme.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//
#import <UIKit/UIKit.h>
#import <pthread.h>
#import "UMC_YYWebImageManager.h"

NS_ASSUME_NONNULL_BEGIN

/**
 Submits a block for execution on a main queue and waits until the block completes.
 */
static inline void _udesk_yy_dispatch_sync_on_main_queue(void (^block)(void)) {
    if (pthread_main_np()) {
        block();
    } else {
        dispatch_sync(dispatch_get_main_queue(), block);
    }
}

extern NSString *const UMC_YYWebImageFadeAnimationKey;
extern const NSTimeInterval UMC_YYWebImageFadeTime;
extern const NSTimeInterval UMC_YYWebImageProgressiveFadeTime;

/**
 Private class used by web image categories.
 Typically, you should not use this class directly.
 */
@interface UMC_YYWebImageSetter : NSObject
/// Current image url.
@property (nullable, nonatomic, readonly) NSURL *imageURL;
/// Current sentinel.
@property (nonatomic, readonly) int32_t sentinel;

/// Create new operation for web image and return a sentinel value.
- (int32_t)setOperationWithSentinel:(int32_t)sentinel
                                url:(nullable NSURL *)imageURL
                            options:(UMC_YYWebImageOptions)options
                            manager:(UMC_YYWebImageManager *)manager
                           progress:(nullable UMC_YYWebImageProgressBlock)progress
                          transform:(nullable UMC_YYWebImageTransformBlock)transform
                         completion:(nullable UMC_YYWebImageCompletionBlock)completion;

/// Cancel and return a sentinel value. The imageURL will be set to nil.
- (int32_t)cancel;

/// Cancel and return a sentinel value. The imageURL will be set to new value.
- (int32_t)cancelWithNewURL:(nullable NSURL *)imageURL;

/// A queue to set operation.
+ (dispatch_queue_t)setterQueue;

@end

NS_ASSUME_NONNULL_END
