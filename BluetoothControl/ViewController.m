#import "ViewController.h"
#import "ImageScrollView.h"
#import "SessionBean.h"

#define CONNECTION_RETRIES 4

@interface ViewController ()

@property (strong, nonatomic) BLE *ble;
@property (strong, nonatomic) IBOutlet UILabel *sbVolt;
@property (strong, nonatomic) IBOutlet UILabel *sbVoltDecimal;
@property (strong, nonatomic) IBOutlet UILabel *lblL1;
@property (strong, nonatomic) IBOutlet UILabel *lblL2;
@property (strong, nonatomic) IBOutlet UILabel *lblTimer;
@property (strong, nonatomic) IBOutlet UILabel *lblSpeed;
@property (strong, nonatomic) IBOutlet UILabel *lblDuty;
@property (strong, nonatomic) IBOutlet UIButton *btnPedale;
@property (strong, nonatomic) IBOutlet UIButton *btnConnect;
@property (strong, nonatomic) IBOutlet UIButton *btnSelL;
@property (strong, nonatomic) IBOutlet UIButton *btnSelS;
@property (strong, nonatomic) IBOutlet UIButton *btnSelPiu;
@property (strong, nonatomic) IBOutlet UIButton *btnSelMeno;
@property (strong, nonatomic) IBOutlet UIButton *btnL1;
@property (strong, nonatomic) IBOutlet UIButton *btnL2;
@property (strong, nonatomic) IBOutlet UIButton *selMarca1;
@property (strong, nonatomic) IBOutlet UIButton *selMarca2;
@property (strong, nonatomic) IBOutlet UIButton *selMarca3;
@property (strong, nonatomic) IBOutlet UIButton *selMarca4;
@property (strong, nonatomic) IBOutlet UIButton *selMarca5;
@property (strong, nonatomic) IBOutlet UILabel *lblMarca1;
@property (strong, nonatomic) IBOutlet UILabel *lblMarca2;
@property (strong, nonatomic) IBOutlet UILabel *lblMarca3;
@property (strong, nonatomic) IBOutlet UILabel *lblMarca4;
@property (strong, nonatomic) IBOutlet UILabel *lblMarca5;
@property (strong, nonatomic) IBOutlet UILabel *liner;
@property (strong, nonatomic) IBOutlet UILabel *shader;
@property (strong, nonatomic) IBOutlet UIView *loadingView;


@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UIView *previewView;
@property (weak, nonatomic) IBOutlet ImageScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIButton *btnSelPiuPreview;
@property (strong, nonatomic) IBOutlet UIButton *btnSelMenoPreview;
@property (strong, nonatomic) IBOutlet UIButton *btnL1Preview;
@property (strong, nonatomic) IBOutlet UIButton *btnL2Preview;
@property (strong, nonatomic) IBOutlet UIButton *btnPedalePreview;
@property (strong, nonatomic) IBOutlet UILabel *sbVoltPreview;
@property (strong, nonatomic) IBOutlet UILabel *sbVoltDecimalPreview;


@property (strong, nonatomic) NSTimer *pingTimer;
@property (strong, nonatomic) NSTimer *mTimer;
@property (strong, nonatomic) NSTimer *piuTimer;
@property (strong, nonatomic) NSTimer *menoTimer;
@property (strong, nonatomic) NSTimer *timerPedale;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;

