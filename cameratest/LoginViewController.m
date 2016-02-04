//
//  LoginViewController.m
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import "LoginViewController.h"
#import "ViewController.h"
#import "DAO.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface LoginViewController (){
    DAO *dao;
}
@property (weak, nonatomic) IBOutlet UITextField *userFieldTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dao = [DAO sharedInstance];
    
    
    PFUser *user = [PFUser currentUser];
    
    if (user){
        if ([user isAuthenticated]) {
            [self presentNewViewController];
        }
    }
//    [self.fbLoginButton setPublishPermissions:@[@"publish_actions"]];
//    self.fbLoginButton.delegate = self;
//    [dao loadPhotoNames];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginPressed:(id)sender
{
    [PFUser logInWithUsernameInBackground:self.userFieldTextField.text password:self.passwordTextField.text block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (user != nil) {
            [self presentNewViewController];
        } else {
            NSLog(@"Error logging in: %@, %@", error.localizedDescription, error.userInfo);
        }
    }];
}
- (IBAction)fbLoginPressed:(id)sender
{
    NSArray *permissions = @[@"user_photos", @"user_friends", @"public_profile"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error logging in parse via facebook: %@, %@", error.localizedDescription, error.userInfo);
        } else{
            if (!user){
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
//                [dao runGraphRequestToSetNameForFBUser:user];
                NSLog(@"User signed up and logged in through Facebook!");
                [self presentNewViewController];
            } else {
                NSLog(@"User logged in through Facebook!");
                [self presentNewViewController];
            }
        }
    }];
}




-(void)presentNewViewController
{
    ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
}

- (IBAction)signUpPressed:(id)sender
{
//    [self performSegueWithIdentifier:@"SignUp" sender:nil];
}

//-(BOOL)loginButtonWillLogin:(FBSDKLoginButton *)loginButton
//{
////    if (!error){
//    if (self.fbLoginButton.)
//
//        }];
////    } else {
////        NSLog(@"Error logging into facebook: \n%@, %@", error.localizedDescription, error.userInfo);
////    }
//    return TRUE;
//}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
