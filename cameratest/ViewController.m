//
//  ViewController.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "ViewController.h"
#import <Parse.h>
#import "DAO.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "LoginViewController.h"


@interface ViewController (){
    DAO *dao;
    BOOL isPopoverPresent;
    UIImagePickerController *imagePicker;
}
@property (weak, nonatomic) IBOutlet UITextView *commentTextField;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingSpinner;
@property (weak, nonatomic) IBOutlet UIImageView *photoFromCloud;
@property (weak, nonatomic) IBOutlet UITextField *photoTitleTextField;
@property (weak, nonatomic) IBOutlet UIButton *likeButton;
@property (weak, nonatomic) IBOutlet UILabel *likeCounterLabel;

@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    dao = [DAO sharedInstance];
    
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(photoUploaded:) name:@"photo uploaded" object:nil];
    [notificationCenter addObserver:self selector:@selector(updateTableViewAndLikeCounter) name:@"photo names downloaded" object:nil];
    
    self.loadingSpinner.hidden = YES;

    [dao loadPhotoNames];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardDismiss)];
    [self.view addGestureRecognizer: tap];
    tap.cancelsTouchesInView = NO;
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
//    [self.tableView reloadData];
}





-(void)keyboardDismiss
{
    if ([self.commentTextField isFirstResponder]) {
        [self.commentTextField resignFirstResponder];
    }
    if ([self.photoTitleTextField isFirstResponder]) {
        [self.photoTitleTextField resignFirstResponder];
    }
}





- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    [dao loadPhotoNames];
}


- (IBAction)edit:(id)sender{
    if([self.tableView isEditing]){
        [sender setTitle:@"Edit"];
    }else{
        [sender setTitle:@"Done"];
    }
    [self.tableView setEditing:![self.tableView isEditing]];
}


#pragma mark - Camera/Picture Access methods

- (IBAction)takePicture:(id)sender{
    
//    if(isPopoverPresent){
//        [self dismissViewControllerAnimated:YES completion:nil];
//    }
    
    imagePicker = [[UIImagePickerController alloc] init];
    
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
        UIAlertController *cameraActionSheet = [UIAlertController alertControllerWithTitle:@"Camera Action" message:@"Choose your destiny" preferredStyle:UIAlertControllerStyleAlert];
        
        [cameraActionSheet addAction:[UIAlertAction actionWithTitle:@"Take Picture" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
            [self showImagePicker];
        }]];
        
        [cameraActionSheet addAction:[UIAlertAction actionWithTitle:@"Choose Photo" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [self showImagePicker];
        }]];
        
        [cameraActionSheet addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        
        [self showViewController:cameraActionSheet sender:nil];
      
    }else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
        [self showImagePicker];
    }
    

    

    
    
//    self.popController = [[UIPopoverPresentationController alloc]initWithPresentedViewController:imagePicker presentingViewController:self];
    
//    [self.popController setDelegate:self];
    
//    [self.popController ];
    
    
}

-(void) showImagePicker
{
    [imagePicker setAllowsEditing:TRUE];
    [imagePicker setDelegate:self];
    self.modalPresentationStyle = UIModalPresentationPopover;
    [self presentViewController:imagePicker animated:YES completion:^{
        //        isPopoverPresent = YES;
    }];
    
    self.popController = imagePicker.popoverPresentationController;
    self.popController.delegate = self;
    self.popController.barButtonItem = self.barButtonCameraItem;
}





//-(void) pop
//{
//    isPopoverPresent = NO;
//}


-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    [self.popController dismissPopoverAnimated:YES];
//    self.popController = nil;
    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.imageView setImage:image];
//    
//    NSData *imageData = UIImageJPEGRepresentation ( image, 1.0);
//    
//    
//    NSString *fileName = [[NSString alloc] initWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970 ] ];

//    [self.s3Util uploadData:imageData format:@"image/jpeg"
//    bucketName:[Constants uploadBucket] withKey:fileName];
//    
    
}

#pragma mark - Buttons: Logout/like/post/comment methods

- (IBAction)logOutPressed:(id)sender
{
    [PFUser logOut];
    LoginViewController *loginViewController = [[UIStoryboard storyboardWithName:@"Storyboard" bundle:nil] instantiateInitialViewController];
    [self presentViewController:loginViewController animated:YES completion:nil];
}

