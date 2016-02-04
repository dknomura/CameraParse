//
//  Photo.m
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import "Photo.h"

@implementation Photo
@dynamic image;
@dynamic comment;
@dynamic user;
@dynamic numberOfLikes;

+(NSString*) parseClassName
{
    return @"Photo";
}

+(void) initialize
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self registerSubclass];
    });
}

+(PFQuery*) query
{
    PFQuery *query = [PFQuery queryWithClassName:[Photo parseClassName]];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    return query;
}

-(instancetype) initWithImage:(PFFile *)image comment:(NSString *)comment user:(PFUser *)user
{
    self = [super init];
    if (self) {
        self.image = image;
        self.comment = comment;
        self.user = user;
    }
    return self;
}


@end
