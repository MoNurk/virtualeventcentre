//
//  RegisterForEventViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 01/02/2013.
//
//

#import "Event.h"
#import <UIKit/UIKit.h>

@interface RegisterForEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    
    UITableView * registerTable;
    
    Event* event;
    Event* eventToSend;
    
    NSMutableArray *tempEventsArray;
    NSMutableArray *events;
    NSMutableArray *finalEvents;
    
    UIBarButtonItem * registerButton;
    UIBarButtonItem * reloadButton;
    
    int eventIdToSend;

}

@property (nonatomic, strong) IBOutlet UITableView * registerTable;

@property (nonatomic, retain) Event* event;
@property (nonatomic, retain) Event* eventToSend;

@property (nonatomic, retain) NSMutableArray *tempEventsArray;
@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSMutableArray *finalEvents;

@property (nonatomic, retain) IBOutlet UIBarButtonItem * registerButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem * reloadButton;

@property (nonatomic) int eventIdToSend;

- (IBAction)registerForEvent:(id)sender;
- (IBAction)reload:(id)sender;

@end
