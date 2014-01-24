//
//  FSCategoriesController.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSCategoriesController.h"
#import "FSMediator.h"

@interface FSCategoriesController ()

- (IBAction)cancelButtonTapped:(id)sender;

@end

@implementation FSCategoriesController

static NSString *StoryboardIdentifier = @"CategoriesTable";

+ (NSString *)storyboardIdentifier
{
    return StoryboardIdentifier;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.tableView.dataSource = self.dataSource;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        [[FSMediator sharedMediator] showVenuesToRecommend];
    }];
}

#pragma mark - Navigation bar delegate
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
    
@end