@property (nonatomic) int seconds;
@property (nonatomic) int minute;
@property (nonatomic) int hour;
@property (nonatomic) int connectionRetries;
@property (nonatomic) float vm;
@property (nonatomic) UInt8 vOut;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.btnConnect.selected = NO;
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    //Initializzation
    SessionBean *app = [SessionBean sharedSessionBean];
    app.Vmin = 4.32;
    app.Vmax = 19.55;
    app.NSTAZ = 4;
    app.CONFERMA = 0x44;
    app.RIFIUTO = 0x0f;
    
    self.vOut = 0;
    self.vm = 6;
    self.connectionRetries = CONNECTION_RETRIES;
    
    UILongPressGestureRecognizer *longPressTimer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelTimer:)];
    
    self.lblTimer.userInteractionEnabled = YES;
    [self.lblTimer addGestureRecognizer:longPressTimer];
    
    UILongPressGestureRecognizer *longPressPiu = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelPiu:)];
    UILongPressGestureRecognizer *longPressMeno = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelMeno:)];
    
    [self.btnSelPiu addGestureRecognizer:longPressPiu];
    [self.btnSelMeno addGestureRecognizer:longPressMeno];
    
    [self.btnSelPiuPreview addGestureRecognizer:longPressPiu];
    [self.btnSelMenoPreview addGestureRecognizer:longPressMeno];
    
    UILongPressGestureRecognizer *longPressS = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelS:)];
    UILongPressGestureRecognizer *longPressL = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelL:)];
    
    [self.btnSelL addGestureRecognizer:longPressL];
    [self.btnSelS addGestureRecognizer:longPressS];
    
    UILongPressGestureRecognizer *longPressMarca1 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelMarca1:)];
    UILongPressGestureRecognizer *longPressMarca2 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelMarca2:)];
    UILongPressGestureRecognizer *longPressMarca3 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelMarca3:)];
    UILongPressGestureRecognizer *longPressMarca4 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelMarca4:)];
    UILongPressGestureRecognizer *longPressMarca5 = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressSelMarca5:)];
    
    [self.selMarca1 addGestureRecognizer:longPressMarca1];
    [self.selMarca2 addGestureRecognizer:longPressMarca2];
    [self.selMarca3 addGestureRecognizer:longPressMarca3];
    [self.selMarca4 addGestureRecognizer:longPressMarca4];
    [self.selMarca5 addGestureRecognizer:longPressMarca5];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    app.password = [defaults objectForKey:@"pswd"];
    if (app.password == nil) {
        [defaults setObject:@"tattoo" forKey:@"pswd"];
        app.password = @"tattoo";
    }
    
    NSString * sel = [defaults objectForKey:@"LAST_CLICK"];
    if (sel != nil) {
        if ([sel isEqualToString:@"selL"]) {
            NSString * volt = [defaults objectForKey:@"L"];
            if (volt != nil) {
                [self displayData:[NSString stringWithFormat:@"%04.01f", [volt floatValue]]];
                self.btnSelL.selected = YES;
                self.btnSelS.selected = NO;
                self.liner.hidden = NO;
                self.shader.hidden = YES;
            }
        } else if([sel isEqualToString:@"selS"]) {
            NSString * volt = [defaults objectForKey:@"S"];
            if (volt != nil) {
                [self displayData:[NSString stringWithFormat:@"%04.01f", [volt floatValue]]];
                self.btnSelL.selected = NO;
                self.btnSelS.selected = YES;
                self.liner.hidden = YES;
                self.shader.hidden = NO;
            }
        }
    }
    
    long volts = 0;
    
    for (int i = 1; i <= 5; i++) {
        volts = [defaults integerForKey:[NSString stringWithFormat:@"MACHINE%i-VOLTS", i]];
        NSString *name = [defaults stringForKey:[NSString stringWithFormat:@"MACHINE%i-NAME", i]];
        
        if (!name.length) {
            [defaults setObject:[NSString stringWithFormat:@"MACHINE%i", i] forKey:[NSString stringWithFormat:@"MACHINE%i-NAME", i]];
        }
        
        if (!volts) {
            [defaults setObject:0 forKey:[NSString stringWithFormat:@"MACHINE%i-VOLTS", i]];
        }
    }
    
    volts = [defaults integerForKey:@"LINER-VOLTS"];
    
    if (!volts) {
        [defaults setObject:0 forKey:@"LINER-VOLTS"];
    }
    
    volts = [defaults integerForKey:@"SHADER-VOLTS"];
    
    if (!volts) {
        [defaults setObject:0 forKey:@"SHADER-VOLTS"];
    }
    
    [defaults synchronize];
    
    self.seconds = 0;
    self.minute = 0;
    self.hour = 0;
    
    self.ble = [BLE sharedBLE];
    [self.ble controlSetup];
    self.ble.delegate = self;
    
    self.scrollView.maximumZoomScale = 3.0f;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.bouncesZoom = YES;
    self.scrollView.bounces = YES;
    self.scrollView.alwaysBounceHorizontal = YES;
    self.scrollView.alwaysBounceVertical = YES;
    self.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    self.scrollView.delegate = self.scrollView;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIBackgroundTaskIdentifier bgTask = 0;
    UIApplication  *sharedApplication = [UIApplication sharedApplication];
    bgTask = [sharedApplication beginBackgroundTaskWithExpirationHandler:^{
        [sharedApplication endBackgroundTask:bgTask];
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [[self navigationController] setNavigationBarHidden:YES animated:YES];
    
    self.ble = [BLE sharedBLE];
    self.ble.delegate = self;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSInteger selectedFootyType = [defaults integerForKey:@"FOOT"];
    
    if (selectedFootyType == 1) { // 1 - Toggle
        //self.btnPedale.userInteractionEnabled = NO;
        //self.btnPedale.alpha = 0.6f;
        [self setPedaleSate:NO];
    } else if (selectedFootyType == 2) { // 2 - In-app Toggle
        //self.btnPedale.userInteractionEnabled = YES;
        //self.btnPedale.alpha = 1.0f;
    } else { // Continuous
        [defaults setInteger:0 forKey:@"FOOT"];
        //self.btnPedale.userInteractionEnabled = NO;
        //self.btnPedale.alpha = 0.6f;
    }
    
    NSString *presetName = nil;
    
    presetName = [defaults stringForKey:@"MACHINE1-NAME"];
    if (presetName != nil) {
        [self.lblMarca1 setText:presetName];
    }
    
    presetName = [defaults stringForKey:@"MACHINE2-NAME"];
    if (presetName != nil) {
        [self.lblMarca2 setText:presetName];
    }
    
    presetName = [defaults stringForKey:@"MACHINE3-NAME"];
    if (presetName != nil) {
        [self.lblMarca3 setText:presetName];
    }
    
    presetName = [defaults stringForKey:@"MACHINE4-NAME"];
    if (presetName != nil) {
        [self.lblMarca4 setText:presetName];
    }
    
    presetName = [defaults stringForKey:@"MACHINE5-NAME"];
    if (presetName != nil) {
        [self.lblMarca5 setText:presetName];
    }
}

- (void)setPedaleSate:(BOOL)state {
    self.btnPedale.selected = state;
    self.btnPedalePreview.selected = state;
    
    if (state) {
        self.timerPedale = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerTick:) userInfo:nil repeats:YES];
    } else {
        [self.timerPedale invalidate];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)ping:(NSTimer *)timer {
    if (!self.btnPedale.isSelected) {
        UInt8 buf[3] = {0x04, 0x00, 0x55};
        
        if ([self.btnL1 isSelected]) {
            buf[1] = 0x44;
        } else if ([self.btnL2 isSelected]) {
            buf[1] = 0x66;
        }
        
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
}

#pragma mark - BLE delegate
- (void)bleDidDisconnect:(NSError *)error {
    //NSLog(@"didDisconnectPeripheral with error: %@", error);
    
    SessionBean *app = [SessionBean sharedSessionBean];
    app.mDevice = nil;
    
    if (error && self.connectionRetries) {
        [self btnScanForPeripherals:nil];
        self.connectionRetries--;
        return;
    } else if (error) {
        self.connectionRetries = CONNECTION_RETRIES;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_connection_error", @"Bluetooth connection failed. Problem may appear because of continuously repeated connections. Please try to connect again after few minutes.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
    }
    
    [self displayData:[NSString stringWithFormat:@"%04.01f", 0.0]];
    [self setPedaleSate:NO];
    [self.pingTimer invalidate];
    [self.btnConnect setEnabled:YES];
    [self.btnConnect setSelected:NO];
    if (![self.loadingView isHidden]) {
        [self.loadingView setHidden:YES];
    }
}

- (void)bleDidConnect {
    self.connectionRetries = CONNECTION_RETRIES;
    
    self.pingTimer = [NSTimer scheduledTimerWithTimeInterval:30.0 target:self selector:@selector(ping:) userInfo:nil repeats:YES];
    [self.mTimer invalidate];
    
    [self sendPassword];
    [self.btnConnect setEnabled:YES];
    [self.btnConnect setSelected:YES];
    [self.loadingView setHidden:YES];
}

// When data is comming, this will be called
- (void)bleDidReceiveData:(unsigned char *)data length:(int)length {
    // parse data, all commands are in 3-byte
    for (int i = 0; i < length; i+=3) {
        if (data[i] == 0x0B) {
            int vv = 256 * [SessionBean unsignedByte:data[i+1]];
            vv += [SessionBean unsignedByte:data[i+2]];
            [self displayData:[NSString stringWithFormat:@"%04.01f", vv * 6.6 * 3.3 / 1024.0]];
        } else if (data[i] == 0x0E) {
            if (!self.btnPedale.isSelected) {
                [self setPedaleSate:YES];
            }
            
            int tt1 = [SessionBean unsignedByte:data[i+1]];
            int tt2 = [SessionBean unsignedByte:data[i+2]];
            
            //NSLog(@"0x%02X, 0x%02X", data[i+1], data[i+2]);
            
            if (tt1 == 255 && tt2 == 255) {
                self.lblSpeed.text = @"c.c.";
                self.lblDuty.text = @"c.c.";
            } else {
                NSString *ss;
                
                ss = [NSString stringWithFormat:@"%dHz", tt1];
                if (ss != nil) {
                    self.lblSpeed.text = ss;
                }
                
                ss = [NSString stringWithFormat:@"%d%%", tt2];
                if (ss != nil) {
                    self.lblDuty.text = ss;
                }
            }
        } else if (data[i] == 0x06 && data[i+2] == 0x55) {
            SessionBean *app = [SessionBean sharedSessionBean];
            if (self.btnPedale.isSelected && data[i+1] == app.RIFIUTO) {
                [self setPedaleSate:NO];
            } else if (!self.btnPedale.isSelected && data[i+1] == app.CONFERMA) {
                [self setPedaleSate:YES];
            }
        } else if (data[i] == 0x08) {
            [self.mTimer invalidate];
            SessionBean *app = [SessionBean sharedSessionBean];
            if (data[i + 2] == app.numIdTrasm) {
                if (data[i+1] == app.CONFERMA) {
                    [NSThread sleepForTimeInterval:0.2];
                    UInt8 bufVolt[3] ={ 0x02, 0x00, 0x55 };
                    NSData *data = [[NSData alloc] initWithBytes:bufVolt length:3];
                    [self.ble write:data];
                    
                    UInt8 buf[3] = {0x04, 0x00 , 0x55};
                    
                    if ([self.btnL1 isSelected]) {
                        buf[1] = 0x44;
                    } else if ([self.btnL2 isSelected]) {
                        buf[1] = 0x66;
                    } else {
                        buf[1] = 0x44;
                        [self.btnL1 setSelected:YES];
                        [self.btnL2 setSelected:NO];
                        [self.btnL1Preview setSelected:YES];
                        [self.btnL2Preview setSelected:NO];
                    }
                    
                    [NSThread sleepForTimeInterval:0.2];
                    NSData *databuf = [[NSData alloc] initWithBytes:buf length:3];
                    [self.ble write:databuf];
                    [NSThread sleepForTimeInterval:0.2];
                    
                    buf[1] = 0x00;
                    buf[2] = 0x55;
                    
                    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                    NSInteger selectedFootyType = [defaults integerForKey:@"FOOT"];
                    
                    if (selectedFootyType == 1) { // 1 - Toggle
                        buf[0] = 0x53;
                    } else if (selectedFootyType == 2) { // 2 - In-app Toggle
                        buf[0] = 0x73;
                    } else { // Continuous
                        buf[0] = 0x13;
                    }
                    
                    databuf = [[NSData alloc] initWithBytes:buf length:3];
                    [self.ble write:databuf];
                    
                    UInt8 buf1[3] = {0x02, (uint8_t)self.vOut, 0x55};
                    
                    NSData *data1 = [[NSData alloc] initWithBytes:buf1 length:3];
                    [self.ble write:data1];
                } else {
                    [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"%@ %c", NSLocalizedString(@"password_incorrect", @"Incorrect iPower device password."), data[i+1]] delegate:self cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil, nil];
                    [alert show];
                }
            }
        }
    }
}

