//
//  LoginCell.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 17/09/2012.
//
//

#import "TextFieldCell.h"

@implementation TextFieldCell

@synthesize cellTextField, adminLogin, adminTitle, setDateButton;

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
