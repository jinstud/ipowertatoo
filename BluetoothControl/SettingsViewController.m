//
//  SettingsViewController.m
//  BluetoothControl
//
//  Created by Andrea Valle on 03/11/14.
//  Copyright (c) 2014 Andrea. All rights reserved.
//

#import "SettingsViewController.h"
#import "DBManager.h"
#import "SessionBean.h"
#import "Marca.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface SettingsViewController ()

@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) IBOutlet UIView *popupNewMarca;
@property(nonatomic, strong) IBOutlet UIView *popupSelMarca;

@property(nonatomic, strong) IBOutlet UITextField *txtMarca;
@property(nonatomic, strong) IBOutlet UIPickerView *pickerVolt;
@property(nonatomic, strong) IBOutlet UILabel *voltnew;

@property(nonatomic, strong) NSMutableArray *marche;
@property(nonatomic, strong) NSMutableArray *volts;
@property(nonatomic, strong) NSString *selectedEntry;

@property(nonatomic, strong) UIButton *buttonChoose;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[self navigationController] setNavigationBarHidden:NO animated:YES];
    
    DBManager *dbManager = [DBManager getSharedInstance];
    
    _marche = [dbManager getAllMarche];
    
    _volts = [[NSMutableArray alloc] init];
    
    SessionBean *myApp = [SessionBean sharedSessionBean];
    
    float pas=(myApp.Vmax-myApp.Vmin)/(float)127;
    
    for (int i = 0; i<=127; i++) {
        [_volts  addObject:[NSString stringWithFormat:@"%@ V",[NSString stringWithFormat:@"%.2f",myApp.Vmin+pas*(float)i]]];
    }
    
    _selectedEntry = [_volts objectAtIndex:0];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    //NSLog(@"viewWillDisappear");
    if ([self.navigationController.viewControllers indexOfObject:self]==NSNotFound) {
        // back button was pressed.  We know this is true because self is no longer
        // in the navigation stack.
        //NSLog(@"viewWillDisappear1");
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:2] animated:NO];
    } else{
         UIViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"Settings"];
        [self.view addSubview:svc.view];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadMarche{
    DBManager *dbManager = [DBManager getSharedInstance];
    
    [_marche removeAllObjects];
    [self.tableView reloadData];
    
    _marche = [dbManager getAllMarche];
    
    //NSLog(@"_marche count %lu", (unsigned long)[_marche count]);
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section

{
    
    return [_marche count];
    
}

//- (UITableViewCell *)tableView:(UITableView *)tableView :(NSIndexPath *)indexPath
//
//{
//    //NSLog(@"isEqualToString");
//    static NSString *simpleTableIdentifier = @"SimpleTableItem";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
//    //NSLog(@"isEqualToString");
//    if (cell == nil) {
//        
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
//        
//    }
//    //NSLog(@"isEqualToString");
//    cell.textLabel.text = [_marche objectAtIndex:indexPath.row];
//    //NSLog(@"isEqualToString");
//    return cell;
//    
//}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    static NSString *simpleTableIdentifier = @"SimpleTableItem";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
   
    if (cell == nil) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:simpleTableIdentifier];
        
    }
    
    Marca *marca = (Marca*)[_marche objectAtIndex:indexPath.row];
    if (marca.marca.length >15 && !IS_IPAD ) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@...",[marca.marca substringToIndex:15]];
    } else if(marca.marca.length >50 && IS_IPAD ){
        cell.textLabel.text = [NSString stringWithFormat:@"%@...",[marca.marca substringToIndex:50]];
    } else{
        cell.textLabel.text = marca.marca;
    }
    
        UIButton *buttonLs = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        //set the position of the button
        buttonLs.frame = CGRectMake(cell.frame.size.width - 100, cell.frame.origin.y + cell.frame.size.height/2 -15, 40, 30);
        if (marca.ls != nil) {
            [buttonLs setTitle:marca.ls forState:UIControlStateNormal];
        } else{
            [buttonLs setTitle:@"L1" forState:UIControlStateNormal];
        }
        
        buttonLs.tag = indexPath.row;
        [buttonLs addTarget:self action:@selector(changeLs:) forControlEvents:UIControlEventTouchUpInside];
        [buttonLs setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
//        [cell.contentView addSubview:buttonLs];
    
        UIButton *buttonSt = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        
        //set the position of the button
    if (IS_IPAD) {
        buttonSt.frame = CGRectMake(700, cell.frame.origin.y + cell.frame.size.height/2 -15, 40, 30);
    } else{
        buttonSt.frame = CGRectMake(cell.frame.size.width - 50, cell.frame.origin.y + cell.frame.size.height/2 -15, 40, 30);
    }
    
        if (marca.stazione != nil) {
            [buttonSt setTitle:marca.stazione forState:UIControlStateNormal];
        } else{
            [buttonSt setTitle:@"" forState:UIControlStateNormal];
        }
        
        buttonSt.tag = indexPath.row;
        [buttonSt addTarget:self action:@selector(changeSt:) forControlEvents:UIControlEventTouchUpInside];
        [buttonSt setBackgroundColor:[UIColor colorWithRed:0 green:0 blue:1 alpha:1]];
        [cell.contentView addSubview:buttonSt];
    
    UILabel *voltLbl;
    if (IS_IPAD) {
        voltLbl = [[UILabel alloc] initWithFrame:CGRectMake(600, cell.frame.origin.y + cell.frame.size.height/2 -15, 80, 30)];
    } else{
        voltLbl = [[UILabel alloc] initWithFrame:CGRectMake(cell.frame.size.width - 150, cell.frame.origin.y + cell.frame.size.height/2 -15, 80, 30)];
    }
    
    if (marca.volt != 0) {
        voltLbl.text = [NSString stringWithFormat:@"%0.2f",marca.volt];
    } else{
        voltLbl.text = _selectedEntry;
    }
    
    [cell.contentView addSubview:voltLbl];
    
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    
    return cell;
}

