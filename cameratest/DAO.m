//
//  DAO.m
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import "DAO.h"
#import "Like.h"
#import "Activity.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@implementation DAO



#pragma mark -Like methods. add/+-/get number of likes
-(void) addLikeForPhotoAtIndex:(NSUInteger)index
{
    Photo *photo = [self.photoObjects objectAtIndex:index];
    PFUser *user = [PFUser currentUser];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"photo" equalTo:photo];
    [query whereKey:@"type" equalTo:@"like"];
    [query whereKey:@"user" equalTo:user];

//    [query getFirstObjectInBackgroundWithBlock:^(PFObject * _Nullable object, NSError * _Nullable error) {
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error){
            NSLog(@"Error querying Parse Activity class: %@, %@", error.localizedDescription, error.userInfo);
        } else {
            if (objects.count == 0) {
                Activity *activity = [[Activity alloc] initWithPhoto:photo user:user comment:nil];
                activity.type = @"like";
                activity.didLike = TRUE;
                [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"error saving activity to Parse: %@", error.localizedDescription);
                    } else {
                        [self loadPhotoNames];
                        [self increaseNumberOfLikesForPhoto:photo];
                    }
                }];
            } else {
                PFObject *object = [objects objectAtIndex:0];
                BOOL userDidLike = [[object valueForKey:@"didLike"]boolValue];
                if (userDidLike == TRUE) {
                    [object setObject:[NSNumber numberWithBool:FALSE] forKey:@"didLike"];
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"error saving activity to Parse: %@", error.localizedDescription);
                        } else {
                            [self loadPhotoNames];
                            [self decreaseNumberOfLikesForPhoto:photo];

                        }
                    }];
//                } if (userDidLike == nil || userDidLike == FALSE){
                } if (userDidLike == FALSE){
                    [object setObject:[NSNumber numberWithBool:TRUE] forKey:@"didLike"];
                    [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
                        if (error) {
                            NSLog(@"error saving activity to Parse: %@", error.localizedDescription);
                        } else {
                            [self loadPhotoNames];
                            [self increaseNumberOfLikesForPhoto:photo];
                        }
                    }];
                }
            }
        }
    }];
}

-(void) increaseNumberOfLikesForPhoto:(Photo*)photo
{
    NSUInteger numberOfLikes = [[photo valueForKey:@"numberOfLikes"]intValue];
    numberOfLikes++;
    [photo setObject:[NSNumber numberWithInt:numberOfLikes] forKey:@"numberOfLikes"];
    [photo saveInBackground];
}

-(void) decreaseNumberOfLikesForPhoto:(Photo*)photo
{
    NSUInteger numberOfLikes = [[photo valueForKey:@"numberOfLikes"]intValue];;
    numberOfLikes--;
    [photo setObject:[NSNumber numberWithInt:numberOfLikes] forKey:@"numberOfLikes"];
    [photo saveInBackground];
}

-(NSUInteger) getNumberOfLikesForPhotoAtIndex:(NSUInteger) index
{
    NSString *photoID = [[self.photoObjects objectAtIndex:index] valueForKey:@"objectId"];
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query whereKey:@"objectId" equalTo:photoID];
    Photo *photo = (Photo*)[query getFirstObject];
    return [photo.numberOfLikes integerValue];
}

-(NSUInteger) getNumberOfLikesForPhoto:(PFObject*)object
{
    return [[object valueForKey:@"numberOfLikes"]intValue];
}

-(void) addComment:(NSString*)comment forPhotoAtIndex:(NSUInteger)index
{
    Photo *photo = [self.photoObjects objectAtIndex:index];
    Activity *activity = [[Activity alloc] initWithPhoto:photo user:[PFUser currentUser] comment:comment];
    activity.type = @"comment";
    [activity saveInBackground];
}

#pragma mark - photo methods. post/load/download/delete

-(void)postPhoto:(UIImage *)image name:(NSString *)name withComment:(NSString *)comment
{
    NSData *pictureData = UIImagePNGRepresentation(image);
    PFFile *file = [PFFile fileWithName:name data:pictureData];
    
    Photo *photo = [[Photo alloc] initWithImage:file comment:comment user:[PFUser currentUser]];
    [photo setObject:[NSNumber numberWithInt:0] forKey:@"numberOfLikes"];
    
    [photo saveInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error saving picture: %@, %@", error.localizedDescription, error.userInfo);
        }else {
            NSLog(@"Photo posted");
            [self loadPhotoNames];
//            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//            [notificationCenter postNotificationName:@"photo uploaded" object:self];
        }
    }];
}


