//
//  CategoriesDataSource.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "CategoriesDataSource.h"
#import "FSCategory.h"

@interface CategoriesDataSource ()

@property (strong, nonatomic) NSArray *categories;
@property (strong, nonatomic) NSDictionary *beenHereCountByIds;

@end

@implementation CategoriesDataSource

static NSString *CellIdentifier = @"CategoryWithCountCell";

- (instancetype)initWithCategoriesDictionary:(NSDictionary *)categoriesDictionary
{
    self = [super init];
    if (self) {
        self.beenHereCountByIds = categoriesDictionary[@"counts"];
        NSArray *categories = categoriesDictionary[@"names"];
        
        self.categories = [categories sortedArrayUsingComparator:^NSComparisonResult(FSCategory *category1, FSCategory *category2) {
            int first = [self.beenHereCountByIds[category1.identifier] integerValue];
            int second = [self.beenHereCountByIds[category2.identifier] integerValue];
            
            if ( first < second ) {
                return (NSComparisonResult)NSOrderedDescending;
            } else if ( first > second ) {
                return (NSComparisonResult)NSOrderedAscending;
            } else {
                return (NSComparisonResult)NSOrderedSame;
            }
        }];
        
    }
    return self;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.categories.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    FSCategory *category = self.categories[indexPath.row];
    cell.textLabel.text = category.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ times", self.beenHereCountByIds[category.identifier]];
    
    return cell;
}

@end