-(void)changeLs:(id)sender{
    //NSLog(@"changeLs");
    UIButton *btn = (UIButton*)sender;
    if ([[btn currentTitle] isEqualToString:@"L1"]) {
        [btn setTitle:@"L2" forState:UIControlStateNormal];
    } else{
        [btn setTitle:@"L1" forState:UIControlStateNormal];
    }
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca =[_marche objectAtIndex:btn.tag];
    //NSLog(@"marca %@", marca.marca);
    [dbManager updateMarca:marca.marca andLs:[btn currentTitle]];
    
}

-(void)changeSt:(id)sender{
    //NSLog(@"changeSt");
    _buttonChoose = (UIButton*)sender;
    _popupSelMarca.hidden = NO;
}

-(IBAction)choseStazione1:(id)sender{
    [_buttonChoose setTitle:@"1" forState:UIControlStateNormal];
    _popupSelMarca.hidden = YES;
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca =[_marche objectAtIndex:_buttonChoose.tag];
    //NSLog(@"marca %@", marca.marca);
    
    for (int i = 0; i <_marche.count ; i++) {
        Marca *marca = [_marche objectAtIndex:i];
        if ([marca.stazione isEqualToString:@"1"]) {
            [dbManager updateMarca:marca.marca andStazione:@""];
        }
    }
    
    [dbManager updateMarca:marca.marca andStazione:@"1"];
    
    SettingsViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self.navigationController pushViewController:svc animated:NO];
}
-(IBAction)choseStazione2:(id)sender{
    [_buttonChoose setTitle:@"2" forState:UIControlStateNormal];
    _popupSelMarca.hidden = YES;
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca =[_marche objectAtIndex:_buttonChoose.tag];
    //NSLog(@"marca %@", marca.marca);
    
    for (int i = 0; i <_marche.count ; i++) {
        Marca *marca = [_marche objectAtIndex:i];
        if ([marca.stazione isEqualToString:@"2"]) {
            [dbManager updateMarca:marca.marca andStazione:@""];
        }
    }
    
    [dbManager updateMarca:marca.marca andStazione:@"2"];
    
    SettingsViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self.navigationController pushViewController:svc animated:NO];
}

