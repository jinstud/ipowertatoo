//
//  PasswordVC.m
//  BluetoothControl
//
//  Created by Andrea Valle on 04/11/14.
//  Copyright (c) 2014 Andrea. All rights reserved.
//

#include <stdlib.h>

#import "PasswordVC.h"
#import "SessionBean.h"
#import "DBManager.h"

@interface PasswordVC ()

@property (strong, nonatomic) BLE *ble;

@property (nonatomic) BOOL attesa_convalida_pswd_attuale;
@property (nonatomic) BOOL attesa_convalida_pswd_nuova;
@property (nonatomic,strong) NSTimer *mTimerAttuale;
@property (nonatomic,strong) NSTimer *mTimerNuova;

@property (nonatomic, strong) IBOutlet UIView *setPasswordView;
@property (nonatomic, strong) IBOutlet UITextField *lblPassword;

@property (nonatomic, strong) IBOutlet UIView *changePasswordView;
@property (nonatomic, strong) IBOutlet UITextField *lblCurrentPassword;
@property (nonatomic, strong) IBOutlet UITextField *lblNewPassword;
@property (nonatomic, strong) IBOutlet UITextField *lblConfirmNewPassword;

@property (nonatomic, strong) IBOutlet UIView *changeNameView;
@property (nonatomic, strong) IBOutlet UITextField *lblPasswordChangeName;

@end

@implementation PasswordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.ble = [BLE sharedBLE];
    self.ble.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)setPassword:(id)sender {
    self.setPasswordView.hidden = NO;
}

-(IBAction)changePassword:(id)sender {
    self.changePasswordView.hidden = NO;
}

-(IBAction)changeName:(id)sender {
    self.changeNameView.hidden = NO;
}

-(IBAction)closePasswordView:(id)sender {
    self.setPasswordView.hidden = YES;
}

-(IBAction)closeChangePasswordView:(id)sender {
    self.changePasswordView.hidden = YES;
}

-(IBAction)closeChangeNameView:(id)sender {
    self.changeNameView.hidden = YES;
}

-(IBAction)confirmSetPassword:(id)sender {
    if (!self.lblPassword.text.length || self.lblPassword.text.length > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_length", @"Password length must be between 1 and 15 characters long.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    } else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.lblPassword.text forKey:@"pswd"];
        SessionBean *myApp = [SessionBean sharedSessionBean];
        myApp.password = self.lblPassword.text;
        [defaults synchronize];
        self.setPasswordView.hidden = YES;
    }
    
    /*else if([self.lblPassword.text containsString:@"£"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[NSBundle mainBundle] localizedStringForKey:@"character_not_avalaible" value:@"The character £ is not avalaible" table:nil] delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    }*/
}

-(IBAction)confirmChangePassword:(id)sender {
    if (!self.lblCurrentPassword.text.length || self.lblCurrentPassword.text.length > 15 ||
        !self.lblNewPassword.text.length || self.lblNewPassword.text.length > 15 ||
        !self.lblConfirmNewPassword.text.length || self.lblConfirmNewPassword.text.length > 15) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_length", @"Password length must be between 1 and 15 characters long.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    } else if(![self.lblNewPassword.text isEqualToString:self.lblConfirmNewPassword.text]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_match", @"Password does not match the confirm password.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    } else{
        [self trasmettiPasswordAttuale];
    }
    
    /*else if ([_lblCurrentPassword.text containsString:@"£"]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[[NSBundle mainBundle] localizedStringForKey:@"character_not_avalaible" value:@"The character £ is not avalaible" table:nil] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }*/
}

