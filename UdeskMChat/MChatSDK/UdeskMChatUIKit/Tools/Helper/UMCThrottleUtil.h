//
//  UdeskThrottleUtil.h
//  UdeskSDK
//
//  Created by xuchen on 2018/6/7.
//  Copyright © 2018年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>

#define UMC_THROTTLE_MAIN_QUEUE             (dispatch_get_main_queue())
#define UMC_THROTTLE_GLOBAL_QUEUE           (dispatch_get_global_queue(0, 0))

typedef void (^UMCThrottleBlock) (void);

@interface UMCThrottleUtil : NSObject

void umc_dispatch_throttle(NSTimeInterval threshold, UMCThrottleBlock block);

@end
