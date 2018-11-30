#import "SignUpViewController.h"
#import "AppDelegate.h"

@interface SignUpViewController ()

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) UIView *overlayView;
@property (strong, nonatomic) NSMutableData *responseData;
@property (strong, nonatomic) AppDelegate *appDelegate;

@property (nonatomic) BOOL valid;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.valid = NO;
    
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

- (IBAction)buttonRegister:(id)sender {
    if (!self.valid) {
        CABasicAnimation *animation =
        [CABasicAnimation animationWithKeyPath:@"position"];
        [animation setDuration:0.05];
        [animation setRepeatCount:3];
        [animation setAutoreverses:YES];
        [animation setFromValue:[NSValue valueWithCGPoint:
                                 CGPointMake([self.button center].x - 10.0f, [self.button center].y)]];
        [animation setToValue:[NSValue valueWithCGPoint:
                               CGPointMake([self.button center].x + 10.0f, [self.button center].y)]];
        [[self.button layer] addAnimation:animation forKey:@"position"];
        return;
    }
    
    [self.view endEditing:YES];
    
    [self.activityIndicator startAnimating];
    self.overlayView.hidden = NO;
    
    @try {
        NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
        NSString *post = [[NSString alloc] initWithFormat:@"firstname=%@&lastname=%@&email=%@&password=%@&language=%@", [self.txtFirstname text], [self.txtLastname text], [self.txtEmail text], [self.txtPassword text], language];
        NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
        NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
        NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://ipower.tattoo/api/sign-up/?cache=", timestamp]]];
        [request setHTTPMethod:@"POST"];
        [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
        [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPBody:postData];
        
        [NSURLConnection connectionWithRequest:request delegate:self];
    }
    @catch (NSException *e) {
        [self.activityIndicator stopAnimating];
        self.overlayView.hidden = YES;
        
        [self.appDelegate showMessage:NSLocalizedString(@"connection_failed", @"Connenction failed. Please check your internet connection or try again later.") withTitle:@""];
    }
}

- (IBAction)editingChanged:(id)sender {
    BOOL valid = ([[self.txtFirstname text] length] > 0 && [[self.txtFirstname text] length] < 33) && ([[self.txtLastname text] length] > 0 && [[self.txtLastname text] length] < 33) && ([self validateEmail:[self.txtEmail text]]) && ([[self.txtPassword text] length] > 3 && [[self.txtPassword text] length] < 21);
    
    self.valid = valid;
}

- (IBAction)edittingDidEnd:(id)sender {
    UITextField *current = ((UITextField *)sender);
    
    if ([[self.txtFirstname text] length] > 0 && [[self.txtFirstname text] length] < 33) {
        self.txtFirstname.textColor = [UIColor blackColor];
    } else if (current == self.txtFirstname) {
        self.txtFirstname.textColor = [UIColor redColor];
    }
    
    if ([[self.txtLastname text] length] > 0 && [[self.txtLastname text] length] < 33) {
        self.txtLastname.textColor = [UIColor blackColor];
    } else if (current == self.txtLastname) {
        self.txtLastname.textColor = [UIColor redColor];
    }
    
    if ([self validateEmail:[self.txtEmail text]]) {
        self.txtEmail.textColor = [UIColor blackColor];
    } else if (current == self.txtEmail) {
        self.txtEmail.textColor = [UIColor redColor];
    }
    
    if ([[self.txtPassword text] length] > 3 && [[self.txtPassword text] length] < 21) {
        self.txtPassword.textColor = [UIColor blackColor];
    } else if (current == self.txtPassword) {
        self.txtPassword.textColor = [UIColor redColor];
    }
}

- (IBAction)edittingDidBegin:(id)sender {
    ((UITextField *)sender).textColor = [UIColor blackColor];
}

- (IBAction)backgroundTap:(id)sender {
    [self.view endEditing:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)validateEmail:(NSString *)candidate {
    NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:candidate];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.view endEditing:YES];
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int code = (int)[httpResponse statusCode];
    
    if (code >= 200 && code < 300) {
        self.responseData = [[NSMutableData alloc] init];
    } else {
        [self.appDelegate showMessage:NSLocalizedString(@"connection_failed", @"Connenction failed. Please check your internet connection or try again later.") withTitle:@""];
        
        [self.activityIndicator stopAnimating];
        self.overlayView.hidden = YES;
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
    [self.responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    BOOL success = NO;
    
    if (self.responseData) {
        NSString *responseData = [[NSString alloc]initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        success = [json[@"success"] intValue];
        
        if (!success) {
            [self.activityIndicator stopAnimating];
            self.overlayView.hidden = YES;
            
            if (json[@"error"]) {
                if (json[@"error"][@"firstname"]) {
                    [self.appDelegate showMessage:NSLocalizedString(@"error_firstname", @"First Name must be between 1 and 32 characters!") withTitle:@""];
                } else if (json[@"error"][@"lastname"]) {
                    [self.appDelegate showMessage:NSLocalizedString(@"error_lastname", @"Last Name must be between 1 and 32 characters!") withTitle:@""];
                } else if (json[@"error"][@"email"]) {
                    [self.appDelegate showMessage:NSLocalizedString(@"error_email", @"E-Mail Address does not appear to be valid!") withTitle:@""];
                } else if (json[@"error"][@"password"]) {
                    [self.appDelegate showMessage:NSLocalizedString(@"error_password", @"Password must be between 4 and 20 characters!") withTitle:@""];
                }
            } else {
                [self.appDelegate showMessage:NSLocalizedString(@"connection_failed", @"Connenction failed. Please check your internet connection or try again later.") withTitle:@""];
            }
        }
    }
    
    if (!success) {
        [self.appDelegate showMessage:NSLocalizedString(@"email_password_incorrect", @"Incorrect email or password.") withTitle:@""];
        
        [self.activityIndicator stopAnimating];
        self.overlayView.hidden = YES;
    } else {
        [self.appDelegate loggedData:[self.txtEmail text] withName:[NSString stringWithFormat:@"%@ %@", [self.txtFirstname text], [self.txtLastname text]]];
        [self.appDelegate loggedIn:SocialAccountTypeEmail];
        
        [self.appDelegate showMessage:NSLocalizedString(@"sign_up_success", @"Thanks for signing up on iPower Tattoo!") withTitle:@""];
    }
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    [self.appDelegate showMessage:NSLocalizedString(@"connection_failed", @"Connenction failed. Please check your internet connection or try again later.") withTitle:@""];
    
    [self.activityIndicator stopAnimating];
    self.overlayView.hidden = YES;
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
