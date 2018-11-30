#import "ModalViewController.h"
#import "BLE.h"

@interface DeviceChangePasswordViewController : ModalViewController <BLEDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *viewChangePassword;
@property (weak, nonatomic) IBOutlet UIView *viewSetPassword;

@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@property (weak, nonatomic) IBOutlet UITextField *txtCurrentPassowrd;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmNewPassword;

@end