-(IBAction)choseStazione3:(id)sender{
    [_buttonChoose setTitle:@"3" forState:UIControlStateNormal];
    _popupSelMarca.hidden = YES;
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca =[_marche objectAtIndex:_buttonChoose.tag];
    //NSLog(@"marca %@", marca.marca);
    
    for (int i = 0; i <_marche.count ; i++) {
        Marca *marca = [_marche objectAtIndex:i];
        if ([marca.stazione isEqualToString:@"3"]) {
            [dbManager updateMarca:marca.marca andStazione:@""];
        }
    }
    
    [dbManager updateMarca:marca.marca andStazione:@"3"];
    
    SettingsViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self.navigationController pushViewController:svc animated:NO];
    
}

-(IBAction)choseStazione4:(id)sender{
    [_buttonChoose setTitle:@"4" forState:UIControlStateNormal];
    _popupSelMarca.hidden = YES;
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca =[_marche objectAtIndex:_buttonChoose.tag];
    //NSLog(@"marca %@", marca.marca);
    
    for (int i = 0; i <_marche.count ; i++) {
        Marca *marca = [_marche objectAtIndex:i];
        if ([marca.stazione isEqualToString:@"4"]) {
            [dbManager updateMarca:marca.marca andStazione:@""];
        }
    }
    
    [dbManager updateMarca:marca.marca andStazione:@"4"];
    
    SettingsViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self.navigationController pushViewController:svc animated:NO];
}
-(IBAction)choseStazione5:(id)sender{
    [_buttonChoose setTitle:@"5" forState:UIControlStateNormal];
    _popupSelMarca.hidden = YES;
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca =[_marche objectAtIndex:_buttonChoose.tag];
    //NSLog(@"marca %@", marca.marca);
    
    for (int i = 0; i <_marche.count ; i++) {
        Marca *marca = [_marche objectAtIndex:i];
        if ([marca.stazione isEqualToString:@"5"]) {
            [dbManager updateMarca:marca.marca andStazione:@""];
        }
    }
    
    [dbManager updateMarca:marca.marca andStazione:@"5"];
    
    SettingsViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    
    [self.navigationController pushViewController:svc animated:NO];
}


-(IBAction)hidePopupSelMarca{
    _popupSelMarca.hidden = YES;
}

-(void) tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    DBManager *dbManager = [DBManager getSharedInstance];
    Marca *marca = (Marca*)[_marche objectAtIndex:indexPath.row];
    [dbManager deleteMarca:marca.marca];
    
    [_marche removeObjectAtIndex:indexPath.row];
    
    
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath

{
    
    
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Alert" message:[NSString stringWithFormat:@"Selected Value is %@",[tableData objectAtIndex:indexPath.row]] delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
//    
//    [alertView show];
    
}

-(IBAction) addMarca{
    _popupNewMarca.hidden = NO;
  
}

-(IBAction)closeNewMarca:(id)sender{
    _popupNewMarca.hidden = YES;
}

-(IBAction) restore{
    
    [self.view endEditing:YES];
}

-(IBAction)conferma:(id)sender{
    if(_txtMarca.text.length==0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[NSBundle mainBundle] localizedStringForKey:@"enter_brand" value:@"Inserire il nome della marca" table:nil] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    } else{
        DBManager *dbManager = [DBManager getSharedInstance];
        [dbManager insertMarca:_txtMarca.text andVolt:_selectedEntry andLs:@"L1" andStazione:@""];
        
         _popupNewMarca.hidden = YES;
        
        SettingsViewController* svc =[self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
        
        [self.navigationController pushViewController:svc animated:NO];
    }
}

-(IBAction)cancel:(id)sender{
    _txtMarca.text = @"";
    [_pickerVolt selectRow:0 inComponent:0 animated:YES];
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:
(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView
numberOfRowsInComponent:(NSInteger)component
{
    return _volts.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return _volts[row];
}

- (NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *title = _volts[row];
    NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    return attString;
    
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    _selectedEntry = [_volts objectAtIndex:row];
    //NSLog(@"_selectedEntry %@", _selectedEntry);
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
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
