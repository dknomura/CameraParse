//
//  RegisterViewController.m
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import "RegisterViewController.h"
#import "ViewController.h"
#import <Parse.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ParseFacebookUtilsV4/ParseFacebookUtilsV4.h>

@interface RegisterViewController ()
@property (weak, nonatomic) IBOutlet UITextField *userTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
//@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.fbLoginButton.delegate = self;
//    [self.fbLoginButton setPublishPermissions:@[@"publish_actions"]];

    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)fbSignUpPressed:(id)sender
{
    NSArray *permissions = @[@"user_photos", @"user_friends", @"public_profile"];
    [PFFacebookUtils logInInBackgroundWithReadPermissions:permissions block:^(PFUser * _Nullable user, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error logging in parse via facebook: %@, %@", error.localizedDescription, error.userInfo);
        } else{
            if (!user){
                NSLog(@"Uh oh. The user cancelled the Facebook login.");
            } else if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
                [self presentNewViewController];
            } else {
                NSLog(@"User logged in through Facebook!");
                [self presentNewViewController];
            }
        }
    }];
}




- (IBAction)signUpButton:(id)sender
{
    PFUser *user = [[PFUser alloc] init];
    user.username = self.userTextField.text;
    user.password = self.passwordTextField.text;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error){
            [self presentNewViewController];
        } else {
            NSLog(@"error signing up: %@", error.localizedDescription);
        }
    }];
}

-(void)presentNewViewController
{
    ViewController *viewController = [[ViewController alloc] initWithNibName:@"ViewController" bundle:nil];
    [self presentViewController:viewController animated:YES completion:nil];
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
