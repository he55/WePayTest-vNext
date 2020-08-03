#import "header.h"
#import "CAppViewControllerManager.h"
#import "WCUIAlertView.h"

static WCPayFacingReceiveContorlLogic *wcPayFacingReceiveContorlLogic;
static int tweakMode;
static NSString *lastFixedAmountQRCode;
static NSMutableArray<NSString *> *orderStrings;


static void saveOrderLog(NSString *order) {
    static NSString *logPath = nil;
    if (!logPath) {
        NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        logPath = [cachesDirectory stringByAppendingPathComponent:@"WePayOrder.log"];
    }

    NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:logPath append:YES];
    [outputStream open];

    NSData *data = [[NSString stringWithFormat:@"%@\n", order] dataUsingEncoding:NSUTF8StringEncoding];
    [outputStream write:data.bytes maxLength:data.length];
    [outputStream close];
}


%hook WCPayFacingReceiveContorlLogic

- (id)initWithData:(id)arg1 {
    if (!wcPayFacingReceiveContorlLogic) {
        wcPayFacingReceiveContorlLogic = self;
    }
    return %orig;
}


- (void)OnGetFixedAmountQRCode:(WCPayTransferGetFixedAmountQRCodeResponse *)arg1 Error:(id)arg2 {
    if ([self onError:arg2] || [lastFixedAmountQRCode isEqualToString:arg1.m_nsFixedAmountQRCode]) {
        return;
    }
    lastFixedAmountQRCode = arg1.m_nsFixedAmountQRCode;

    if (tweakMode == 0) {
        orderStrings[0] = @"wers";
        [orderStrings addObject:lastFixedAmountQRCode];

        NSString *order = [orderStrings componentsJoinedByString:@"::"];
        saveOrderLog(order);

        [UIPasteboard generalPasteboard].string = order;

        [self stopLoading];
    } else if (tweakMode == 1) {
        tweakMode = 0;

        WCPayControlData *m_data = [self valueForKey:@"m_data"];
        m_data.m_nsFixedAmountReceiveMoneyQRCode = arg1.m_nsFixedAmountQRCode;
        m_data.fixed_qrcode_level = arg1.qrcode_level;
        m_data.m_enWCPayFacingReceiveMoneyScene = 2;

        [self stopLoading];

        id viewController = [[%c(CAppViewControllerManager) getAppViewControllerManager] getTopViewController];
        if ([viewController isKindOfClass:%c(WCPayFacingReceiveQRCodeViewController)]) {
            [(WCPayFacingReceiveQRCodeViewController *)viewController refreshViewWithData:m_data];
        }
    } else if (tweakMode == 2) {
        tweakMode = 0;
        %orig;
    }
}

%end


%hook MainFrameLogicController

- (void)onSessionTotalUnreadCountChange:(unsigned int)arg1 {
    %orig;
    //
}

%end


// 二维码收款
%hook WCPayFacingReceiveQRCodeViewController

- (void)viewDidLoad {
    %orig;

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"测试" style:UIBarButtonItemStylePlain target:self action:@selector(handleCodeTest)];
    [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor labelColor]} forState:UIControlStateNormal];
    [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor labelColor]} forState:UIControlStateHighlighted];

    self.navigationItem.rightBarButtonItem = barButtonItem;
}

%new
- (void)handleCodeTest {
    tweakMode = 1;
    NSString *amount = [NSString stringWithFormat:@"%d", arc4random_uniform(100)];
    [wcPayFacingReceiveContorlLogic WCPayFacingReceiveFixedAmountViewControllerNext:amount Description:@"我是备注"];
}

%end


// 二维码收款 > 设置金额
%hook WCPayFacingReceiveFixedAmountViewController

- (void)onNext {
    tweakMode = 2;
    %orig;
}

%end


// 微信
%hook NewMainFrameViewController

- (void)viewDidAppear:(BOOL)animated {
    %orig;

    if (!self.navigationItem.leftBarButtonItem) {
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"二维码收款" style:UIBarButtonItemStylePlain target:self action:@selector(handleOpenFace2FaceReceiveMoney)];
        [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor labelColor]} forState:UIControlStateNormal];
        [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor labelColor]} forState:UIControlStateHighlighted];
        self.navigationItem.leftBarButtonItem = barButtonItem;
    }

    if (!wcPayFacingReceiveContorlLogic) {
        [%c(WCUIAlertView) showAlertWithTitle:@"WePay" message:@"WePay 需要打开二维码收款" btnTitle:@"打开二维码收款" target:self sel:@selector(handleOpenFace2FaceReceiveMoney)];
    }
}

%new
- (void)handleOpenFace2FaceReceiveMoney {
    [self openFace2FaceReceiveMoney];
}

%end


// 通讯录
%hook ContactsViewController

- (void)viewDidLoad {
    %orig;

    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"我" style:UIBarButtonItemStylePlain target:self action:@selector(handleShowQRInfoView)];
    [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor labelColor]} forState:UIControlStateNormal];
    [barButtonItem setTitleTextAttributes:@{NSForegroundColorAttributeName: [UIColor labelColor]} forState:UIControlStateHighlighted];

    self.navigationItem.leftBarButtonItem = barButtonItem;
}

%new
- (void)handleShowQRInfoView {
    UITabBarController *tabBarController = [%c(CAppViewControllerManager) getTabBarController];
    tabBarController.selectedIndex = 0;

    CAppViewControllerManager *appViewControllerManager = [%c(CAppViewControllerManager) getAppViewControllerManager];
    NewMainFrameViewController *newMainFrameViewController = [appViewControllerManager getNewMainFrameViewController];
    [newMainFrameViewController showQRInfoView];
}

%end
