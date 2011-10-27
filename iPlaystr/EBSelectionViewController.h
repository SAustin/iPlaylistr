//
//  EBViewController.h
//  iPlaystr
//
//  Created by Scott Austin on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "EBLastFMManager.h"
#import "EBRdioManager.h"

@interface EBSelectionViewController : UIViewController <UITextFieldDelegate>
{
    UITextField *artistName;
    UITextField *songName;
    UITextField *numberOfResults;
    UIButton    *searchButton;
    EBLastFMManager *fmManager;
    EBRdioManager *rdioManager;
}

@property (nonatomic, strong) IBOutlet UITextField *artistName;
@property (nonatomic, strong) IBOutlet UITextField *songName;
@property (nonatomic, strong) IBOutlet UITextField *numberOfResults;
@property (nonatomic, strong) IBOutlet UIButton *searchButton;
@property (nonatomic, strong) EBLastFMManager *fmManager;
@property (nonatomic, strong) EBRdioManager *rdioManager;

-(IBAction)searchButtonWasPressed:(id)sender;

@end
