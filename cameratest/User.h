//
//  User.h
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>

@interface User : PFUser
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *email;
@property (strong, nonatomic) PFFile *profilePictureMedium;
@property (strong, nonatomic) PFFile *profilePictureSmall;
@property (strong, nonatomic) NSString *facebookID;
@property (strong, nonatomic) NSArray *facebookFriends;
@property (strong, nonatomic) NSString *channel;

@end