- (UInt8)volt2byte {
    SessionBean *app = [SessionBean sharedSessionBean];
    float pas=(app.Vmax - app.Vmin) / 127;
    return ((UInt8)((6 - app.Vmin) / pas));
}


- (void)displayData:(NSString*)data {
    if (data != nil) {
        NSArray* volts = [data componentsSeparatedByString: @"."];
        self.sbVolt.text = [volts objectAtIndex:0];
        self.sbVoltDecimal.text = [volts objectAtIndex:1];
        
        self.sbVoltPreview.text = self.sbVolt.text;
        self.sbVoltDecimalPreview.text = self.sbVoltDecimal.text;
    }
}

// Bluetooth Connect button will call to this
- (IBAction)btnScanForPeripherals:(id)sender {
    if (self.btnConnect.isSelected) {
        [self setPedaleSate:NO];
        [self.btnConnect setSelected:NO];
    } else {
        [self.btnConnect setSelected:YES];
        [self.loadingView setHidden:NO];
    }
    
    if (self.ble.activePeripheral && self.ble.activePeripheral.state == CBPeripheralStateConnected) {
        [[self.ble CM] cancelPeripheralConnection:[self.ble activePeripheral]];
        return;
    }
    
    if (self.ble.peripherals) {
        self.ble.peripherals = nil;
    }
    
    [self.btnConnect setEnabled:NO];
    [self.ble findBLEPeripherals:2.0];
    [NSTimer scheduledTimerWithTimeInterval:2.5 target:self selector:@selector(connectionTimer:) userInfo:nil repeats:NO];
}

