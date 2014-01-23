//
//  FSVenueCell.h
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FSVenue;

@interface FSVenueCell : UITableViewCell

- (void)configureWithVenue:(FSVenue *)venue;

@end
