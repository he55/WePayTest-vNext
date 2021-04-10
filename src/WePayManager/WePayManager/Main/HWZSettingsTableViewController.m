//
//  HWZSettingsTableViewController.m
//  WePayManager
//
//  Created by 何伟忠 on 6/3/20.
//  Copyright © 2020 何伟忠. All rights reserved.
//

#import "HWZSettingsTableViewController.h"
#import "HWZWeChatLocalInfo.h"
#import "HWZWeChatUserInfoItem.h"
#import "HWZWeChatMessage.h"
#import "HWZHelper.h"
#import "HWZSettings.h"
#import "MBProgressHUD.h"

static NSString * const HWZWePaydStatusURL = @"http://localhost:5200/status";
static NSString * const HWZWePaydRestartURL = @"http://localhost:5200/restart";

@interface HWZSettingsTableViewController ()

// WeChat
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UILabel *wxidLabel;
@property (weak, nonatomic) IBOutlet UILabel *userIdLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dbPathLabel;
@property (weak, nonatomic) IBOutlet UILabel *tableNameLabel;

// wepayd
@property (weak, nonatomic) IBOutlet UILabel *wepaydStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *wepaydPidLabel;
@property (weak, nonatomic) IBOutlet UILabel *wepaydURLLabel;

// order service
@property (weak, nonatomic) IBOutlet UILabel *orderServiceStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderServiceURLLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderServiceCallbackURLLabel;

@end


@implementation HWZSettingsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"设置";
    self.clearsSelectionOnViewWillAppear = YES;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"刷新" style:UIBarButtonItemStyleDone target:self action:@selector(handleReloadInfo)];
    
    [self loadWeChatInfo];
    [self loadWePaydInfo];
    [self loadOrderServiceInfo];
}


#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1 && indexPath.row == 3) {
        [self restartWePayd];
    } else if (indexPath.section == 2 && indexPath.row == 1) {
        [self setOrderServiceURL];
    } else if (indexPath.section == 3 && indexPath.row == 0) {
        [self saveSettings];
    }
}


- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ((indexPath.section == 0 && indexPath.row > 0) ||
        (indexPath.section == 1 && (indexPath.row == 1 || indexPath.row == 2)) ||
        (indexPath.section == 2 && indexPath.row == 2)) {
        return YES;
    }
    return NO;
}


- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        return YES;
    }
    return NO;
}


- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender {
    if (action == @selector(copy:)) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        [UIPasteboard generalPasteboard].string = cell.detailTextLabel.text ?: @"";
    }
}


#pragma mark - Private

- (void)loadWeChatInfo {
    HWZWeChatUserInfoItem *userInfo = [HWZWeChatLocalInfo userInfo];
    if (userInfo) {
        self.statusLabel.text = @"已安装";
    } else {
        self.statusLabel.text = @"未安装";
    }
    
    if (userInfo.wxid) {
        self.wxidLabel.text = userInfo.wxid;
        self.userIdLabel.text = userInfo.userId;
        self.userNameLabel.text = userInfo.userName;
        self.dbPathLabel.text = userInfo.dbPath;
        HWZDbPath = userInfo.dbPath;
    } else {
        self.wxidLabel.text = @"";
        self.userIdLabel.text = @"";
        self.userNameLabel.text = @"";
        self.dbPathLabel.text = @"";
        HWZDbPath = nil;
    }
    
    
    HWZTableName = [HWZWeChatMessage tableNameWithDbPath:userInfo.dbPath];
    if (HWZTableName) {
        self.tableNameLabel.text = HWZTableName;
        return;
    }
    
    self.tableNameLabel.text = @"获取失败";
    [HWZHelper alertWithViewController:self message:@"请在微信消息列表，找到微信支付消息会话。发送 '123qwe' 验证，然后刷新数据。"];
}


- (void)loadWePaydInfo {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:HWZWePaydStatusURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSArray *status = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] componentsSeparatedByString:@" "];
                if (status.count == 2) {
                    self.wepaydStatusLabel.text = @"已启动";
                    self.wepaydPidLabel.text = status[1];
                    self.wepaydURLLabel.text = status[0];
                    return;
                }
            }
            
            self.wepaydStatusLabel.text = @"未启动";
            self.wepaydPidLabel.text = @" ";
            self.wepaydURLLabel.text = @" ";
        });
    }];
    [dataTask resume];
}


- (void)loadOrderServiceInfo {
    if (!HWZOrderServiceURL) {
        return;
    }
    
    self.orderServiceURLLabel.text = HWZOrderServiceURL;
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:[HWZOrderServiceURL stringByAppendingPathComponent:@"status"]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.orderServiceStatusLabel.text = @"未启动";
                self.orderServiceCallbackURLLabel.text = @" ";
                return;
            }
            
            NSString *callback = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            HWZOrderServiceCallbackURL = [HWZOrderServiceURL stringByAppendingPathComponent:callback];
            
            self.orderServiceStatusLabel.text = @"已启动";
            self.orderServiceCallbackURLLabel.text = HWZOrderServiceCallbackURL;
        });
    }];
    [dataTask resume];
}


- (void)sureAlertWithBlock:(void (^)(void))block message:(NSString *)message {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }];
    
    UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        
        if (block) {
            block();
        }
    }];
    
    [alertController addAction:cancelAlertAction];
    [alertController addAction:okAlertAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)restartWePayd {
    [self sureAlertWithBlock:^{
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithURL:[NSURL URLWithString:HWZWePaydRestartURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            dispatch_async(dispatch_get_main_queue(), ^{
                MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
                hud.mode = MBProgressHUDModeText;
                
                if (error) {
                    hud.label.text = @"服务重启失败";
                } else {
                    hud.completionBlock = ^{
                        [self loadWePaydInfo];
                    };
                    hud.label.text = @"服务重启成功";
                }
                
                [hud hideAnimated:YES afterDelay:1.0];
            });
        }];
        [dataTask resume];
    } message:@"重新启动服务？"];
}


- (void)setOrderServiceURL {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"设置订单服务地址" preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入订单服务地址";
        textField.text = HWZOrderServiceURL ?: @"";
        textField.keyboardType = UIKeyboardTypeURL;
    }];
    
    UIAlertAction *cancelAlertAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    }];
    
    UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        
        HWZOrderServiceURL = alertController.textFields[0].text;
        [self loadOrderServiceInfo];
    }];
    
    [alertController addAction:cancelAlertAction];
    [alertController addAction:okAlertAction];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


- (void)saveSettings {
    if (![HWZSettings saveSettings]) {
        [HWZHelper alertWithViewController:self message:@"缺少配置，无法保存"];
        return;
    }
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = @"保存成功";
    hud.completionBlock = ^{
        [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
        [self restartWePayd];
    };
    
    [hud hideAnimated:YES afterDelay:0.5];
}


#pragma mark - Action

- (void)handleReloadInfo {
    [self loadWeChatInfo];
    [self loadWePaydInfo];
    [self loadOrderServiceInfo];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.label.text = @"正在加载...";
    [hud hideAnimated:YES afterDelay:0.5];
}

@end
