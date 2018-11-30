#import "ModalViewController.h"

@interface SignUpViewController : ModalViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *txtFirstname;
@property (weak, nonatomic) IBOutlet UITextField *txtLastname;
@property (weak, nonatomic) IBOutlet UITextField *txtEmail;
@property (weak, nonatomic) IBOutlet UITextField *txtPassword;
@property (weak, nonatomic) IBOutlet UIButton *button;

- (IBAction)buttonRegister:(id)sender;
- (IBAction)editingChanged:(id)sender;
- (IBAction)edittingDidEnd:(id)sender;
- (IBAction)edittingDidBegin:(id)sender;

@end
