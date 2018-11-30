#import "DeviceNameViewController.h"
#import "SessionBean.h"

@interface DeviceNameViewController ()

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) SessionBean *app;

@end

@implementation DeviceNameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.ble = [BLE sharedBLE];
    self.app = [SessionBean sharedSessionBean];
    
    self.txtDeviceName.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.app.mDevice != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        self.txtDeviceName.text = [defaults stringForKey:self.app.mDevice.identifier.UUIDString];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.txtDeviceName becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.txtDeviceName resignFirstResponder];
}

- (IBAction)saveDeviceName:(id)sender {
    if (self.app.mDevice != nil) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        if (self.txtDeviceName.text.length) {
            [defaults setObject:self.txtDeviceName.text forKey:self.app.mDevice.identifier.UUIDString];
        } else {
            [defaults removeObjectForKey:self.app.mDevice.identifier.UUIDString];
        }
        [defaults synchronize];
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_name_not_connected", @"You must be connected to the device to change it's name.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self saveDeviceName:nil];
    return YES;
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
