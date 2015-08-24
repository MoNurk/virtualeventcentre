//
//  LoginCell.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 17/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface TextFieldCell : UITableViewCell {
    UITextField * cellTextField;
    UIButton * setDateButton;
}

@property (nonatomic, retain) IBOutlet UITextField * cellTextField;
@property (nonatomic, retain) IBOutlet UIButton * setDateButton;
@property (nonatomic, retain) IBOutlet UISwitch * adminLogin;
@property (nonatomic, retain) IBOutlet UILabel * adminTitle;

@end