- (IBAction)btnSelPedale:(id)sender {
    SessionBean *app = [SessionBean sharedSessionBean];
    if (self.btnPedale.isSelected) {
        [self setPedaleSate:NO];
        if (app.mDevice != nil) {
            UInt8 buf[3] = {0x73, 0x0F, 0x55};
            NSData *data = [[NSData alloc] initWithBytes:buf length:3];
            [self.ble write:data];
        }
    } else {
        [self setPedaleSate:YES];
        if (app.mDevice != nil) {
            UInt8 buf[3] = {0x73, 0x44, 0x55};
            NSData *data = [[NSData alloc] initWithBytes:buf length:3];
            [self.ble write:data];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView beginAnimations:nil context:nil];
                [UIView setAnimationDuration:0.2];
                
                [self setPedaleSate:NO];
                
                [UIView commitAnimations];
            });
        }
    }
    
    if (app.mDevice != nil) {
        [NSThread sleepForTimeInterval:0.2];
        
        NSInteger selectedFootyType = [[NSUserDefaults standardUserDefaults] integerForKey:@"FOOT"];
        
        UInt8 buf[3] = {0x03, 0x00, 0x55};
        
        if (selectedFootyType == 1) {
            buf[0]=0x53;
        } else if (selectedFootyType == 2) {
            buf[0]=0x73;
        } else {
            buf[0]=0x13;
        }
        
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
}

