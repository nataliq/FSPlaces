//
//  FSVenueAnnotation.m
//  FSPlaces
//
//  Created by Nataliya P. on 2/24/13.
//  Copyright (c) 2013 MMAcademy. All rights reserved.
//

#import "FSVenueAnnotation.h"

@interface FSVenueAnnotation ()

@end

@implementation FSVenueAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate name:(NSString *)name url:(NSString *)url andCategoryNames:(NSString *)names
{
    self = [super init];
    if (self) {
        _name = name;
        _categoryNames = names;
        _url = url;
        _coordinate = coordinate;
        _title = _name;
        
        _subtitle = names;
        
    }
    return self;
}

@end
