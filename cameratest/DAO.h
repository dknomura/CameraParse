//
//  DAO.h
//  CameraTest
//
//  Created by Aditya Narayan on 12/14/15.
//  Copyright © 2015 Aditya. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse.h>
#import "User.h"
#import "Photo.h"
#import "Activity.h"

@interface DAO : NSObject
@property (strong, nonatomic) NSMutableDictionary *tableData;
@property (strong, nonatomic) NSMutableArray *photoObjects;
@property (strong, nonatomic) NSMutableArray *dataObjects;
//@property (strong, nonatomic) id <photoUploadDAODelegate> delegate;

-(void)postPhoto:(UIImage *)image name:(NSString*)name withComment:(NSString*)comment;
-(void)loadPhotoNames;
-(NSData*) downloadPhotoAtIndex:(NSInteger) index;
-(void) deletePhotoAtIndex:(NSInteger)index;
-(void) addComment:(NSString*)comment forPhotoAtIndex:(NSUInteger)index;
-(void) addLikeForPhotoAtIndex:(NSUInteger)index;
-(NSUInteger) getNumberOfLikesForPhotoAtIndex:(NSUInteger) index;
-(NSString*) getTableCellTitleForPhotoAtIndex:(NSUInteger) index;
-(NSString*) getTCDetailedTextForPhotoAtIndex:(NSUInteger) index;


//-(void)runGraphRequestToSetNameForFBUser:(PFUser*)user;


+(instancetype) sharedInstance;

@end


//@protocol photoUploadDAODelegate <NSObject>
//
//-(void)daoDidFinishPhotoUpload;
//
//@end