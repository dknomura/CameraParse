//
//  Comment.m
//  CameraTest
//
//  Created by Aditya Narayan on 12/17/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import "Activity.h"

@implementation Activity
@dynamic photo;
@dynamic comment;
@dynamic user;
@dynamic didLike;
@dynamic type;

+(NSString*) parseClassName
{
    return @"Activity";
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
    PFQuery *query = [PFQuery queryWithClassName:[Activity parseClassName]];
    [query includeKey:@"photoID"];
    [query orderByDescending:@"createdAt"];
    return query;
}

-(instancetype) initWithPhoto:(Photo *)photo user:(PFUser *)user comment:(NSString *)comment
{
    self = [super init];
    if (self) {
        self.comment = comment;
        self.photo = photo;
        self.user = user;
    }
    return self;
}


@end
