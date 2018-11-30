#import "WelcomeViewController.h"
#import "AppDelegate.h"

@interface WelcomeViewController ()

@property (strong, nonatomic) IBOutlet UIView *logoView;
@property (weak, nonatomic) IBOutlet UIButton *facebook;
@property (weak, nonatomic) IBOutlet UIButton *signUp;
@property (weak, nonatomic) IBOutlet UIView *login;

@end

@implementation WelcomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[self navigationController] setNavigationBarHidden:YES];
    
    self.facebook.alpha = 0;
    self.facebook.hidden = NO;
    self.signUp.alpha = 0;
    self.signUp.hidden = NO;
    self.login.alpha = 0;
    self.login.hidden = NO;
    
    CGPoint point = self.logoView.center;
    
    self.logoView.center = CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2);
    
    [UIView animateWithDuration:0.3f delay:0.3f options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.logoView.center = point;
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.5f animations:^{
            self.facebook.alpha = 1;
            self.signUp.alpha = 1;
            self.login.alpha = 1;
        }];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonFacebook:(id)sender {
    AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate facebook];
}

- (BOOL)prefersStatusBarHidden {
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
