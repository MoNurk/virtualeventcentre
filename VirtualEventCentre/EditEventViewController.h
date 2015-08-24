//
//  EditEventViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/10/2012.
//
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "AddEventViewController.h"

@interface EditEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddEventViewControllerDelegate> {
    
    int eventIdToSend;
    
    UITableView* eventTable;
    
    Event* event;
    Event* eventToSend;
    
    NSMutableArray *tempEventsArray;
    NSMutableArray *events;
    NSMutableArray *finalEvents;
}

@property int eventIdToSend;

@property (nonatomic, retain) IBOutlet UITableView* eventTable;

@property (nonatomic, retain) Event* event;
@property (nonatomic, retain) Event* eventToSend;

@property (nonatomic, retain) NSMutableArray *tempEventsArray;
@property (nonatomic, retain) NSMutableArray *events;
@property (nonatomic, retain) NSMutableArray *finalEvents;

@end
