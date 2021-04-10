//
//  HWZMessageTableViewController.m
//  WePayManager
//
//  Created by 何伟忠 on 6/3/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZMessageTableViewController.h"
#import "HWZWeChatMessage.h"
#import "HWZWeChatMessageItem.h"
#import "HWZMessageDetailViewController.h"
#import "MBProgressHUD.h"
#import "MJRefresh.h"

static NSString * const messageCellId = @"messageCellId";

@interface HWZMessageTableViewController ()

@property (nonatomic, strong) NSDateFormatter *dateFormatter;
@property (nonatomic, strong) HWZMessageDetailViewController *messageDetailViewController;

@property (nonatomic, strong) NSArray<HWZWeChatMessageItem *> *messageItems;

@end


@implementation HWZMessageTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"收款数据";
    self.clearsSelectionOnViewWillAppear = YES;
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadMessageData)];
    [self.tableView.mj_header beginRefreshing];
}


- (void)loadMessageData {
    NSArray *messageItems = [HWZWeChatMessage messagesWithTimestamp:0];
    if (!messageItems) {
        [self.tableView.mj_header endRefreshing];
        
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = @"数据加载失败，请检查设置";
        
        [hud hideAnimated:YES afterDelay:1.5];
        return;
    }
    
    self.messageItems = messageItems;
    
    [self.tableView reloadData];
    [self.tableView.mj_header endRefreshing];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.messageDetailViewController.messageItem = self.messageItems[indexPath.row];
    [self.navigationController pushViewController:self.messageDetailViewController animated:YES];
}


- (UIContextMenuConfiguration *)tableView:(UITableView *)tableView contextMenuConfigurationForRowAtIndexPath:(NSIndexPath *)indexPath point:(CGPoint)point {
    
    UIContextMenuConfiguration *contextMenuConfiguration = [UIContextMenuConfiguration configurationWithIdentifier:@"messageDetailViewController" previewProvider:^UIViewController * _Nullable{
        
        self.messageDetailViewController.messageItem = self.messageItems[indexPath.row];
        return self.messageDetailViewController;
    } actionProvider:nil];
    
    return contextMenuConfiguration;
}


- (void)tableView:(UITableView *)tableView willPerformPreviewActionForMenuWithConfiguration:(UIContextMenuConfiguration *)configuration animator:(id<UIContextMenuInteractionCommitAnimating>)animator {
    
    UIViewController *previewViewController = animator.previewViewController;
    
    [animator addCompletion:^{
        [self.navigationController pushViewController:previewViewController animated:YES];
    }];
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageItems.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    HWZWeChatMessageItem *message = self.messageItems[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:messageCellId];
    cell.textLabel.text = message.messageId;
    cell.detailTextLabel.text = [self.dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:message.createTime]];
    
    return cell;
}


#pragma mark - Getter / Setter

- (NSDateFormatter *)dateFormatter {
    if (!_dateFormatter) {
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    }
    return _dateFormatter;
}


- (HWZMessageDetailViewController *)messageDetailViewController {
    if (!_messageDetailViewController) {
        _messageDetailViewController = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HWZMessageDetailViewController"];
    }
    return _messageDetailViewController;
}

@end
