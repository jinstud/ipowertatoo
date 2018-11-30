#import "DeviceChangePasswordViewController.h"
#import "SessionBean.h"

@interface DeviceChangePasswordViewController ()

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) UIView *overlayView;

@property (strong, nonatomic) BLE *ble;

@property (nonatomic,strong) NSTimer *currentPasswordTimer;
@property (nonatomic,strong) NSTimer *passwordTimer;

@end

@implementation DeviceChangePasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if ([[defaults stringForKey:@"pswd"] isEqualToString:@"tattoo"]) {
        self.viewChangePassword.hidden = YES;
        self.viewSetPassword.hidden = NO;
    } else {
        self.viewSetPassword.hidden = YES;
        self.viewChangePassword.hidden = NO;
    }
    
    self.ble = [BLE sharedBLE];
    self.ble.delegate = self;
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayView.tag = 77;
    self.overlayView.hidden = YES;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.navigationController.view addSubview:self.overlayView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (IBAction)setPassword:(id)sender {
    NSString *password;
    NSString *passwordConfirm;
    
    if (self.viewChangePassword.hidden) {
        password = self.txtPassword.text;
        passwordConfirm = self.txtConfirmPassword.text;
    } else {
        password = self.txtNewPassword.text;
        passwordConfirm = self.txtConfirmNewPassword.text;
    }
    
    if (!self.viewChangePassword.hidden && !self.txtCurrentPassowrd.text.length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_current", @"Please provide current iPower device password.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
        [self.txtCurrentPassowrd becomeFirstResponder];
    } else if (!password.length || password.length > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_length_min", @"Password length must be between 1 and 15 characters long.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
        if (self.viewChangePassword.hidden) {
            [self.txtPassword becomeFirstResponder];
        } else {
            [self.txtNewPassword becomeFirstResponder];
        }
    } else if(![password isEqualToString:passwordConfirm]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_match", @"Password does not match the confirm password.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
        if (self.viewChangePassword.hidden) {
            [self.txtConfirmPassword becomeFirstResponder];
        } else {
            [self.txtConfirmNewPassword becomeFirstResponder];
        }
    } else{
        [self sendCurrentPassword];
    }
}

- (void)sendCurrentPassword {
    [self.activityIndicator startAnimating];
    self.overlayView.hidden = NO;
    
    UInt8 buf[3] = {0x09, 0x00 , 0x00};
    int r = arc4random_uniform(256);
    
    SessionBean *app = [SessionBean sharedSessionBean];
    app.numIdTrasm = r;
    
    NSString *currentPassword;
    if (self.viewChangePassword.hidden) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        currentPassword = [defaults stringForKey:@"pswd"];
    } else {
        currentPassword = self.txtCurrentPassowrd.text;
    }
    
    buf[0] = 0x09;
    buf[1] = currentPassword.length;
    buf[2] = app.numIdTrasm;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    
    [NSThread sleepForTimeInterval:0.2];
    
    [self.ble write:data];
    
    for (int i = 0; i < currentPassword.length; i++) {
        [NSThread sleepForTimeInterval:0.2];
        buf[0] = (((i+1)<<4)+9);
        buf[1] = [currentPassword characterAtIndex:i];

        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
    
    self.currentPasswordTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(endPasswordCheck) userInfo:nil repeats:NO];
}

- (void)endPasswordCheck {
    [self.activityIndicator stopAnimating];
    self.overlayView.hidden = YES;
    
    self.overlayView.hidden = NO;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"no_confirm_password_received", @"Password change confirmation was not received from iPower device.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alert show];
}

- (void)bleDidReceiveData:(unsigned char *)data length:(int)length {
    SessionBean *app = [SessionBean sharedSessionBean];
    for (int i = 0; i < length; i+=3) {
        if (data[i] == 0x0A) {
            if (data[i + 2] == app.numIdTrasm) {
                [self.currentPasswordTimer invalidate];
                if (data[i + 1] == app.CONFERMA) {
                    [self setDevicePassword];
                } else {
                    [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
                    [self.activityIndicator stopAnimating];
                    self.overlayView.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_incorrect", @"Incorrect iPower device password.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        } else if (data[i] == 0x0C) {
            if (data[i + 2] == app.numIdTrasm) {
                if (data[i + 1] == app.CONFERMA) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    if (self.viewChangePassword.hidden) {
                        [defaults setObject:self.txtPassword.text forKey:@"pswd"];
                    } else {
                        [defaults setObject:self.txtNewPassword.text forKey:@"pswd"];
                    }
                    [defaults synchronize];
                    [self.activityIndicator stopAnimating];
                    self.overlayView.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_password_changed", @"iPower device password changed successfully.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                    [self dismissViewControllerAnimated:YES completion:nil];
                } else {
                    [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
                    [self.activityIndicator stopAnimating];
                    self.overlayView.hidden = YES;
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"old_password_incorrect", @"Incorrect iPower device current password. New password was not applied.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
                [self.passwordTimer invalidate];
            }
        }
    }
}

- (void)setDevicePassword {
    UInt8 buf[3] = {0x00, 0x00 , 0x00};
    int r = arc4random_uniform(256);
    SessionBean *app = [SessionBean sharedSessionBean];
    app.numIdTrasm = r;
    
    NSString *newPassword;
    if (self.viewChangePassword.hidden) {
        newPassword = self.txtPassword.text;
    } else {
        newPassword = self.txtNewPassword.text;
    }
    
    buf[0] = 0x0D;
    buf[1] = newPassword.length;
    buf[2] = app.numIdTrasm;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    
    [NSThread sleepForTimeInterval:0.2];
    
    [self.ble write:data];
    
    for (int i = 0; i < newPassword.length; i++) {
        [NSThread sleepForTimeInterval:0.2];
        buf[0] = (((i+1)<<4)+13);
        buf[1] = [newPassword characterAtIndex:i];
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
    
    self.passwordTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(endNewPasswordCheck) userInfo:nil repeats:NO];
}

- (void)endNewPasswordCheck {
    [self.activityIndicator stopAnimating];
    self.overlayView.hidden = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"no_confirm_password_received", @"Password change confirmation was not received from iPower device.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alert show];
}

-(void) bleDidConnect {}
-(void) bleDidDisconnect {}
-(void) bleDidDisconnect:(NSError *)error {}
-(void) bleDidUpdateRSSI:(NSNumber *)rssi {}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
