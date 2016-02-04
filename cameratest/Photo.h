//
//  Photo.h
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "User.h"
#import <Parse.h>

@interface Photo : PFObject <PFSubclassing>
@property (strong, nonatomic) PFFile *image;
@property (strong, nonatomic) NSString *comment;
@property (strong, nonatomic) PFUser *user;
@property (nonatomic, strong) NSNumber *numberOfLikes;

+(NSString*) parseClassName;
+(void) initialize;
+(PFQuery*) query;
-(instancetype)initWithImage:(PFFile*)image comment:(NSString*)comment user:(PFUser*)user;
//-(void) savePhoto;


@end
