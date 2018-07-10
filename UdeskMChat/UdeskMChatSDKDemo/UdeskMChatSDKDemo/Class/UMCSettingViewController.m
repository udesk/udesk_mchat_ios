//
//  UMCSettingViewController.m
//  UdeskMChatExample
//
//  Created by xuchen on 2017/12/21.
//  Copyright © 2017年 Udesk. All rights reserved.
//

#import "UMCSettingViewController.h"

@interface UMCSettingViewController ()

@end

@implementation UMCSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.tableFooterView = [UIView new];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"customButtonId" forIndexPath:indexPath];
        return cell;
    }
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"conversationListId" forIndexPath:indexPath];
    
    return cell;
}

@end
