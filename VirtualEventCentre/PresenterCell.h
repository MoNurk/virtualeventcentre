//
//  PresenterCell.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 06/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface PresenterCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIActivityIndicatorView * activityView;
@property (nonatomic, strong) IBOutlet UILabel * nameLabel;
@property (nonatomic, strong) IBOutlet UILabel * jobTitleLabel;
@property (nonatomic, strong) IBOutlet UIImageView * profileImageView;


@end
