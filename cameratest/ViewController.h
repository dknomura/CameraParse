//
//  ViewController.h
//  CameraTest
//
//  Created by Aditya on 02/10/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AmazonS3Util.h"
#import "Constants.h"

@interface ViewController : UIViewController
<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIPopoverPresentationControllerDelegate,
UITableViewDelegate, UITableViewDataSource>

@property(strong,nonatomic)NSString *urlStr;
@property(strong,nonatomic)UIPopoverPresentationController *popController;
@property(strong,nonatomic)NSArray *tableData;

@property (nonatomic, retain) AmazonS3Util *s3Util;
@property (nonatomic,weak) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *barButtonCameraItem;

- (void)loadData;
- (IBAction)takePicture:(id)sender;
- (IBAction)edit:(id)sender;



@end
