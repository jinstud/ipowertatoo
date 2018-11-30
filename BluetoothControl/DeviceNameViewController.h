#import "ViewController.h"

@interface DeviceNameViewController : UIViewController<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtDeviceName;
- (IBAction)saveDeviceName:(id)sender;

@end
