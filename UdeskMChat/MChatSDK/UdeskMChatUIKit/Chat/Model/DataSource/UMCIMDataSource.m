//
//  UMCIMDataSource.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/10/18.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCIMDataSource.h"
#import "UMCBaseCell.h"
#import "UMCBaseMessage.h"

@implementation UMCIMDataSource 

#pragma mark - TableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messagesArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.messagesArray.count <= indexPath.row) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"errorCellWithIdentifier"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"errorCellWithIdentifier"];
        }
        return cell;
    }
    
    id message = self.messagesArray[indexPath.row];
    
    NSString *messageModelName = NSStringFromClass([message class]);
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageModelName];
    
    if (!cell) {
        
        cell = [(UMCBaseMessage *)message getCellWithReuseIdentifier:messageModelName];
        UMCBaseCell *chatCell = (UMCBaseCell *)cell;
        chatCell.delegate = self.delegate;
    }
    
    if (![cell isKindOfClass:[UMCBaseCell class]]) {
        return cell;
    }
    
    [(UMCBaseCell *)cell updateCellWithMessage:message];
    
    return cell;
}

@end
