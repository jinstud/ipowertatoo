#import "ModalViewController.h"

@interface LoginViewController : ModalViewController <UITextFieldDelegate, NSURLConnectionDelegate>

- (IBAction)buttonFacebook:(id)sender;
- (IBAction)buttonLogin:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIView *viewLine;
@property (weak, nonatomic) IBOutlet UILabel *lblOr;
@property (weak, nonatomic) IBOutlet UIButton *button;

@end
