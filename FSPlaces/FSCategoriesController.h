//
//  FSCategoriesController.h
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoriesDataSource.h"

@interface FSCategoriesController : UIViewController <UINavigationBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) CategoriesDataSource *dataSource;

+ (NSString *)storyboardIdentifier;



@end