- (void)timerTick:(NSTimer *)timer {
    self.seconds++;
    if (self.seconds == 60) {
        self.seconds = 0;
        self.minute++;
        if (self.minute == 60) {
            self.minute = 0;
            self.hour++;
        }
    }
    
    self.lblTimer.text = [NSString stringWithFormat:@"%01i:%02i:%02i", self.hour, self.minute, self.seconds];
}

/**
  Long press on timer label will set it's value to zero.
  */
- (void)longPressSelTimer:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateRecognized) {
        self.seconds = 0;
        self.minute = 0;
        self.hour = 0;
        self.lblTimer.text = [NSString stringWithFormat:@"%01i:%02i:%02i", self.hour, self.minute, self.seconds];
    }
}

- (IBAction)btnSelMarca1:(id)sender {
    self.vOut = [[NSUserDefaults standardUserDefaults] integerForKey:@"MACHINE1-VOLTS"];

    UInt8 buf[3] = {0x02, (uint8_t)self.vOut , 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    self.btnSelS.selected=NO;
    self.btnSelL.selected=NO;
    
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    
    self.selMarca1.selected = YES;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
}

- (IBAction)btnSelMarca2:(id)sender {
    self.vOut = [[NSUserDefaults standardUserDefaults] integerForKey:@"MACHINE2-VOLTS"];
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut , 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    self.btnSelS.selected=NO;
    self.btnSelL.selected=NO;
    
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    
    self.selMarca1.selected = NO;
    self.selMarca2.selected = YES;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
}

- (IBAction)btnSelMarca3:(id)sender {
    self.vOut = [[NSUserDefaults standardUserDefaults] integerForKey:@"MACHINE3-VOLTS"];
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut , 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    self.btnSelS.selected=NO;
    self.btnSelL.selected=NO;
    
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = YES;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
}

- (IBAction)btnSelMarca4:(id)sender {
    self.vOut = [[NSUserDefaults standardUserDefaults] integerForKey:@"MACHINE4-VOLTS"];
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut , 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    self.btnSelS.selected=NO;
    self.btnSelL.selected=NO;
    
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = YES;
    self.selMarca5.selected = NO;
}

- (IBAction)btnSelMarca5:(id)sender {
    self.vOut = [[NSUserDefaults standardUserDefaults] integerForKey:@"MACHINE5-VOLTS"];
    
    //NSLog(@"%i", self.vOut);
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut , 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    self.btnSelS.selected=NO;
    self.btnSelL.selected=NO;
    
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = YES;
    
    //NSLog(@"PRESS: %i", self.vOut);
}

- (IBAction)btnSelL1:(id)sender {
    self.lblL1.hidden = NO;
    self.lblL2.hidden = YES;

    self.btnL1.selected = YES;
    self.btnL2.selected = NO;
    
    self.btnL1Preview.selected = YES;
    self.btnL2Preview.selected = NO;
    
    UInt8 buf[3] = {0x04, 0x44 , 0x55};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
}

- (IBAction)btnSelL2:(id)sender {
    self.lblL1.hidden = YES;
    self.lblL2.hidden = NO;
    
    self.btnL1.selected = NO;
    self.btnL2.selected = YES;
    
    self.btnL1Preview.selected = NO;
    self.btnL2Preview.selected = YES;
    
    UInt8 buf[3] = {0x04, 0x66 , 0x55};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
}

- (void)longPressSelS:(UILongPressGestureRecognizer*)gesture {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    if (gesture.state == UIGestureRecognizerStateEnded) {
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"SHADER-VOLTS"];

        self.btnSelS.selected=YES;
        self.btnSelL.selected=NO;
        self.liner.hidden = YES;
        self.shader.hidden = NO;
        
        self.selMarca1.selected = NO;
        self.selMarca2.selected = NO;
        self.selMarca3.selected = NO;
        self.selMarca4.selected = NO;
        self.selMarca5.selected = NO;
    }

    [defaults setObject:@"selS" forKey:@"LAST_CLICK"];

    [defaults synchronize];
}

