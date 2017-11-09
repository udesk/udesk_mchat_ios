//
//  UMCMerchantsDataSource.h
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol UMCMerchantsDataSourceDelegate <NSObject>

- (void)deleteMerchantForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface UMCMerchantsDataSource : NSObject<UITableViewDataSource>

@property (nonatomic, strong) NSArray *merchantsArray;
@property (nonatomic, weak  ) id<UMCMerchantsDataSourceDelegate> delegate;

@end
