//
//  UMCDeveloperViewController.m
//  UdeskMChat
//
//  Created by xuchen on 2019/9/10.
//  Copyright © 2019 Udesk. All rights reserved.
//

#import "UMCDeveloperViewController.h"
#import "UMCCustomButtonTableViewController.h"

@interface UMCDeveloperViewController ()

@property (nonatomic, strong) NSArray *dataSource;

@end

@implementation UMCDeveloperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCellIdentifier"];
    self.dataSource = @[
                        @"自定义按钮",
                        ];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCellIdentifier" forIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = self.dataSource[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        
        UMCCustomButtonTableViewController *customButtonVC = [[UMCCustomButtonTableViewController alloc] init];
        [self.navigationController pushViewController:customButtonVC animated:YES];
    }
}

@end
