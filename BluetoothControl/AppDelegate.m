#import <FacebookSDK/FacebookSDK.h>
#import <Accounts/Accounts.h>

#import "AppDelegate.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPHONE_5 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 568.0)
#define IS_IPHONE_6 (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 667.0)
#define IS_IPHONE_6PLUS (IS_IPHONE && [[UIScreen mainScreen] nativeScale] == 3.0f)
#define IS_IPHONE_6_PLUS (IS_IPHONE && [[UIScreen mainScreen] bounds].size.height == 736.0)
#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0)

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    SocialAccountType lastActiveSocialAccountType = (int)[defaults integerForKey:kAccountSocialTypeKey];
    
    if(lastActiveSocialAccountType == SocialAccountTypeFacebook) {
        [self loggedIn:SocialAccountTypeFacebook];
        /*if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
            // If there's one, just open the session silently, without showing the user the login UI
            [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"] allowLoginUI:NO completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                // Handler for session state changes
                // This method will be called EACH time the session state changes,
                // also for intermediate states and NOT just when the session open
                [self sessionStateChanged:session state:state error:error];
            }];
        }*/
    } else if (lastActiveSocialAccountType == SocialAccountTypeEmail) {
        NSString *email = [[NSUserDefaults standardUserDefaults] stringForKey:kAccountEmailKey];
        if (email.length) {
            [self loggedIn:SocialAccountTypeEmail];
        } else {
            [self loggedOut];
        }
    } else {
        [self loggedOut];
    }
    
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Override point for customization after application launch.
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [FBAppEvents activateApp];
    
    // Handle the user leaving the app while the Facebook login dialog is being shown
    // For example: when the user presses the iOS "home" button while the login dialog is active
    [FBAppCall handleDidBecomeActive];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

// During the Facebook login flow, your app passes control to the Facebook iOS app or Facebook in a mobile browser.
// After authentication, your app will be called back with the session information.
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // Note this handler block should be the exact same as the handler passed to any open calls.
    [FBSession.activeSession setStateChangeHandler:
     ^(FBSession *session, FBSessionState state, NSError *error) {
         // Retrieve the app delegate
         AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
         // Call the app delegate's sessionStateChanged:state:error method to handle session state changes
         [appDelegate sessionStateChanged:session state:state error:error];
     }];
    return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication];
}

// This method will handle ALL the session state changes in the app
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error
{
    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen){
        //NSLog(@"Session opened");
        // Show the user the logged-in UI
        [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
            if (error) {
                //error
            } else {
                // Retrieve the app delegate
                AppDelegate* appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                // Call the app delegate's loggedEmail method to store user data
                [appDelegate loggedData:[user objectForKey:@"email"] withName:[user objectForKey:@"name"] whereFirst:[user objectForKey:@"first_name"] whereLast:[user objectForKey:@"last_name"]];
            }
        }];
        
        [self loggedIn:SocialAccountTypeFacebook];
        
        return;
    }
    if (state == FBSessionStateClosed || state == FBSessionStateClosedLoginFailed){
        // If the session is closed
        //NSLog(@"Session closed");
        // Show the user the logged-out UI
        [self loggedOut];
    }
    
    // Handle errors
    if (error) {
        //NSLog(@"Error");
        // If the error requires people using an app to make an action outside of the app in order to recover
        if ([FBErrorUtility shouldNotifyUserForError:error] == YES) {
            [self showMessage:[FBErrorUtility userMessageForError:error] withTitle:NSLocalizedString(@"something_went_wrong", @"Something went wrong")];
        } else {
            // If the user cancelled login, do nothing
            if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                //NSLog(@"User cancelled login");
            } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                [self showMessage:NSLocalizedString(@"session_no_valid", @"Your current session is no longer valid. Please sign in again.") withTitle:NSLocalizedString(@"session_error", @"Session Error")];
            } else {
                //Get more error information from the error
                NSDictionary *errorInformation = [[[error.userInfo objectForKey:@"com.facebook.sdk:ParsedJSONResponseKey"] objectForKey:@"body"] objectForKey:@"error"];
                
                // Show the user an error message
                [self showMessage:[NSString stringWithFormat:NSLocalizedString(@"rety_contact_with_code", @"Please retry. \n\n If the problem persists contact us and mention this error code: %@"), [errorInformation objectForKey:@"message"]] withTitle:NSLocalizedString(@"something_went_wrong", @"Something went wrong")];
            }
        }
        // Clear this token
        [FBSession.activeSession closeAndClearTokenInformation];
        // Show the user the logged-out UI
        [self loggedOut];
    }
}

