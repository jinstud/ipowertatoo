#import <UIKit/UIKit.h>

@interface PresetViewController : UIViewController <UITextFieldDelegate>

- (IBAction)sliderValueChanged:(UISlider *)sender;
- (IBAction)txtVoltsEditingDidEnd:(UITextField *)sender;
- (IBAction)savePreset:(id)sender;
- (IBAction)backgroundTap:(id)sender;

@property (weak, nonatomic) IBOutlet UITextField *txtName;
@property (weak, nonatomic) IBOutlet UITextField *txtVolts;
@property (weak, nonatomic) IBOutlet UISlider *sliderVolts;
@property (weak, nonatomic) IBOutlet UIButton *buttonSave;

@end