- (void)longPressSelL:(UILongPressGestureRecognizer*)gesture {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (gesture.state == UIGestureRecognizerStateEnded) {
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"LINER-VOLTS"];
        self.btnSelS.selected=NO;
        self.btnSelL.selected=YES;
        self.liner.hidden = NO;
        self.shader.hidden = YES;
        
        self.selMarca1.selected = NO;
        self.selMarca2.selected = NO;
        self.selMarca3.selected = NO;
        self.selMarca4.selected = NO;
        self.selMarca5.selected = NO;
    }

    [defaults setObject:@"selL" forKey:@"LAST_CLICK"];
    [defaults synchronize];
}

- (void)longPressSelMarca1:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"MACHINE1-VOLTS"];
        [defaults synchronize];
        
        [self btnSelMarca1:self.selMarca1];
    }
}

- (void)longPressSelMarca2:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"MACHINE2-VOLTS"];
        [defaults synchronize];
        
        [self btnSelMarca2:self.selMarca2];
    }
}

- (void)longPressSelMarca3:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"MACHINE3-VOLTS"];
        [defaults synchronize];
        
        [self btnSelMarca3:self.selMarca3];
    }
}

- (void)longPressSelMarca4:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"MACHINE4-VOLTS"];
        [defaults synchronize];
        
        [self btnSelMarca4:self.selMarca4];
    }
}

