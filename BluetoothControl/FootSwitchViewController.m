#import "FootSwitchViewController.h"
#import "BLE.h"

@interface FootSwitchViewController ()

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) NSArray *footType;
@property NSInteger selectedFootType;

@end

@implementation FootSwitchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.ble = [BLE sharedBLE];
    //self.footType = @[NSLocalizedString(@"footswitch_continuous", @"Continuous"), NSLocalizedString(@"footswitch_toggle", @"Toggle"), NSLocalizedString(@"footswitch_app_toggle", @"In-app Toggle")];
    self.footType = @[NSLocalizedString(@"footswitch_continuous", @"Continuous"), NSLocalizedString(@"footswitch_toggle", @"Toggle")];
    self.selectedFootType = [[NSUserDefaults standardUserDefaults] integerForKey:@"FOOT"];
    
    [[[self navigationController] navigationBar] setTintColor:[UIColor colorWithRed:(158/255.0) green:(158/255.0) blue:(158/255.0) alpha:1]];
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *oldIndex = [tableView indexPathForSelectedRow];
    [tableView cellForRowAtIndexPath:oldIndex].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    return indexPath;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedFootType = indexPath.row;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setInteger:indexPath.row forKey:@"FOOT"];
    [defaults synchronize];
    
    UInt8 buf[3] = {0x03, 0x00, 0x55};
    
    if (indexPath.row == 1) {
        buf[0]=0x53;
    } else if (indexPath.row == 2) {
        buf[0]=0x73;
    } else {
        buf[0]=0x13;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    
    if (cell.selectedBackgroundView == nil) {
        cell.selectedBackgroundView = [UIView new];
    }
    
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(89/255.0) green:(89/255.0) blue:(89/255.0) alpha:1];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.3];
        
        cell.selectedBackgroundView.backgroundColor = [UIColor colorWithRed:(89/255.0) green:(89/255.0) blue:(89/255.0) alpha:0];
        
        [UIView commitAnimations];
    });
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    //[cell setAccessoryType:UITableViewCellAccessoryNone];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.footType.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"select_footswitch_mode", @"Select footswitch mode");
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"footSwitchTypeCell" forIndexPath:indexPath];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"footSwitchTypeCell"];
        cell.backgroundColor = [UIColor colorWithRed:(20/255.0) green:(20/255.0) blue:(20/255.0) alpha:1];
        cell.textLabel.textColor = [UIColor lightGrayColor];
    }
    
    cell.textLabel.text = [self.footType objectAtIndex:indexPath.row];
    
    if (self.selectedFootType == indexPath.row) {
        [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
    } else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    [cell setTintColor:[UIColor lightGrayColor]];
    
    return cell;
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
