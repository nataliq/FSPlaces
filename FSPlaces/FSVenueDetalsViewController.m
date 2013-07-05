//
//  ProfileSwipeView.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSVenueDetalsViewController.h"
#import "UIBarButtonItem+CustomBarButtonItem.h"
#import "FSConnectionManager.h"

@interface FSVenueDetalsViewController () <UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

- (IBAction)checkInButtonTapped:(id)sender;

@end

@implementation FSVenueDetalsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationController.navigationBarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    self.navigationItem.leftBarButtonItem = [UIBarButtonItem customBarButtonWithImageDefault:@"icon-back.png"
                                                                             imageHiglighted:nil target:self
                                                                                      action:@selector(popViewControllerAnimated)];
    
    [self.webView setDelegate:self];
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.venue.urlAddress]]];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)popViewControllerAnimated
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)checkInButtonTapped:(id)sender {
    [[FSConnectionManager sharedManager] checkInInVenue:self.venue];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self.activityIndicator stopAnimating];
}

@end