- (void)facebook {
    // If the session state is any of the two "open" states when the button is clicked
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [self loggedIn:SocialAccountTypeFacebook];
    } else {
        // Open a session showing the user the login UI
        // You must ALWAYS ask for public_profile permissions when opening a session
        [FBSession openActiveSessionWithReadPermissions:@[@"public_profile", @"email"]
                                           allowLoginUI:YES
                                      completionHandler:
         ^(FBSession *session, FBSessionState state, NSError *error) {
             [self sessionStateChanged:session state:state error:error];
         }];
    }
}

- (void)facebookLogout {
    if (FBSession.activeSession.state == FBSessionStateOpen
        || FBSession.activeSession.state == FBSessionStateOpenTokenExtended) {
        [FBSession.activeSession closeAndClearTokenInformation];
    }
}

- (void)showMessage:(NSString *)message withTitle:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:NSLocalizedString(@"ok", @"OK") otherButtonTitles:nil];
    [alert show];
}

- (void)loggedIn:(SocialAccountType)accountType {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:accountType forKey:kAccountSocialTypeKey];
    [userDefaults synchronize];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;

    if(![NSStringFromClass([navigationController.topViewController class]) isEqualToString:@"ViewController"]) {
        BOOL animated = [NSStringFromClass([navigationController.topViewController class]) isEqualToString:@"WelcomeViewController"];
        
        if (!animated) {
            UIView *overlay = [navigationController.topViewController.view viewWithTag:77];
            if (overlay) {
                [overlay removeFromSuperview];
            }
        }
        
        if (IS_IPHONE_5) {
            [navigationController pushViewController:[navigationController.storyboard instantiateViewControllerWithIdentifier:@"ViewController5"] animated:animated];
        } else if (IS_IPHONE_6) {
            [navigationController pushViewController:[navigationController.storyboard instantiateViewControllerWithIdentifier:@"ViewController6"] animated:animated];
        } else if (IS_IPHONE_6_PLUS) {
            [navigationController pushViewController:[navigationController.storyboard instantiateViewControllerWithIdentifier:@"ViewController6P"] animated:animated];
        } else if (IS_IPAD){
            [navigationController pushViewController:[navigationController.storyboard instantiateViewControllerWithIdentifier:@"ViewControllerIP"] animated:animated];
        } else {
            [navigationController pushViewController:[navigationController.storyboard instantiateViewControllerWithIdentifier:@"ViewController"] animated:animated];
        }
        
        [navigationController.topViewController dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)loggedData:(NSString *)email withName:(NSString *)name {
    [self loggedData:email withName:name whereFirst:nil whereLast:nil];
}

- (void)loggedData:(NSString *)email withName:(NSString *)name whereFirst:(NSString *)first whereLast:(NSString *)last {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (first != nil && last != nil && ![[defaults stringForKey:kAccountEmailKey] isEqualToString:email]) {
        @try {
            NSString *language = [[NSLocale preferredLanguages] objectAtIndex:0];
            NSString *post = [[NSString alloc] initWithFormat:@"firstname=%@&lastname=%@&email=%@&password=%@&language=%@", first, last, email, [self randomStringWithLength:6], language];
            NSString *timestamp = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000];
            NSData *postData = [post dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
            NSString *postLength = [NSString stringWithFormat:@"%lu", (unsigned long)[postData length]];
            
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
            [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", @"https://ipower.tattoo/api/sign-up/?cache=", timestamp]]];
            [request setHTTPMethod:@"POST"];
            [request setValue:postLength forHTTPHeaderField:@"Content-Length"];
            [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
            [request setHTTPBody:postData];
            
            [NSURLConnection connectionWithRequest:request delegate:self];
        }
        @catch (NSException *exception) {}
    }
    
    [defaults setObject:email forKey:kAccountEmailKey];
    if (name.length) {
        [defaults setObject:name forKey:kAccountNameKey];
    }
    [defaults synchronize];
}

- (void)loggedOut {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [userDefaults setInteger:0 forKey:kAccountSocialTypeKey];
    [userDefaults synchronize];
    
    UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
    
    UIView *overlay = [navigationController.topViewController.view viewWithTag:77];
    if (overlay) {
        [overlay removeFromSuperview];
    }
    
    if(![NSStringFromClass([navigationController.topViewController class]) isEqualToString:@"WelcomeViewController"]) {
        [navigationController pushViewController:[navigationController.storyboard instantiateViewControllerWithIdentifier: @"LoginScene"] animated:NO];
    }
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

- (NSString *)randomStringWithLength:(int)len {
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    return randomString;
}

#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // Append the new data to the instance variable you declared
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
}

@end