-(IBAction)confirmChangeName:(id)sender {
    if (!self.lblPasswordChangeName.text.length) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"enter_device_name", @"Device name cannot be empty.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
        [alert show];
    } else {
        SessionBean *myApp = [SessionBean sharedSessionBean];
        if (myApp.mDevice != nil) {
            DBManager *db = [DBManager getSharedInstance];
            [db saveNomeDevice:self.lblPasswordChangeName.text];
            self.changeNameView.hidden = YES;
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_name_not_connected", @"You must be connected to the device to change name.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

-(void)stopAttesaConvalida {
     _attesa_convalida_pswd_attuale = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"no_confirm_password_received", @"No password confirmation received.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alert show];
}

-(void)trasmettiPasswordAttuale {
    UInt8 buf[3] = {0x09, 0x00 , 0x00};
    int r = arc4random_uniform(256);
    
    SessionBean *myApp = [SessionBean sharedSessionBean];
    myApp.numIdTrasm = r;// numero identificativo trasmissione
    
    
    buf[0] = 0x09;
    buf[1] = self.lblCurrentPassword.text.length; //	trasmissione numero caratteri password (max=15)
    buf[2] = myApp.numIdTrasm;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    
    [NSThread sleepForTimeInterval:0.2];
    
    [self.ble write:data];
    
    int i;
    
    for (i = 0; i < self.lblCurrentPassword.text.length; i++) {
        [NSThread sleepForTimeInterval:0.2];
        buf[0] = (((i+1)<<4)+9);	//	codice trasmissione password e numero pacchetto
        buf[1] = [self.lblCurrentPassword.text characterAtIndex:i];	//	trasmissione carattere password
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
    
    self.attesa_convalida_pswd_attuale = YES;
    
    self.mTimerAttuale = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopAttesaConvalida) userInfo:nil repeats:NO];
}

-(void)stopAttesaNuova {
    self.attesa_convalida_pswd_nuova = YES;
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Attention" message:NSLocalizedString(@"no_confirm_password_received", @"No password confirmation received.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
    [alert show];
}

-(void)trasmettiPasswordNuova{
    UInt8 buf[3] = {0x00, 0x00 , 0x00};
    int r = arc4random_uniform(256);
    SessionBean *myApp = [SessionBean sharedSessionBean];
    myApp.numIdTrasm = r;// numero identificativo trasmissione
    
    buf[0] = 0x0D;
    buf[1] = self.lblNewPassword.text.length;	//	trasmissione numero caratteri password (max=15)
    buf[2] = myApp.numIdTrasm;
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    
    [NSThread sleepForTimeInterval:0.2];
    
    [self.ble write:data];
    
    int i;
    
    for (i = 0; i < self.lblNewPassword.text.length; i++) {
        [NSThread sleepForTimeInterval:0.2];
        buf[0] = (((i+1)<<4)+13);	//	codice trasmissione password e numero pacchetto
        buf[1] = [self.lblNewPassword.text characterAtIndex:i];	//	trasmissione carattere password
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }

    self.attesa_convalida_pswd_nuova = YES;
    
    self.mTimerNuova = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(stopAttesaNuova) userInfo:nil repeats:NO];
}

// When data is comming, this will be called
-(void) bleDidReceiveData:(unsigned char *)data length:(int)length {
    //NSLog(@"Length: %d", length);
    SessionBean *myApp = [SessionBean sharedSessionBean];
    // ricezione responso
    // se il responso Ë negativo bisogna chiudere la trasmissione
    // se il responso Ë positivo puÚ continuare la trasmissione
    for (int i = 0; i < length; i+=3) {
        //NSLog(@"0x%02X, 0x%02X, 0x%02X", data[i], data[i+1], data[i+2]);
        if (data[i] == 0x0A) {
            if (data[i + 2] == myApp.numIdTrasm) {
                //NSLog(@"conferma identificazione per cambio pswd");
                self.attesa_convalida_pswd_attuale = false;
                [self.mTimerAttuale invalidate];
                //NSLog(@"myApp.CONFERMA : %f",myApp.CONFERMA);
                //NSLog(@"data[i + 1] : %c",data[i + 1]);
                if (data[i + 1] == myApp.CONFERMA) {
                    //NSLog(@"conferma identificazione per cambio pswd");
                    [self trasmettiPasswordNuova];
                } else {
                    //NSLog(@"rifiuto identificazione per cambio paswd");
                    [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"password_incorrect", @"Incorrect password.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        } else if (data[i] == 0x0C) {
            if (data[i + 2] == myApp.numIdTrasm) {
                //NSLog(@"conferma identificazione per cambio pswd");
                self.attesa_convalida_pswd_attuale = false;
                
                if (data[i + 1] == myApp.CONFERMA) {
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    
                    [defaults setObject:self.lblConfirmNewPassword.text forKey:@"pswd"];
                    
                    [defaults synchronize];

                } else{
                    //NSLog(@"Password nuova non settata");
                    [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"old_password_incorrect", @"Incorrect old password. New password is not set.") delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
                
                self.attesa_convalida_pswd_nuova = NO;
                [self.mTimerNuova invalidate];
            }
        }
    }
}

-(void)bleDidDisconnect {
    
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField {
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
