//
//  Like.h
//  CameraTest
//
//  Created by Aditya Narayan on 12/17/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>

@interface Like : PFObject <PFSubclassing>
@property (nonatomic) BOOL didLike;
@property (nonatomic) NSUInteger numberOfLikes;
@property (nonatomic, strong) NSString *userID;
@property (nonatomic, strong) NSString *photoID;

+(NSString*) parseClassName;
+(void) initialize;
+(PFQuery*) query;
-(instancetype) initWithUserID:(NSString*)userID andPhotoID:(NSString*)photoID;
@end
