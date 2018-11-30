#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

#define kAccountSocialTypeKey @"ACCOUNT_SOCIAL_TYPE"
#define kAccountEmailKey @"ACCOUNT_EMAIL"
#define kAccountNameKey @"ACCOUNT_NAME"

typedef enum SocialAccountType  {
    SocialAccountTypeFacebook = 1,
    SocialAccountTypeEmail = 2
} SocialAccountType;

@interface AppDelegate : UIResponder <UIApplicationDelegate, NSURLConnectionDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;

- (void)facebook;
- (void)facebookLogout;

- (void)loggedIn:(SocialAccountType)accountType;

- (void)loggedData:(NSString *)email withName:(NSString *)name;
- (void)loggedData:(NSString *)email withName:(NSString *)name whereFirst:(NSString *)first whereLast:(NSString *)last;
- (void)loggedOut;

- (void)showMessage:(NSString *)message withTitle:(NSString *)title;

@end

