#import "header.h"
#import "CAppViewControllerManager.h"
#import "WCUIAlertView.h"

static WCPayFacingReceiveContorlLogic *wcPayFacingReceiveContorlLogic;
static int tweakMode;
static NSString *lastFixedAmountQRCode;
static NSMutableArray<NSMutableDictionary *> *s_orderTasks;
static NSMutableDictionary *s_orderTask;
static NSString * const WePayServiceURL = @"http://192.168.0.101:5000";


static void makeQRCode(NSDictionary *orderTask) {
    dispatch_async(dispatch_get_main_queue(), ^{
        [wcPayFacingReceiveContorlLogic WCPayFacingReceiveFixedAmountViewControllerNext:orderTask[@"orderAmount"] Description:orderTask[@"orderId"]];
    });
}


static void getOrderTask() {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/getOrderTask", WePayServiceURL]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (((NSHTTPURLResponse *)response).statusCode == 200) {
            NSMutableArray *arr = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
            [s_orderTasks addObjectsFromArray:arr];
        }
    }];
    [dataTask resume];
}


static void postOrderTask(NSDictionary *orderTask) {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/postOrderTask", WePayServiceURL]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:orderTask options:kNilOptions error:nil];

    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (((NSHTTPURLResponse *)response).statusCode == 200) {
        }
    }];
    [dataTask resume];
}


static void saveOrderTaskLog(NSDictionary *orderTask) {
    static NSString *logPath = nil;
    if (!logPath) {
        NSString *cachesDirectory = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES).firstObject;
        logPath = [cachesDirectory stringByAppendingPathComponent:@"WePayOrder.log"];
    }

    NSOutputStream *outputStream = [[NSOutputStream alloc] initToFileAtPath:logPath append:YES];
    [outputStream open];

    NSData *data = [[NSString stringWithFormat:@"%@\n\n", orderTask] dataUsingEncoding:NSUTF8StringEncoding];
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
        s_orderTask[@"orderCode"] = lastFixedAmountQRCode;
        saveOrderTaskLog(s_orderTask);
        postOrderTask(s_orderTask);
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


// 接收消息
%hook CMessageMgr

- (void)onNewSyncAddMessage:(id)arg1 {
    %orig;
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

    [NSTimer scheduledTimerWithTimeInterval:2.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
        getOrderTask();
    }];
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
