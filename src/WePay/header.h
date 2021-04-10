@interface UIColor ()

@property (class, nonatomic, readonly) UIColor *labelColor;

@end


@interface NewMainFrameViewController : UIViewController

- (void)openFace2FaceReceiveMoney;
- (void)showQRInfoView;

@end


@interface ContactsViewController : UIViewController

@end


@interface WCPayTransferGetFixedAmountQRCodeResponse : NSObject

@property (nonatomic, assign) unsigned int qrcode_level;
@property (nonatomic, copy) NSString *m_nsFixedAmountQRCode;

@end


@interface WCPayControlData : NSObject

@property (nonatomic, assign) int fixed_qrcode_level;
@property (nonatomic, assign) int m_enWCPayFacingReceiveMoneyScene;
@property (nonatomic, copy) NSString *m_nsFixedAmountReceiveMoneyQRCode;

@end


@interface WCBaseControlLogic : NSObject

- (id)getCurrentViewController;
- (void)dismissCurrentViewWithAnimated:(_Bool)arg1;

@end


@interface WCBizControlLogic : WCBaseControlLogic

- (void)stopLoading;
- (void)startLoading;

@end


@interface WCPayControlLogic : WCBizControlLogic
{
    WCPayControlData *m_data;
}

- (_Bool)onError:(id)arg1;

@end


@interface WCPayFacingReceiveContorlLogic : WCPayControlLogic

- (void)startLogic;
- (id)initWithData:(id)arg1;

- (void)OnGetFixedAmountQRCode:(WCPayTransferGetFixedAmountQRCodeResponse *)arg1 Error:(id)arg2;
- (void)WCPayFacingReceiveFixedAmountViewControllerNext:(NSString *)arg1 Description:(NSString *)arg2;
- (void)WCPayFacingReceiveChangeToUnFixedAmount;
- (void)WCPayFacingReceiveChangeToFixedAmount;

@end


@interface WCPayFacingReceiveQRCodeViewController : UIViewController

- (void)refreshViewWithData:(id)arg1;

@end


@interface WCPayFacingReceiveFixedAmountViewController : UIViewController

@property (nonatomic, strong) UITextField *feeTextField;
@property (nonatomic, copy) NSString *remark;
- (void)textFieldDidChange;
- (void)onNext;

@end
