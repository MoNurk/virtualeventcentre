//
//  LoginViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 15/09/2012.
//
//

#import <UIKit/UIKit.h>

@class LoginViewController;

@protocol LoginViewControllerDelegate <NSObject>

@optional

- (void)myModalViewControllerDidFinishLogin:(LoginViewController *)controller;

@end


@interface LoginViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> {
    
    id <LoginViewControllerDelegate> delegate;
   
    CGPoint originalCenter;
    
    UILabel* userLabel;
    
    UITextField* usernameLabel;
    UITextField* passwordLabel;
    
    NSString* username;
    NSString* password;
    
    UIButton* loginButton;
    
    UITableView *myTableView;
    
    UISwitch * switchView;
    
    UIActivityIndicatorView * activityIndicator;
}

@property (assign) id <LoginViewControllerDelegate> delegate;

@property CGPoint originalCenter; 

@property (nonatomic, retain) NSString* username;
@property (nonatomic, retain) NSString* password;

@property (nonatomic, retain) IBOutlet UILabel* userLabel; 

@property (nonatomic, retain) IBOutlet UITextField* usernameLabel;
@property (nonatomic, retain) IBOutlet UITextField* passwordLabel;

@property (nonatomic, retain) IBOutlet UIButton* loginButton;

@property (nonatomic, retain) IBOutlet UITableView* myTableView;

@property (nonatomic, retain) IBOutlet UISwitch * switchView;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView * activityIndicator;

- (IBAction) signIn:(id)sender;
- (IBAction) goToRegisterView:(id)sender;
- (IBAction) updateUserDetails:(id)sender;

@end
