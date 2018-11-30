#import "DevicePasswordViewController.h"
#import "SessionBean.h"

@interface DevicePasswordViewController ()

@property (strong, nonatomic) SessionBean *app;

@end

@implementation DevicePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.app = [SessionBean sharedSessionBean];
    
    self.btnEditPassword.enabled = (self.app.mDevice != nil);
    self.txtStoredPassword.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults stringForKey:@"pswd"] isEqualToString:@"tattoo"]) {
        self.txtStoredPassword.text = @"";
    } else {
        self.txtStoredPassword.text = [defaults stringForKey:@"pswd"];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.txtStoredPassword becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.txtStoredPassword resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[self resetPassword:nil]; button action
    return YES;
}

- (IBAction)savePassword:(id)sender {
    if (self.txtStoredPassword.text.length > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_length", @"Password length must be less than 15 characters long.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (self.txtStoredPassword.text.length) {
            [defaults setObject:self.txtStoredPassword.text forKey:@"pswd"];
            self.app.password = self.txtStoredPassword.text;
        } else {
            [defaults setObject:@"tattoo" forKey:@"pswd"];
            self.app.password = @"tattoo";
        }
        [defaults synchronize];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_password_saved", @"iPower device password saved successfully.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
