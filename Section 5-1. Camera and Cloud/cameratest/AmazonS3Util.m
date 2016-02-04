//
//  AmazonS3Util.m
//  CameraTest
//
//  Created by Aditya on 08/11/13.
//  Copyright (c) 2013 Aditya. All rights reserved.
//

#import "AmazonS3Util.h"
#import <AWSRuntime/AWSRuntime.h>

@implementation AmazonS3Util


-(id)initWithAccessKey:(NSString*)accessKey secretKey:(NSString*)secretKey bucket:(NSString*)bucket delegate:(id)delegate
{
    self = [super init];
    
    // Initial the S3 Client.
    _amazonS3Client = [[AmazonS3Client alloc] initWithAccessKey:accessKey withSecretKey:secretKey];
    _delegate = delegate;
    
    // Create Bucket.
    S3CreateBucketRequest *request = [[S3CreateBucketRequest alloc] initWithName:bucket ];
    S3CreateBucketResponse *response = [self.amazonS3Client createBucket:request];
    if(response.error != nil)
    {
        NSLog(@"Error: %@", response.error);
    }
    
    return self;
}



-(NSArray*)listFromBucket:(NSString*)bucketName
{
    @try{
        S3ListObjectsRequest *req = [[S3ListObjectsRequest alloc] initWithName: bucketName ];
        S3ListObjectsResponse *resp = [self.amazonS3Client listObjects:req];
        NSMutableArray* objectSummaries = resp.listObjectsResult.objectSummaries;
        return [[NSArray alloc] initWithArray: objectSummaries];
    }@catch (NSException *exception) {
        NSLog(@"Cannot list S3 %@",exception);
        return [[NSArray alloc]init];
    }
    
}

-(NSData*)downloadFromBucket:(NSString*)bucketName withKey: (NSString*) key
{
    @try{
        S3GetObjectRequest *request = [[S3GetObjectRequest alloc]
                                       initWithKey:key withBucket:bucketName];
        S3GetObjectResponse *response = [self.amazonS3Client getObject:request];
        return [response body];
    }@catch (NSException *exception) {
        NSLog(@"Cannot Load S3 Object %@",exception);
        return  nil;
    }
    
}

-(void)uploadData:(NSData*)data format:(NSString*)format
         bucketName:(NSString*)bucketName withKey: (NSString*) key
{
    S3PutObjectRequest *obRequest = [[S3PutObjectRequest alloc] initWithKey:key
                                                             inBucket:bucketName ];
    obRequest.contentType = format;
    obRequest.data = data;
    S3PutObjectResponse *putObjectResponse =
    [self.amazonS3Client putObject:obRequest];
    [self performSelectorOnMainThread:@selector( uploadDone: )
                           withObject:putObjectResponse.error waitUntilDone:NO];
    
}

- (void)uploadDone:(NSError *)error
{
    @try{
    [[self delegate] uploadDone:error];
    }@catch (NSException *exception) {
        NSLog(@"uploadDone Exception : %@",exception);
    }
}


-(BOOL)deleteFromBucket:(NSString*)bucketName withKey:(NSString*)key
{
    @try{
        [self.amazonS3Client deleteObjectWithKey:key withBucket:bucketName];
        return TRUE;
    }@catch (NSException *exception) {
        NSLog(@"Cannot Delete S3 Object %@",exception);
        return FALSE;
    }
}

- (void)dealloc {
    self.amazonS3Client = nil;
    self.delegate = nil;
    NSLog(@"Deallocation Done");
}

@end
