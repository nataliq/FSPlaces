//
//  FSVenueCell.m
//  FSPlaces
//
//  Created by Nataliya Patsovska on 1/23/14.
//  Copyright (c) 2014 MMAcademy. All rights reserved.
//

#import "FSVenueCell.h"
#import "FSVenue.h"
#import <AFNetworking/UIImageView+AFNetworking.h>

@interface FSVenueCell ()

@property (weak, nonatomic) IBOutlet UIImageView *categoryImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;

@end

@implementation FSVenueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)configureWithVenue:(FSVenue *)venue
{
    self.nameLabel.text = venue.name;
    NSString *distance = @"";
    if (venue.distance != 0) {
        distance = [distance stringByAppendingFormat:@"%.1f m", venue.distance];
    }
    self.distanceLabel.text = distance;
    FSCategory *primaryCategory = venue.primaryCategory;
    if (primaryCategory) {
        [self.categoryImageView setImageWithURL:[NSURL URLWithString:primaryCategory.photoURL]];
        self.categoryNameLabel.text = venue.categoriesNames;
    }
    
}

@end
