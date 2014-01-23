//
//  CategoriesDataSource.h
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CategoriesDataSource : NSObject <UITableViewDataSource>


- (instancetype)initWithCategoriesDictionary:(NSDictionary *)categoriesDictionary;

@end
