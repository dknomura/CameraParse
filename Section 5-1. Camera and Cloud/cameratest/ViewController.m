//
//  ViewController.m
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@end

@implementation ViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.s3Util = [[AmazonS3Util alloc] initWithAccessKey:ACCESS_KEY_ID secretKey:SECRET_KEY
                bucket:[Constants uploadBucket] delegate:self];
    
    [self loadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)loadData
{
    self.tableData = [self.s3Util listFromBucket:[Constants uploadBucket]];
    [self.tableView reloadData];
}


- (IBAction)edit:(id)sender{
    if([self.tableView isEditing]){
        [sender setTitle:@"Edit"];
    }else{
        [sender setTitle:@"Done"];
    }
    [self.tableView setEditing:![self.tableView isEditing]];
}

- (IBAction)takePicture:(id)sender{
    
    if([self.popController isPopoverVisible]){
        [self.popController dismissPopoverAnimated:YES];
        self.popController = nil;
        return;
    }
    
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    if( [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera] ){
      
        [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    }else
    {
        [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
 
    }
    
    [imagePicker setAllowsEditing:TRUE];

    [imagePicker setDelegate:self];
    
    self.popController = [[UIPopoverController alloc]initWithContentViewController:imagePicker];
    
    [self.popController setDelegate:self];
    
    [self.popController presentPopoverFromBarButtonItem:sender permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    
    
}



-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    [self.popController dismissPopoverAnimated:YES];
    self.popController = nil;
    
    UIImage *image = [info objectForKey:UIImagePickerControllerEditedImage];
    [self.imageView setImage:image];
    
    NSData *imageData = UIImageJPEGRepresentation ( image, 1.0);
    
    
    NSString *fileName = [[NSString alloc] initWithFormat:@"%f.jpg", [[NSDate date] timeIntervalSince1970 ] ];

    [self.s3Util uploadData:imageData format:@"image/jpeg"
    bucketName:[Constants uploadBucket] withKey:fileName];
    
    
}

- (void)uploadDone:(NSError *)error
{
    if(error != nil){
        NSLog(@"Error: %@", error);
    }else
    {
        NSLog(@"File Uploaded");
        [self loadData];
    }
}



-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSLog(@"Table Data Count: %lu", (unsigned long)[self.tableData count]);
    return [self.tableData count];
}


-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    
    if(!cell){
        cell =
        [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UITableViewCell"];
    }
    NSString *fileName = [[NSString alloc] initWithFormat:@"%@",
                         [self.tableData objectAtIndex: indexPath.row ]];
    
    [[cell textLabel] setText: fileName];
    return cell;
}


- (void)tableView: (UITableView *)tableView didSelectRowAtIndexPath: (NSIndexPath *)indexPath
{

    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [self.tableData objectAtIndex: indexPath.row ]];
    
    NSData *downloadData = [self.s3Util downloadFromBucket:[Constants uploadBucket] withKey:fileName];
    
    if(downloadData){
        self.imageView.image = [UIImage imageWithData:downloadData];
    }
}


- (void) tableView: (UITableView *)tableView  commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString *fileName = [NSString stringWithFormat:@"%@",
                          [self.tableData objectAtIndex: indexPath.row ]];
    
    [self.s3Util deleteFromBucket:[Constants uploadBucket] withKey:fileName];
    [self loadData];
 }


@end
