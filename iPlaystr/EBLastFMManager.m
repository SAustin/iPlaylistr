//
//  LastFMManager.m
//  iPlaystr
//
//  Created by Scott Austin on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EBLastFMManager.h"

@implementation EBLastFMManager

-(void)getMBIDforArtist:(NSString *)artistName
{
    artistName = [artistName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSArray *parameterKeys = [NSArray arrayWithObjects:@"method", @"artist", @"autocorrect", @"api_key", @"format", nil];
    NSArray *parameterValues = [[NSArray alloc] initWithObjects:@"artist.getInfo", artistName, @"1", api_key, @"json", nil];
    
    NSDictionary *parameters = [[NSDictionary alloc] initWithObjects:parameterValues 
                                                             forKeys:parameterKeys];
    NSURL *scrobbleURL = [[NSURL alloc] initWithString:@"http://ws.audioscrobbler.com/2.0/"];
    
    EBRESTWrapper *getArtistWrapper = [[EBRESTWrapper alloc] initWithDelegate:self];
    
    [getArtistWrapper sendRequestTo:scrobbleURL
                          usingVerb:@"GET" 
                     withParameters:parameters];

}


-(void)wrapper:(EBRESTWrapper *)wrapper didRetrieveData:(NSData *)data
{
    NSString *response = [[NSString alloc] initWithData:data 
                                               encoding:NSUTF8StringEncoding];
    NSError *jsonError = nil;
    NSDictionary *responseData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];

    NSDictionary *artistInformation = [responseData objectForKey:@"artist"];
    NSString *mbid = [artistInformation objectForKey:@"mbid"];
    NSDictionary *similarArtists = [[artistInformation objectForKey:@"similar"] objectForKey:@"artist"];
    
    for (NSDictionary *artist in similarArtists) 
    {
        NSString *similarArtistName = [artist valueForKey:@"name"];
    }
    
    UIAlertView *dataReceived = [[UIAlertView alloc] initWithTitle:@"Success" 
                                                           message:@"Data was received from last.fm" 
                                                          delegate:nil 
                                                 cancelButtonTitle:@"Ok" 
                                                 otherButtonTitles: nil];
    [dataReceived show];
}

@end
