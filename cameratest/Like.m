//
//  Like.m
//  CameraTest
//
//  Created by Aditya Narayan on 12/17/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import "Like.h"

@implementation Like
@dynamic didLike;
@dynamic numberOfLikes;
@dynamic photoID;
@dynamic userID;

+(NSString*) parseClassName
{
    return @"Like";
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
    PFQuery *query = [PFQuery queryWithClassName:[Like parseClassName]];
    [query includeKey:@"user"];
    [query orderByDescending:@"createdAt"];
    return query;
}

-(instancetype) initWithUserID:(NSString*)userID andPhotoID:(NSString*)photoID
{
    self = [super init];
    if (self) {
        self.userID = userID;
        self.photoID = photoID;
    }
    return self;
}

@end
