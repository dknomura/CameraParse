//
//  AmazonS3Util.h
//  CameraTest
//
//  Created by Aditya on 08/11/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import <AWSS3/AWSS3.h>

@interface AmazonS3Util : NSObject

@property (nonatomic, retain) AmazonS3Client *amazonS3Client;
@property (nonatomic, retain) id delegate;

-(id)initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey bucket:(NSString*)bucket delegate:(id)delegate;

-(NSArray*)listFromBucket:(NSString*)bucketName;

-(NSData*)downloadFromBucket:(NSString*)bucketName withKey: (NSString*) key;

-(void)uploadData:(NSData*)data format:(NSString*)format
         bucketName:(NSString*)bucketName withKey: (NSString*) key;

-(BOOL)deleteFromBucket:(NSString*)bucketName withKey:(NSString*)key;

@end
