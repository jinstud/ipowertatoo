#import <UIKit/UIKit.h>
#import "BLE.h"

@interface DevicePasswordViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnEditPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtStoredPassword;

@end
