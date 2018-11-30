#import "ResetPasswordViewController.h"
#import "AppDelegate.h"

@interface ResetPasswordViewController ()

@property(nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property(nonatomic, strong) UIView *overlayView;

@property (strong, nonatomic) NSMutableData *responseData;

@property (strong, nonatomic) AppDelegate *appDelegate;

@end

@implementation ResetPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    self.txtEmail.delegate = self;
    
    self.overlayView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.overlayView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.overlayView.tag = 77;
    self.overlayView.hidden = YES;
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicator.center = self.overlayView.center;
    [self.overlayView addSubview:self.activityIndicator];
    [self.navigationController.view addSubview:self.overlayView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.txtEmail becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.txtEmail resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    //[self resetPassword:nil]; button action
    return YES;
}

- (IBAction)resetPassword:(id)sender {
    
    @try {
        if (![[self.txtEmail text] length]) {
            [self shake];
        } else {
            [self.view endEditing:YES];
            
            [self.activityIndicator startAnimating];
            self.overlayView.hidden = NO;
            
            NSString *post = [[NSString alloc] initWithFormat:@"email=%@", [self.txtEmail text]];
            NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
            NSData *postData = [post dataUsingEncoding:NSUTF8StringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://ipower.tattoo/api/reset/?cache=", timestamp]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [request setValue:@"application/x-www-form-urlencoded charset=utf-8" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            [NSURLConnection connectionWithRequest:request delegate:self];
        }
    }
    @catch (NSException *e) {
        [self.activityIndicator stopAnimating];
        self.overlayView.hidden = YES;
        
        [self.appDelegate showMessage:NSLocalizedString(@"connection_failed", @"Connenction failed. Please check your internet connection or try again later.") withTitle:@""];
    }
}

- (void)shake {
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
    BOOL not_found = NO;
    
    if (self.responseData) {
        NSString *responseData = [[NSString alloc]initWithData:self.responseData encoding:NSUTF8StringEncoding];
        
        NSError *error = nil;
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[responseData dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
        
        success = [[json objectForKey:@"success"] boolValue];
        not_found = [[json objectForKey:@"not_found"] boolValue];
    }
    
    if (not_found) {
        [self.appDelegate showMessage:NSLocalizedString(@"email_incorrect_or_not_found", @"Account with provided email is not found.") withTitle:@""];
    } else if (success) {
        [self.appDelegate showMessage:NSLocalizedString(@"reset_instructions", @"An email with reset password instructions is sent to your email address.") withTitle:@""];
        
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.appDelegate showMessage:NSLocalizedString(@"connection_failed", @"Connenction failed. Please check your internet connection or try again later.") withTitle:@""];
    }
    
    [self.activityIndicator stopAnimating];
    self.overlayView.hidden = YES;
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