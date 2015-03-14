//
//  LoginTableViewController.m
//  Soundtrace
//
//  Created by Sebastian Boldt on 20.12.14.
//  Copyright (c) 2014 sebastianboldt. All rights reserved.
//

#import "LoginTableViewController.h"
#import "RootViewController.h"
#import "SoundtraceClient.h"
#import "AppDelegate.h"
#import "SoundtraceClient.h"
#import "CredentialStore.h"
#import <TSMessage.h>
#import "Constants.h"
#import <SVProgressHUD.h>
#import <FAKFontAwesome.h>
#import "SRStylesheet.h"
@interface LoginTableViewController ()
@property (nonatomic,strong) CredentialStore * store;
@property (weak, nonatomic) IBOutlet UIImageView *logoImageView;
@property (nonatomic,strong)RootViewController * root;
@end

@implementation LoginTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.store = [[CredentialStore alloc]init];
    [self.logoImageView.layer setMinificationFilter:kCAFilterTrilinear];
    [self.loginButton setTitleColor:[SRStylesheet mainColor] forState:UIControlStateNormal];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.loginButton setBackgroundColor:[UIColor clearColor]];
    [self setupBackgroundImage];
    [self setupLogo];
}

-(void)setupBackgroundImage {
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.opaque = NO;
    UIImageView * view = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"background-image.png"]];
    view.contentMode = UIViewContentModeScaleAspectFill;
    self.tableView.backgroundView = view;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self showTutorialScreens];
}

-(void)setupLogo{
    NSAttributedString *attributedString =
    [[NSAttributedString alloc]
     initWithString:@"Soundrocket"
     attributes:
     @{
       NSFontAttributeName : [UIFont fontWithName:@"Helvetica-Bold" size:50],
       NSForegroundColorAttributeName : [SRStylesheet mainColor],
       NSKernAttributeName : @(-4.0f)
       }];
    
    self.soundrocketNameLabel.attributedText = attributedString;
    [self.poweredByLabel setTextColor:[SRStylesheet whiteColor]];
    [self.loginButtonBackgroundView setBackgroundColor:[UIColor clearColor]];

}



-(void)showTutorialScreens {
    UIStoryboard * storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        // app already launched, there is nothign to do here
        
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        UINavigationController * tipsController = [storyBoard instantiateViewControllerWithIdentifier:@"IntroNav"];
        [self presentViewController:tipsController animated:YES completion:nil];
        // This is the first launch ever
        
    }
}

- (IBAction)loginButtonPressed:(id)sender {
    // Logging in the User
    [self login];
}

-(void)login {
    [self.loginButton setHidden:YES];
    [self.loginButton setEnabled:NO];
    
    if (self.emailTextField.text.length != 0 && self.passWordTextField.text.length != 0) {
               
        NSMutableDictionary * parameters = [[NSMutableDictionary alloc]init];
        [self setupParametersForLogin:parameters];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        [self.activityIndicatorLoggingIn startAnimating];
        
        
        [[SoundtraceClient sharedClient] POST:@"/oauth2/token" parameters:parameters success: ^(NSURLSessionDataTask *task, id responseObject)
         {
             [self.store setAuthToken:[responseObject objectForKey:@"access_token"]];
             NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
             [defaults setObject:[responseObject objectForKey:@"access_token"] forKey:@"access_token"];
             [defaults synchronize];
             [self getUserData];
         }
         
            failure: ^(NSURLSessionDataTask *task, NSError *error)
         {
             [self.activityIndicatorLoggingIn stopAnimating];
             [self.loginButton setHidden:NO];
             [self.loginButton setEnabled:YES];
             [SVProgressHUD showErrorWithStatus:error.localizedDescription];
             [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         }];
    }
    else {
        [SVProgressHUD showErrorWithStatus:@"Please enter email and password first"];
        [self.loginButton setEnabled:YES];
        [self.loginButton setHidden:NO];

    }
    
}

-(void)setupParametersForLogin:(NSMutableDictionary*)parameters {
    // Token will not expire for now
    [parameters setObject:@"non-expiring" forKey:@"scope"];
    [parameters setObject:@"password" forKey:@"grant_type"];
    [parameters setObject:self.emailTextField.text forKey:@"username"];
    [parameters setObject:self.passWordTextField.text forKey:@"password"];
    [parameters setObject:CLIENT_ID forKey:@"client_id"];
    [parameters setObject:CLIENT_SECRET forKey:@"client_secret"];
}
-(void)getUserData {
    NSMutableDictionary * paramters = [[NSMutableDictionary alloc]init];
    [paramters setObject:self.store.authToken forKey:@"oauth_token"];
    [[SoundtraceClient sharedClient] GET:@"/me.json" parameters:paramters success: ^(NSURLSessionDataTask *task, id responseObject)
     {
         NSError * error = nil;
         AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
         User *currentUser = [[User alloc]initWithDictionary:responseObject error:&error];
         delegate.currentUser = currentUser;
         [self showMainController];
         
         // Enable the Buttons etc
         [self.activityIndicatorLoggingIn stopAnimating];
         [self.loginButton setHidden:NO];
         [self.loginButton setEnabled:YES];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         
     }
     
    failure: ^(NSURLSessionDataTask *task, NSError *error)
     {
         // Fehlerbehandlung
         [self.activityIndicatorLoggingIn stopAnimating];
         [self.loginButton setHidden:NO];
         [self.loginButton setEnabled:YES];
         [SVProgressHUD showErrorWithStatus:error.localizedDescription];
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
     }];
}

-(void)showMainController {
    if (!self.root) {
        UIStoryboard * storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.root = [storyboard instantiateViewControllerWithIdentifier:@"Root"];
    }

    AppDelegate * delegate = (AppDelegate*)[[UIApplication sharedApplication]delegate];
    [UIView transitionFromView:delegate.window.rootViewController.view
                        toView:self.root.view
                      duration:0.65f
                       options:(UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionTransitionCrossDissolve)
                    completion:^(BOOL finished){
                        [self.activityIndicatorLoggingIn stopAnimating];
                        [self.loginButton setHidden:NO];
                        delegate.window.rootViewController = self.root;
                    }];
}
@end
