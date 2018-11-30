#import "ModalViewController.h"

@interface ResetPasswordViewController : ModalViewController<UITextFieldDelegate, NSURLConnectionDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)resetPassword:(id)sender;

@end