-(void) loadPhotoNames
{
    PFQuery *query = [PFQuery queryWithClassName:@"Photo"];
    [query findObjectsInBackgroundWithBlock:^(NSArray * _Nullable objects, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error fetching Objects: %@, %@", error.localizedDescription, error.userInfo);
        }else {
            self.photoObjects = [NSMutableArray arrayWithArray:objects];
            self.tableData = [NSMutableDictionary new];
            self.dataObjects = [NSMutableArray new];
            
            for (PFObject *object in self.photoObjects){
                
                PFFile *file = [object objectForKey:@"image"];
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *data = [file getData];
                    [self.dataObjects addObject:data];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//                        [notificationCenter postNotificationName:@"photo names downloaded" object:self];
//                    });
                });
                NSMutableDictionary *photoData = [NSMutableDictionary dictionaryWithObject:[object objectForKey:@"user"] forKey:@"user"];
                
                NSMutableString *name = [NSMutableString stringWithString:file.name];
                [name deleteCharactersInRange:NSMakeRange(0, 42)];
                [photoData setObject:name forKey:@"name"];
                
                
                [photoData setObject:[object objectForKey:@"numberOfLikes"] forKey:@"numberOfLikes"];
                
                NSString *userDidLike = [self getDidLikeForPhoto:object];
                [photoData setObject: userDidLike forKey:@"userDidLike"];
                
                
                NSString *tableViewTitle = [NSString stringWithFormat:@"User: %@. photo: %@.", [self getUserNameForPhoto:object], name];
                [photoData setObject:tableViewTitle forKey:@"cell title"];
                                            
                NSString *detailText = [NSString stringWithFormat:@"likes:%@, didlike?:%@", [object objectForKey:@"numberOfLikes"], userDidLike];
                [photoData setObject:detailText forKey:@"cell detail text"];
                
                [self.tableData setObject:photoData forKey:object.objectId];
            }
            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
            [notificationCenter postNotificationName:@"photo names downloaded" object:self];
        }
    }];
}

-(NSString*)getUserNameForPhoto:(PFObject*)object
{
    PFUser *user = [object objectForKey:@"user"];
    NSString *userName;
    if (user.authenticated) {
        userName = @"You";
    } else{
        return @"Not You";
    }
    
    //    if (![user objectForKey:@"authData"]){
//        userName = [user objectForKey:@"name"];
//    } else{
//        userName = [user objectForKey:@"username"];
//    }
    return userName;
}

-(NSString*)getDidLikeForPhoto:(PFObject*)object
{
    NSString *didLike;
    PFQuery *query = [PFQuery queryWithClassName:@"Activity"];
    [query whereKey:@"photo" equalTo:object];
    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    int didLikeBool = [[[query getFirstObject]objectForKey:@"didLike"] boolValue];
    if (didLikeBool) {
        didLike = @"yes";
    }else{
        didLike = @"no";
    }
    return didLike;
}


#pragma mark - Methods for ViewController at Index

-(NSString*) getTableCellTitleForPhotoAtIndex:(NSUInteger) index
{
    PFObject *object = [self.photoObjects objectAtIndex:index];
    NSString *title = [[self.tableData objectForKey:object.objectId] objectForKey:@"cell title"];
    return title;
}

-(NSString*) getTCDetailedTextForPhotoAtIndex:(NSUInteger) index
{
    PFObject *object = [self.photoObjects objectAtIndex:index];
    NSString *text = [[self.tableData objectForKey:object.objectId] objectForKey:@"cell detail text"];
    return text;
}



-(NSData*) downloadPhotoAtIndex:(NSInteger) index
{
//    PFFile *file = [self.dataObjects objectAtIndex:index];
    return [self.dataObjects objectAtIndex:index];
}

-(void) deletePhotoAtIndex:(NSInteger)index
{
    PFObject *object = [self.photoObjects objectAtIndex:index];
//    [object delete];
    [object deleteInBackgroundWithBlock:^(BOOL succeeded, NSError * _Nullable error) {
        if (!error) {
//            NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
//            [notificationCenter postNotificationName:@"photo deleted" object:self];
        } else{
            NSLog(@"Error deleting photo: %@, %@", error.localizedDescription, error.userInfo);
        }
    }];
//    [self.tableData removeObjectForKey:object];
}

#pragma mark - facebook set FB name methods
//-(void)runGraphRequestToSetNameForFBUser:(PFUser*)user
//{
//    NSDictionary *graphRequestDictionary = [NSDictionary dictionaryWithObject:@"name"forKey:@"fields"]; 
//    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:graphRequestDictionary] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
//        if (!error){
//            NSLog(@"fetched user: %@", result);
//            NSString *userName = [result objectForKey:@"name"];
//            [user setObject:userName forKey:@"name"];
//            [user saveInBackground];
//        } else {
//            NSLog(@"Error with graph request for user info: %@, %@", error.localizedDescription, error.userInfo);
//        }
//    }];
//}



+(instancetype) sharedInstance
{
    static DAO *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DAO alloc] init];
    });
    return _sharedInstance;
}
@end
