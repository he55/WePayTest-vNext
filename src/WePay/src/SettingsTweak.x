#import "WeChat.h"
#import "WPConfig.h"

extern NSString *WePayServiceURL;

%hook NewSettingViewController

- (void)reloadTableData {
    %orig;

    WCTableViewSectionManager *section = [%c(WCTableViewSectionManager) sectionInfoDefaut];

    BOOL serviceEnable = [WPConfig sharedConfig].serviceEnable;
    [section addCell:[%c(WCTableViewCellManager) switchCellForSel:@selector(handleSettingServiceEnable:) target:self title:@"启动 WePay" on:serviceEnable]];

    WCTableViewCellManager *cell = serviceEnable ?
        [%c(WCTableViewCellManager) normalCellForSel:@selector(handleSettingServiceURL) target:self title:@"服务器地址" rightValue:WePayServiceURL] :
        [%c(WCTableViewNormalCellManager) normalCellForTitle:@"服务器地址" rightValue:WePayServiceURL];
    [section addCell:cell];

    [section addCell:[%c(WCTableViewCellManager) normalCellForSel:@selector(handleShowGitHub) target:self title:@"GitHub" rightValue:@"Star ★"]];

    WCTableViewManager *tableViewMgr = [self valueForKey:@"m_tableViewMgr"];
    [tableViewMgr insertSection:section At:4];
    [[tableViewMgr getTableView] reloadData];
}

%new
- (void)handleSettingServiceEnable:(UISwitch *)sw {
    [WPConfig sharedConfig].serviceEnable = sw.on;
    [self reloadTableData];
}

%new
- (void)handleSettingServiceURL {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:@"设置服务器地址" preferredStyle:UIAlertControllerStyleAlert];

    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入服务器地址";
        textField.text = WePayServiceURL;
        textField.keyboardType = UIKeyboardTypeURL;
    }];

    UIAlertAction *okAlertAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        WePayServiceURL = alertController.textFields[0].text;
        [WPConfig sharedConfig].serviceURL = WePayServiceURL;
        [self reloadTableData];
    }];

    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:okAlertAction];

    [self presentViewController:alertController animated:YES completion:nil];
}

%new
- (void)handleShowGitHub {
    NSURL *gitHubUrl = [NSURL URLWithString:@"https://github.com/he55"];
    MMWebViewController *webViewController = [[%c(MMWebViewController) alloc] initWithURL:gitHubUrl presentModal:NO extraInfo:nil];
    [self.navigationController PushViewController:webViewController animated:YES];
}

%end
