//
//  LastFMManager.h
//  iPlaystr
//
//  Created by Scott Austin on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EBRESTWrapper.h"

#define api_key @"d838233066d52d287b9e18443c17439d"
#define secret_key @"fcfc51b845bb3166d9190bf8d9584f7d"

@interface EBLastFMManager : NSObject <EBRESTWrapperDelegate>
{
}

-(void)getMBIDforArtist:(NSString *)artistName;

@end
