//
//  EBViewController.m
//  iPlaystr
//
//  Created by Scott Austin on 10/19/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "EBSelectionViewController.h"

@implementation EBSelectionViewController
@synthesize searchButton, artistName, songName, numberOfResults;
@synthesize fmManager, rdioManager;

-(IBAction)searchButtonWasPressed:(id)sender
{
    if (![artistName.text isEqualToString:@""]) 
    {
        [fmManager getMBIDforArtist:artistName.text];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    fmManager = [[EBLastFMManager alloc] init];
    rdioManager = [[EBRdioManager alloc] init];
    artistName.delegate = self;
    songName.delegate = self;
    numberOfResults.delegate = self;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

-(BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end
