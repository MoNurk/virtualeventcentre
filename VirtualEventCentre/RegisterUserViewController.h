//
//  RegisterUserViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 15/09/2012.
//
//

#import <UIKit/UIKit.h>

@interface RegisterUserViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    NSString* username;
    NSString* password;
    NSString* confirmPassword;
    
    UITableView * myTableView;
    
    CGPoint originalCenter;
}

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;
@property (nonatomic, retain) NSString* confirmPassword;

@property CGPoint originalCenter; 

@property (nonatomic, retain) IBOutlet UITableView * myTableView;

- (IBAction)registerUser:(id)sender;
- (IBAction) updateUserDetails:(id)sender;

@end
