//
//  Wrapper.m
//  WrapperTest
//
//  Created by Adrian on 10/18/08.
//  Copyright 2008 Adrian Kosmaczewski. All rights reserved.
//

#import "EBRESTWrapper.h"

@interface EBRESTWrapper (Private)
- (void)startConnection:(NSURLRequest *)request;
@end

@implementation EBRESTWrapper

@synthesize receivedData;
@synthesize asynchronous;
@synthesize mimeType;
@synthesize username;
@synthesize password;
@synthesize delegate;

#pragma mark -
#pragma mark Constructor

- (id)init
{
    return [self initWithDelegate:nil];
}

-(id)initWithDelegate:(id<EBRESTWrapperDelegate>) theDelegate
{
    if (self = [super init])
    {
        receivedData = [[NSMutableData alloc] init];
        conn = nil;
        
        asynchronous = YES;
        mimeType = @"text/html";
        delegate = theDelegate;
        username = @"";
        password = @"";
    }
    
    return self;
}

#pragma mark -
#pragma mark Public methods

- (void)sendRequestTo:(NSURL *)url usingVerb:(NSString *)verb withParameters:(NSDictionary *)parameters
{
    NSData *body = nil;
    NSMutableString *params = nil;
    NSString *contentType = @"text/html; charset=utf-8";
    NSURL *finalURL = url;
    if (parameters != nil)
    {
        params = [[NSMutableString alloc] init];
        for (id key in parameters)
        {
            NSString *encodedKey = [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            CFStringRef value = (__bridge CFStringRef)[parameters objectForKey:key];
            // Escape even the "reserved" characters for URLs 
            // as defined in http://www.ietf.org/rfc/rfc2396.txt
            CFStringRef encodedValue = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, 
                                                                               value,
                                                                               NULL, 
                                                                               (CFStringRef)@";/?:@&=+$,", 
                                                                               kCFStringEncodingUTF8);
            [params appendFormat:@"%@=%@&", encodedKey, encodedValue];
            CFRelease(value);
            CFRelease(encodedValue);
        }
        [params deleteCharactersInRange:NSMakeRange([params length] - 1, 1)];
    }
    
    if ([verb isEqualToString:@"POST"] || [verb isEqualToString:@"PUT"])
    {
        contentType = @"application/x-www-form-urlencoded; charset=utf-8";
        body = [params dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        if (parameters != nil)
        {
            NSString *urlWithParams = [[url absoluteString] stringByAppendingFormat:@"?%@", params];
            finalURL = [NSURL URLWithString:urlWithParams];
        }
    }
    
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    [headers setValue:contentType forKey:@"Content-Type"];
    [headers setValue:mimeType forKey:@"Accept"];
    [headers setValue:@"no-cache" forKey:@"Cache-Control"];
    [headers setValue:@"no-cache" forKey:@"Pragma"];
    [headers setValue:@"close" forKey:@"Connection"]; // Avoid HTTP 1.1 "keep alive" for the connection
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:finalURL
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:verb];
    [request setAllHTTPHeaderFields:headers];
    if (parameters != nil)
    {
        [request setHTTPBody:body];
    }
    [self startConnection:request];
}

- (void)uploadData:(NSData *)data toURL:(NSURL *)url
{
    // File upload code adapted from http://www.cocoadev.com/index.pl?HTTPFileUpload
    // and http://www.cocoadev.com/index.pl?HTTPFileUploadSample
    
    NSString* stringBoundary = [NSString stringWithString:@"0xKhTmLbOuNdArY"];
    
    NSMutableDictionary* headers = [[NSMutableDictionary alloc] init];
    [headers setValue:@"no-cache" forKey:@"Cache-Control"];
    [headers setValue:@"no-cache" forKey:@"Pragma"];
    [headers setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", stringBoundary] forKey:@"Content-Type"];
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:url
                                                           cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                       timeoutInterval:60.0];
    [request setHTTPMethod:@"POST"];
    [request setAllHTTPHeaderFields:headers];
    
    NSMutableData* postData = [NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[@"Content-Disposition: form-data; name=\"image\"; filename=\"test.bin\"\r\n\r\n" 
                          dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
    
    [self startConnection:request];
}

- (void)cancelConnection
{
    [conn cancel];
    conn = nil;
}

- (NSDictionary *)responseAsPropertyList
{
    NSString *errorStr = nil;
    NSPropertyListFormat format;
    NSDictionary *propertyList = [NSPropertyListSerialization propertyListFromData:receivedData
                                                                  mutabilityOption:NSPropertyListImmutable
                                                                            format:&format
                                                                  errorDescription:&errorStr];
    return propertyList;
}

- (NSString *)responseAsText
{
    return [[NSString alloc] initWithData:receivedData 
                                 encoding:NSUTF8StringEncoding];
}

#pragma mark -
#pragma mark Private methods

- (void)startConnection:(NSURLRequest *)request
{
    if (asynchronous)
    {
        [self cancelConnection];
        conn = [[NSURLConnection alloc] initWithRequest:request
                                               delegate:self
                                       startImmediately:YES];
        
        if (!conn)
        {
            NSMutableDictionary* info = [NSMutableDictionary dictionaryWithObject:[request URL] 
                                                                               forKey:NSURLErrorFailingURLStringErrorKey];
            [info setObject:@"Could not open connection" 
                     forKey:NSLocalizedDescriptionKey];
            NSError* error = [NSError errorWithDomain:@"Wrapper" 
                                                 code:1 
                                             userInfo:info];
            [delegate wrapper:self 
             didFailWithError:error];
        }
    }
    else
    {
        NSURLResponse* response = [[NSURLResponse alloc] init];
        NSError* error = [[NSError alloc] init];
        NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
        [receivedData setData:data];
        response = nil;
        error = nil;
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection 
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    NSInteger count = [challenge previousFailureCount];
    if (count == 0)
    {
        NSURLCredential* credential = [NSURLCredential credentialWithUser:username
                                                                 password:password
                                                              persistence:NSURLCredentialPersistenceNone];
        [[challenge sender] useCredential:credential 
               forAuthenticationChallenge:challenge];
    }
    else
    {
        [[challenge sender] cancelAuthenticationChallenge:challenge];
        [delegate wrapperHasBadCredentials:self];
    }
}

- (void)connection:(NSURLConnection *)connection 
didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int statusCode = [httpResponse statusCode];
    switch (statusCode)
    {
        case 200:
            break;
            
        case 201:
        {
            NSString* url = [[httpResponse allHeaderFields] objectForKey:@"Location"];
            [delegate wrapper:self didCreateResourceAtURL:url];
            break;
        }
            
            // Here you could add more status code handling... for example 404 (not found),
            // 204 (after a PUT or a DELETE), 500 (server error), etc... with the
            // corresponding delegate methods called as required.
            
        default:
        {
            [delegate wrapper:self didReceiveStatusCode:statusCode];
            break;
        }
    }
    [receivedData setLength:0];
}

- (void)connection:(NSURLConnection *)connection 
    didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
    [self cancelConnection];
    [delegate wrapper:self 
     didFailWithError:error];

}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self cancelConnection];
    [delegate wrapper:self 
      didRetrieveData:receivedData];

}

@end