- (IBAction)commentPressed:(id)sender
{
    NSUInteger indexForSelectedRow = [self.tableView indexPathForSelectedRow].row;
    UIAlertController *commentAlertController = [UIAlertController alertControllerWithTitle:@"Comment Below" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *commentTextField;
    [commentAlertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        commentTextField = textField;
    }];
    [commentAlertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [dao addComment:commentTextField.text forPhotoAtIndex:indexForSelectedRow];
    }]];
    [commentAlertController addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }]];
    
    [self presentViewController:commentAlertController animated:YES completion:nil];
    
}

- (IBAction)likePressed:(id)sender
{
    if ([self.tableView indexPathForSelectedRow]){
        NSUInteger indexForSelectedRow = [self.tableView indexPathForSelectedRow].row;
        [dao addLikeForPhotoAtIndex:indexForSelectedRow];
    } else {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"Select a photo from list below" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleCancel handler:nil]];
        [self presentViewController:alertController animated:YES completion:nil];
    }
}


- (IBAction)postPicturePressed:(id)sender
{
    if (!self.imageView.image) {
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please select a photo" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    } else if ([self.photoTitleTextField.text isEqualToString:@""]){
        UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Error" message:@"Please enter a title" preferredStyle:UIAlertControllerStyleAlert];
        [controller addAction:[UIAlertAction actionWithTitle:@"Confirm" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        }]];
        [self presentViewController:controller animated:YES completion:nil];
    }else {
        self.loadingSpinner.hidden = NO;
        [self.loadingSpinner startAnimating];
        
        [dao postPhoto:self.imageView.image name:self.photoTitleTextField.text withComment:self.commentTextField.text];
    }
}

//
//- (void)uploadDone:(NSError *)error
//{
//    if(error != nil){
//        NSLog(@"Error: %@", error);
//    }else
//    {
//        NSLog(@"File Uploaded");
//        [self loadData];
//    }
//}

#pragma mark - NSNotification Center methods
-(void)photoUploaded:(NSNotification*) notification
{
    self.commentTextField.text = nil;
    self.imageView.image = nil;
    self.photoTitleTextField.text = nil;
    
    [self.loadingSpinner stopAnimating];
    self.loadingSpinner.hidden = YES;
    
    [self loadData];
}

-(void)updateTableViewAndLikeCounter
{
    NSIndexPath *selectedRowIndexPath = [self.tableView indexPathForSelectedRow];
    NSUInteger row = selectedRowIndexPath.row;
    PFObject *object = [dao.photoObjects objectAtIndex:row];
    if (selectedRowIndexPath) {
        id dictionaryForSelectedRow = [dao.tableData objectForKey:object.objectId];
        BOOL userDidLike = [[dictionaryForSelectedRow objectForKey:@"userDidLike"]boolValue];
        NSNumber *numberOfLikes = [dictionaryForSelectedRow objectForKey:@"numberOfLikes"];
        if (userDidLike) {
            self.likeButton.imageView.image = [UIImage imageNamed:@"full heart.png"];
        } else{
            self.likeButton.imageView.image = [UIImage imageNamed:@"empty heart.png"];
        }
        self.likeCounterLabel.text = [NSString stringWithFormat:@"%@", numberOfLikes];
    }
    [self.tableView reloadData];
    self.photoFromCloud.image = nil;
}


//-(void)photoNamesDownloaded
//{
//    [self.tableView reloadData];
//}


#pragma mark - tableview Delegate methods


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dao.photoObjects count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell){
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
    }
    
    
    NSString *fileName = [dao getTableCellTitleForPhotoAtIndex:indexPath.row];
    
    [[cell textLabel] setText: fileName];
    cell.detailTextLabel.text = [dao getTCDetailedTextForPhotoAtIndex:indexPath.row];
    
    NSData *photoData = [dao.dataObjects objectAtIndex:indexPath.row];
    cell.imageView.image = [UIImage imageWithData:photoData];
    return cell;
}

-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{

//    NSString *fileName = [NSString stringWithFormat:@"%@",
//                          [self.tableData objectAtIndex: indexPath.row ]];
    
    //METHODS FOR SHOWING LIKE # AND ON/OFF and the comments. Then Animate
    
    
    NSData *downloadData = [dao.dataObjects objectAtIndex:indexPath.row];
    
    if(downloadData){
        self.photoFromCloud.image = [UIImage imageWithData:downloadData];
    }
}


- (void) tableView: (UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [dao deletePhotoAtIndex:indexPath.row];
//    [dao.tableData removeObjectForKey:[dao.photoObjects objectAtIndex:indexPath.row]];
    [dao.photoObjects removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationLeft];
//    [self loadData];
 }

-(void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
