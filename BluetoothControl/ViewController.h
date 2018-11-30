#import <UIKit/UIKit.h>
#import "BLE.h"
#import "ZSYPopoverListView.h"

@interface ViewController : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, BLEDelegate, ZSYPopoverListDatasource, ZSYPopoverListDelegate>

@end

