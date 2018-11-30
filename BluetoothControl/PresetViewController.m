#import "PresetViewController.h"
#import "SessionBean.h"

@interface PresetViewController ()

@property (strong, nonatomic) SessionBean *app;
@property (strong, nonatomic) NSString *preset;
@property (strong, nonatomic) NSUserDefaults *defaults;

@end

@implementation PresetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.app = [SessionBean sharedSessionBean];
    self.defaults = [NSUserDefaults standardUserDefaults];
    
    long volts = [self.defaults integerForKey:[NSString stringWithFormat:@"%@-VOLTS", self.preset]];
    
    if (volts > 127) {
        volts = 127;
    } else if (volts < 0) {
        volts = 0;
    }
    
    [self.sliderVolts setValue:volts];
    [self.txtVolts setText:[NSString stringWithFormat:@"%4.01f", ((int)volts * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    [self.txtName setUserInteractionEnabled:NO];
    [self.txtVolts setUserInteractionEnabled:NO];
    
    if ([self.preset isEqualToString:@"LINER"]) {
        [self.txtName setText:@"Liner"];
    } else if ([self.preset isEqualToString:@"SHADER"]) {
        [self.txtName setText:@"Shader"];
    } else {
        NSString *name = [self.defaults stringForKey:[NSString stringWithFormat:@"%@-NAME", self.preset]];
        [self.txtName setText:name];
        [self.txtName setUserInteractionEnabled:YES];
        
        [self.navigationItem setTitle:@"Preset"];
    }
    
    self.txtName.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.txtName becomeFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)sliderValueChanged:(UISlider *)sender {
    [self.txtVolts setText:[NSString stringWithFormat:@"%4.01f", ((int)sender.value * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
}

- (IBAction)txtVoltsEditingDidEnd:(UITextField *)sender {
    if ([sender.text floatValue] > self.app.Vmax) {
        [sender setText:[NSString stringWithFormat:@"%4.01f", self.app.Vmax]];
    } else if ([sender.text floatValue] < self.app.Vmin) {
        [sender setText:[NSString stringWithFormat:@"%4.01f", self.app.Vmin]];
    }
    
    [self.sliderVolts setValue:[sender.text floatValue] animated:YES];
}

- (IBAction)savePreset:(id)sender {
    if (!self.txtName.text.length) {
        [self.txtName becomeFirstResponder];
        
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:3];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self.buttonSave center].x - 10.0f, [self.buttonSave center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self.buttonSave center].x + 10.0f, [self.buttonSave center].y)]];
        [[self.buttonSave layer] addAnimation:animation forKey:@"position"];
        return;
    }
    
    [self.defaults setInteger:(int)self.sliderVolts.value forKey:[NSString stringWithFormat:@"%@-VOLTS", self.preset]];
    [self.defaults setObject:self.txtName.text forKey:[NSString stringWithFormat:@"%@-NAME", self.preset]];
    [self.defaults synchronize];
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSRange lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    
    if (lowercaseCharRange.location != NSNotFound) {
        textField.text = [textField.text stringByReplacingCharactersInRange:range
                                                                 withString:[string uppercaseString]];
        return NO;
    }
    
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
