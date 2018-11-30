#import "MenuViewController.h"
#import "PresetViewController.h"
#import "SessionBean.h"
#import "AppDelegate.h"

@interface MenuViewController ()

@property (strong, nonatomic) SessionBean *app;
@property (strong, nonatomic) NSArray *footType;
@property (strong, nonatomic) NSString *preset;

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.app = [SessionBean sharedSessionBean];
    self.footType = @[NSLocalizedString(@"footswitch_continuous", @"Continuous"), NSLocalizedString(@"footswitch_toggle", @"Toggle"), NSLocalizedString(@"footswitch_app_toggle", @"In-app Toggle")];
    
    self.tableView.allowsMultipleSelectionDuringEditing = NO;
    
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:(158/255.0) green:(158/255.0) blue:(158/255.0) alpha:1]];
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    NSInteger selectedFootType = [defaults integerForKey:@"FOOT"];
    self.footSwitch.textLabel.text = self.footType[selectedFootType];
    self.accountName.textLabel.text = [defaults stringForKey:kAccountNameKey];

    if (self.app.mDevice != nil) {
        self.deviceName.detailTextLabel.text = [defaults stringForKey:self.app.mDevice.identifier.UUIDString];

        if (![self.app.password isEqualToString:@"tattoo"]) {
            self.devicePassword.detailTextLabel.text = @"•••";
        } else {
            self.devicePassword.detailTextLabel.text = @"";
        }
    }
    
    [self.shortcutLiner.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"LINER-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    [self.shortcutShader.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"SHADER-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    
    [self.preset1.textLabel setText:[NSString stringWithFormat:@"1. %@", [defaults stringForKey:@"MACHINE1-NAME"]]];
    [self.preset1.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"MACHINE1-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    
    [self.preset2.textLabel setText:[NSString stringWithFormat:@"2. %@", [defaults stringForKey:@"MACHINE2-NAME"]]];
    [self.preset2.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"MACHINE2-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    
    [self.preset3.textLabel setText:[NSString stringWithFormat:@"3. %@", [defaults stringForKey:@"MACHINE3-NAME"]]];
    [self.preset3.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"MACHINE3-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    
    [self.preset4.textLabel setText:[NSString stringWithFormat:@"4. %@", [defaults stringForKey:@"MACHINE4-NAME"]]];
    [self.preset4.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"MACHINE4-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
    
    [self.preset5.textLabel setText:[NSString stringWithFormat:@"5. %@", [defaults stringForKey:@"MACHINE5-NAME"]]];
    [self.preset5.detailTextLabel setText:[NSString stringWithFormat:@"%4.01fv", ([defaults integerForKey:@"MACHINE5-VOLTS"] * ((self.app.Vmax - self.app.Vmin) / 127) + self.app.Vmin)]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    if (cell.selectedBackgroundView == nil) {
        cell.selectedBackgroundView = [UIView new];
    }
    
    [cell setTintColor:[UIColor lightGrayColor]];
    
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(89/255.0) green:(89/255.0) blue:(89/255.0) alpha:1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(89/255.0) green:(89/255.0) blue:(89/255.0) alpha:0];
        
        [UIView commitAnimations];
    });
    
    if (indexPath.section == 4 || indexPath.section == 3) {
        if (indexPath.section == 4) {
            self.preset = [NSString stringWithFormat:@"MACHINE%i", (int)indexPath.row + 1];
        } else {
            if (indexPath.row) {
                self.preset = @"SHADER";
            } else {
                self.preset = @"LINER";
            }
        }
        [self performSegueWithIdentifier:@"presetSegue" sender:self];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController respondsToSelector:@selector(setPreset:)]) {
        [segue.destinationViewController performSelector:@selector(setPreset:)
                                              withObject:self.preset];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return (indexPath.section == 2 && indexPath.row == 0); // Sign out
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate loggedOut];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return NSLocalizedString(@"sign_out", @"Sign out");
}

-  (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewCellEditingStyleDelete;
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
