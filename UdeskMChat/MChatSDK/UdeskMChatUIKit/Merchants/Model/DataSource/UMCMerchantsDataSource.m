//
//  UMCMerchantsDataSource.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCMerchantsDataSource.h"
#import "UMCMerchantsCell.h"

@class UMCMerchant;

@implementation UMCMerchantsDataSource

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.merchantsArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.merchantsArray.count <= indexPath.row) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"errorCellWithIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"errorCellWithIdentifier"];
        }
        return cell;
    }
    
    UMCMerchant *merchant = self.merchantsArray[indexPath.row];
    UMCMerchantsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UMCMerchantsCell"];
    
    if (!cell) {
        cell = [[UMCMerchantsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UMCMerchantsCell"];
    }
    cell.merchant = merchant;
    
    return cell;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        if (self.delegate && [self.delegate respondsToSelector:@selector(deleteMerchantForRowAtIndexPath:)]) {
            [self.delegate deleteMerchantForRowAtIndexPath:indexPath];
        }
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

@end