- (void)longPressSelMarca5:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateEnded) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:[NSString stringWithFormat:@"%i", self.vOut] forKey:@"MACHINE5-VOLTS"];
        [defaults synchronize];
        
        [self btnSelMarca5:self.selMarca5];
    }
}

- (IBAction)btnSelS:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.vOut = [defaults integerForKey:@"SHADER-VOLTS"];
    
    self.btnSelS.selected=YES;
    self.btnSelL.selected=NO;
    self.liner.hidden = YES;
    self.shader.hidden = NO;
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut, 0x55};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    [defaults setObject:@"selS" forKey:@"LAST_CLICK"];
    [defaults synchronize];
}

- (IBAction)btnSelL:(id)sender {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.vOut = [defaults integerForKey:@"LINER-VOLTS"];
    
    self.btnSelL.selected=YES;
    self.btnSelS.selected=NO;
    self.liner.hidden = NO;
    self.shader.hidden = YES;
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut, 0x55};
    
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    [defaults setObject:@"selL" forKey:@"LAST_CLICK"];
    [defaults synchronize];
}

- (IBAction)rptUpdaterMeno {
    self.btnSelL.selected=NO;
    self.btnSelS.selected=NO;
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
    
    if (self.vOut > 0) {
        self.vOut--;
    }
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut, 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
}

- (IBAction)rptUpdaterPiu {
    self.btnSelL.selected = NO;
    self.btnSelS.selected = NO;
    self.liner.hidden = YES;
    self.shader.hidden = YES;
    self.selMarca1.selected = NO;
    self.selMarca2.selected = NO;
    self.selMarca3.selected = NO;
    self.selMarca4.selected = NO;
    self.selMarca5.selected = NO;
    
    if (self.vOut < 127) {
        self.vOut ++;
    }
    
    UInt8 buf[3] = {0x02, (uint8_t)self.vOut, 0x55};
    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
}

- (void)longPressSelPiu:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.piuTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rptUpdaterPiu) userInfo:nil repeats:YES];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.piuTimer invalidate];
        self.piuTimer = nil;
    }
}

- (void)longPressSelMeno:(UILongPressGestureRecognizer*)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.menoTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(rptUpdaterMeno) userInfo:nil repeats:YES];
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        [self.menoTimer invalidate];
        self.menoTimer = nil;
    }
}

