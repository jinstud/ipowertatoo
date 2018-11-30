//
//  LoadingPageViewController.m
//  BluetoothControl
//
//  Created by Andrea Valle on 24/09/14.
//  Copyright (c) 2014 Andrea. All rights reserved.
//

#import "LoadingPageViewController.h"
#import "ViewController.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)

@interface LoadingPageViewController ()

@end

@implementation LoadingPageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //[[self navigationController] setNavigationBarHidden:YES];
    
    // Do any additional setup after loading the view.
    //NSLog(@"%f",[[UIScreen mainScreen] bounds].size.height);
    if (IS_IPHONE_5) {
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ViewController *controller = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController5"];
        [self.navigationController pushViewController:controller animated:YES];
    }else if (IS_IPHONE_6){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ViewController *controller = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController6"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    else if (IS_IPHONE_6_PLUS){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ViewController *controller = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController6P"];
        [self.navigationController pushViewController:controller animated:YES];
    } else{
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Main" bundle: nil];
        ViewController *controller = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }
    /*
    else if(IS_IPAD){
        UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"Mainipad" bundle: nil];
        ViewController *controller = (ViewController*)[mainStoryboard instantiateViewControllerWithIdentifier: @"ViewController"];
        [self.navigationController pushViewController:controller animated:YES];
    }*/
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
