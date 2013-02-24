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

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate name:(NSString *)name andCategoryNames:(NSArray *)names
{
    self = [super init];
    if (self) {
        _name = name;
        _categoryNames = names;
        _coordinate = coordinate;
        _title = _name;
        
        if (_categoryNames) {
            NSMutableString *subtitleString = [NSMutableString string];
            for (NSString *name in _categoryNames) {
                [subtitleString appendFormat:@"%@, ", name];
            }
            if (subtitleString.length>0) {
                _subtitle = [subtitleString substringToIndex:subtitleString.length-2];
            }
        }
    }
    return self;
}

@end
