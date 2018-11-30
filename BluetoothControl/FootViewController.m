//
//  FootViewController.m
//  BluetoothControl
//
//  Created by Andrea Valle on 19/10/14.
//  Copyright (c) 2014 Andrea. All rights reserved.
//

#import "FootViewController.h"
#import "BLE.h"

@interface FootViewController ()

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) NSArray *footType;
@property (strong, nonatomic) IBOutlet UIPickerView *picker;

@end

@implementation FootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.footType = @[@"Continuous", @"Toggle", @"Toggle Phone"];
    self.ble = [BLE sharedBLE];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString * foot = [defaults objectForKey:@"FOOT"];
    if (foot != nil) {
        [self.picker selectRow:[self.footType indexOfObject:foot] inComponent:0 animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark PickerView DataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.footType.count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component
{
    return self.footType[row];
}

#pragma mark -
#pragma mark PickerView Delegate
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row
      inComponent:(NSInteger)component
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    [defaults setObject:self.footType[row] forKey:@"FOOT"];
    [defaults synchronize];
    
    UInt8 buf[3] = {0x03, 0x00, 0x55};
    
    if ([self.footType[row] isEqualToString:@"Continuous"]) {
        buf[0]=0x13;
    } else if ([self.footType[row] isEqualToString:@"Toggle"]) {
         buf[0]=0x53;
    } else if ([self.footType[row] isEqualToString:@"Toggle Phone"]) {
        buf[0]=0x73;
    }
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
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
