//
//  Comment.h
//  CameraTest
//
//  Created by Aditya Narayan on 12/17/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>
#import "Photo.h"

@interface Activity : PFObject <PFSubclassing>
@property (strong, nonatomic) Photo *photo;
@property (nonatomic, strong) PFUser *user;
@property (nonatomic, strong) NSString *comment;
@property (nonatomic) BOOL didLike;
@property (nonatomic, strong) NSString *type;

+(NSString*) parseClassName;
+(void) initialize;
+(PFQuery*) query;
-(instancetype) initWithPhoto:(Photo*)photo user:(PFUser*)user comment:(NSString *)comment;

@end
