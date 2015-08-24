//
//  PresenterCell.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 06/09/2012.
//
//

#import "PresenterCell.h"

@implementation PresenterCell

@synthesize nameLabel;
@synthesize jobTitleLabel;
@synthesize profileImageView;
@synthesize activityView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
