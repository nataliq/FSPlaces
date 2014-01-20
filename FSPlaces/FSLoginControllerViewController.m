//
//  FSLoginControllerViewController.m
//  FSPlaces
//
//  Created by Natalia Patsovska on 1/20/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSLoginControllerViewController.h"
#import "FSConnectionManager.h"
#import "FSLocationManager.h"
#import "UIAlertView+FSAlerts.h"
#import <FSOAuth.h>

@interface FSLoginControllerViewController () <UIWebViewDelegate>

@property (strong, nonatomic) UIWebView *webView;

- (IBAction)loginInWebViewButtonTapped:(id)sender;
- (IBAction)loginInFacebookAppButtonTapped:(id)sender;

@end

@implementation FSLoginControllerViewController;

static BOOL locationEnabled = NO;

#pragma mark - Initialization
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(locationEnabled) name:FSNotificationLocationServicesAreEnabled object:nil];
    [FSLocationManager sharedManager];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    if ([[FSConnectionManager sharedManager] isActive] && [[FSLocationManager sharedManager] getCurrentLocation] != nil) {
        [self showPlacesController];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)authenticationRequestResolved
{
    if (locationEnabled && [[FSLocationManager sharedManager] getCurrentLocation] != nil) {
        [self showPlacesController];
    }
    else {
        [[UIAlertView alertWithMessage:@"Please enable your location services and try again."] show];
    }
}

- (void)showPlacesController
{
    UIViewController *placesController = [self.storyboard instantiateViewControllerWithIdentifier:@"PlacesController"];
    [self.navigationController pushViewController:placesController animated:YES];
}

#pragma mark - Login actions
- (IBAction)loginInWebViewButtonTapped:(id)sender {
    self.webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
    self.webView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.webView.delegate = self;
    self.webView.opaque = NO;
    self.webView.backgroundColor = [UIColor clearColor];
    [self.webView loadRequest:[[FSConnectionManager sharedManager] tokenRequest]];
    
    [self.view addSubview:self.webView];
}

- (IBAction)loginInFacebookAppButtonTapped:(id)sender {
#if TARGET_IPHONE_SIMULATOR
    [[UIAlertView alertWithMessage:@"You can't use this option running on iOS Simulator."] show];
#else
    FSOAuthStatusCode statusCode = [FSOAuth authorizeUserUsingClientId:[[FSConnectionManager sharedManager] clientID]
                                                     callbackURIString:[[FSConnectionManager sharedManager] callbackURI]];
    NSString *alertMessage = nil;
    switch (statusCode) {
        case FSOAuthStatusSuccess:
            [self authenticationRequestResolved];
            break;
        case FSOAuthStatusErrorFoursquareNotInstalled:
            alertMessage = @"You don't have Foursquare application installed";
        default:
            alertMessage = @"Can't login to Foursquare";
            break;
    }
    if (alertMessage) {
        [UIAlertView alertWithMessage:alertMessage] show];
    }
#endif
}

#pragma mark - Web view delegate
- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.scheme isEqualToString:@"fsplaces"]) {
        BOOL success = [[FSConnectionManager sharedManager] extractTokenFromResponseURL:request.URL];
        if (success) {
            [webView removeFromSuperview];
            self.webView = nil;
            [self authenticationRequestResolved];
        }
        [UIAlertView loginFailureAlert];
        return NO;
    }
    return YES;
}

#pragma mark - Notification observers

- (void)locationEnabled
{
    locationEnabled = YES;
}

@end
