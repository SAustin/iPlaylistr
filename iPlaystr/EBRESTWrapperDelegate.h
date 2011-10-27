//
//  WrapperDelegate.h
//  WrapperTest
//
//  Created by Adrian on 10/18/08.
//  Copyright 2008 Adrian Kosmaczewski. All rights reserved.
//

#import <Foundation/Foundation.h> 

@class EBRESTWrapper;

@protocol EBRESTWrapperDelegate

@required
- (void)wrapper:(EBRESTWrapper *)wrapper didRetrieveData:(NSData *)data;

@optional
- (void)wrapperHasBadCredentials:(EBRESTWrapper *)wrapper;
- (void)wrapper:(EBRESTWrapper *)wrapper didCreateResourceAtURL:(NSString *)url;
- (void)wrapper:(EBRESTWrapper *)wrapper didFailWithError:(NSError *)error;
- (void)wrapper:(EBRESTWrapper *)wrapper didReceiveStatusCode:(int)statusCode;

@end