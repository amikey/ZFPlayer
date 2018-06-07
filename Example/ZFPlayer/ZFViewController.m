//
//  ZFViewController.m
//  ZFPlayer_Example
//
//  Created by 任子丰 on 2018/6/7.
//  Copyright © 2018年 紫枫. All rights reserved.
//

#import "ZFViewController.h"
static NSString *kIdentifier = @"kIdentifier";

@interface ZFViewController () <UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *viewControllers;

@end

@implementation ZFViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
    self.titles = @[@"Keyboard",
                        @"Noraml",
                        @"Click to play the at tableView",
                        @"Automatic to play at tableView",
                        @"Small window to play at tableView",
                        @"Light and dark to play at tableView",
                        @"Dou yin style"];
    
    self.viewControllers = @[@"ZFKeyboardViewController",
                             @"ZFNoramlViewController",
                             @"ZFNotAutoPlayViewController",
                             @"ZFNormalTableViewController",
                             @"ZFSmallPlayViewController",
                             @"ZFLightTableViewController",
                             @"ZFDouYinViewController"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.tableView.frame = self.view.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.titles.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kIdentifier];
    cell.textLabel.text = self.titles[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString *vcString = self.viewControllers[indexPath.row];
    UIViewController *viewController = [[NSClassFromString(vcString) alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kIdentifier];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = 44;
    }
    return _tableView;
}

@end
