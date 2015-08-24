//
//  EventViewController.h
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 28/08/2012.
//
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "EventDetailViewController.h"
#import "AddEventViewController.h"
#import "LoginViewController.h"
#import "Session.h"

@interface EventViewController : UIViewController <LoginViewControllerDelegate, UITableViewDataSource, UITableViewDelegate, UITabBarControllerDelegate> {
    
    UIRefreshControl * refreshControl;
    
    int eventIdToSend;
    
    UITableView* eventTable;
    
    Event* event;
    Event* eventToSend;
    
    NSMutableArray *tempEventsArray;
    NSMutableArray *events;
    
    NSMutableArray *sessions;
    
    UIActivityIndicatorView* busyIndicator;
}
@property (nonatomic) int eventIdToSend;

@property (nonatomic, retain) IBOutlet UIRefreshControl * refreshControl;

@property (nonatomic, retain) IBOutlet UITableView* eventTable;

@property (nonatomic, retain) Event* event;
@property (nonatomic, retain) Event* eventToSend;

@property (nonatomic, retain) NSMutableArray *tempEventsArray;
@property (nonatomic, retain) NSMutableArray *events;

@property (nonatomic, retain) IBOutlet UIActivityIndicatorView* busyIndicator;

@property BOOL loginShown; 

- (void) populateEventsTable;
- (IBAction)refreshTable:(id)sender;
- (IBAction)logOut:(id)sender;

@end
