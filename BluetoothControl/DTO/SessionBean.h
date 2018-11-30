#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BLE.h"

@interface SessionBean : NSObject

+ (id) sharedSessionBean;
+ (int) unsignedByte:(Byte)a;

@property (nonatomic) float Vmin;
@property (nonatomic) float Vmax;
@property (nonatomic) UInt8 CONFERMA;
@property (nonatomic) UInt8 RIFIUTO;

@property (nonatomic) NSInteger NSTAZ;
@property (nonatomic) UInt8 numIdTrasm;

@property (nonatomic) CBPeripheral *mDevice;
@property (nonatomic, strong) NSString *password;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic) CGPoint imagePosition;
@property (nonatomic) float imageZoom;

@end