- (void)connectionTimer:(NSTimer *)timer {
    if (self.ble.peripherals.count > 1) {
        [self setPedaleSate:NO];
        [self.btnConnect setSelected:NO];
        ZSYPopoverListView *listView = [[ZSYPopoverListView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
        listView.titleName.text = NSLocalizedString(@"choose", @"Choose");
        listView.datasource = self;
        listView.delegate = self;
        [listView show];
    } else if (self.ble.peripherals.count) {
        [NSThread sleepForTimeInterval:0.2];
        [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];
        SessionBean *app = [SessionBean sharedSessionBean];
        app.mDevice = [self.ble.peripherals objectAtIndex:0];
    } else {
        if (self.connectionRetries) {
            [NSThread sleepForTimeInterval:1.0];
            [self btnScanForPeripherals:nil];
            self.connectionRetries--;
        } else {
            [self setPedaleSate:NO];
            [self.btnConnect setSelected:NO];
            [self.btnConnect setEnabled:YES];
            [self.loadingView setHidden:YES];
            self.connectionRetries = CONNECTION_RETRIES;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_not_found", @"No iPower devices found. Please make sure that iPower device is powered on and try to connect again.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alert show];
        }
    }
}

- (void)sendPassword {
    int r = arc4random_uniform(256);
    SessionBean *app = [SessionBean sharedSessionBean];
    app.numIdTrasm = r;// numero identificativo trasmissione
    
    [NSThread sleepForTimeInterval:0.20];
    
    UInt8 buf[3] = {0x07, app.password.length, app.numIdTrasm}; // trasmissione numero caratteri password (max=15)

    NSData *data = [[NSData alloc] initWithBytes:buf length:3];
    [self.ble write:data];
    
    int b0;
    for (int i = 0; i < app.password.length; i++) {
        [NSThread sleepForTimeInterval:0.20];
        b0 = (((i+1)<<4)+7); // codice trasmissione password e numero pacchetto
        buf[0] = b0;
        buf[1] = [app.password characterAtIndex:i];	// trasmissione carattere password
        NSData *data = [[NSData alloc] initWithBytes:buf length:3];
        [self.ble write:data];
    }
    
    self.mTimer = [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(stopPasswordCheck) userInfo:nil repeats:NO];
}

- (void)stopPasswordCheck {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"" message:NSLocalizedString(@"device_timeout", @"iPower device didn't respond within the timeout period. Please try to connect again.") delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
}

#pragma mark -
- (NSInteger)popoverListView:(ZSYPopoverListView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.ble.peripherals count];
}

- (UITableViewCell *)popoverListView:(ZSYPopoverListView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusablePopoverCellWithIdentifier:identifier];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }

    CBPeripheral *p = [self.ble.peripherals objectAtIndex:indexPath.row];
    
    NSString *deviceName = [[NSUserDefaults standardUserDefaults] stringForKey:p.identifier.UUIDString];
    
    if (deviceName != nil) {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", deviceName];
    } else {
        [cell.textLabel setFont:[UIFont systemFontOfSize:11]];
        cell.textLabel.text = p.name;
        [cell.detailTextLabel setLineBreakMode:NSLineBreakByCharWrapping];
        [cell.detailTextLabel setFont:[UIFont systemFontOfSize:11]];
        cell.detailTextLabel.numberOfLines = 2;
        cell.detailTextLabel.text = p.identifier.UUIDString;
    }
    
    return cell;
}

- (void)popoverListView:(ZSYPopoverListView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    //
}

- (void)popoverListView:(ZSYPopoverListView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndexPath = indexPath;
    [self.ble connectPeripheral:[self.ble.peripherals objectAtIndex:0]];
    SessionBean *app = [SessionBean sharedSessionBean];
    app.mDevice = [self.ble.peripherals objectAtIndex:0];
    [tableView dismiss];
}

- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

- (IBAction)openPreview:(id)sender {
    self.previewView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, self.previewView.frame.size.width, self.previewView.frame.size.height);
    self.previewView.hidden = NO;
    
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.previewView.frame = CGRectMake(0, self.bannerView.frame.size.height, self.previewView.frame.size.width, self.previewView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished && self.scrollView.imageView == nil) {
                             [self openImagePicker:nil];
                         }
                     }];
}

- (IBAction)closePreview:(id)sender {
    [UIView animateWithDuration:0.3
                          delay:0.1
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.previewView.frame = CGRectMake(0, [[UIScreen mainScreen] bounds].size.height, self.previewView.frame.size.width, self.previewView.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             self.previewView.hidden = YES;
                             self.previewView.frame = CGRectMake(0, self.bannerView.frame.size.height, self.previewView.frame.size.width, self.previewView.frame.size.height);
                         }
                     }];
}

- (IBAction)openImagePicker:(id)sender {
    if (self.loadingView.hidden) {
        self.loadingView.hidden = NO;
    }
    
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    
    [self presentViewController:picker animated:YES completion:nil];
}

-(void) bleDidDisconnect {}
-(void) bleDidUpdateRSSI:(NSNumber *)rssi {}


#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self.scrollView setImage:[info objectForKey:UIImagePickerControllerOriginalImage]];
    self.loadingView.hidden = YES;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    self.loadingView.hidden = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end
