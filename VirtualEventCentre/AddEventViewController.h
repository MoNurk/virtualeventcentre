//
//  AddEventViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 24/09/2012.
//
//

#import <UIKit/UIKit.h>
#import "Event.h"

@class AddEventViewController;

@protocol AddEventViewControllerDelegate <NSObject>

@optional

- (void)myModalViewControllerDidFinishAddingEvent:(AddEventViewController *)controller;
- (void)myModalViewControllerDidCancel:(AddEventViewController *)controller;

@end

@interface AddEventViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate> {
    
    UITableView * myTableView;
    
    UIDatePicker * datePicker;
    UIDatePicker * dateToPicker;
    
    id <AddEventViewControllerDelegate> delegate;
    
    UINavigationBar *navBar;
    
    NSMutableArray * eventTableInfo;
    
    Event * event;
    
    NSString * dateFromTemp;
    NSString * dateToTemp;
}

@property (retain, nonatomic) IBOutlet UITableView * myTableView;

@property (retain, nonatomic) IBOutlet UIDatePicker * datePicker;
@property (retain, nonatomic) IBOutlet UIDatePicker * dateToPicker;

@property (retain, nonatomic) NSString * dateFromTemp;
@property (retain, nonatomic) NSString * dateToTemp;

@property (assign) id <AddEventViewControllerDelegate> delegate;

@property (retain, nonatomic) IBOutlet UINavigationBar * navBar;

@property (retain, nonatomic) NSMutableArray * eventTableInfo;

@property (retain, nonatomic) Event * event; 

- (IBAction)done:(id)sender;
- (IBAction)cancel:(id)sender;

- (IBAction)updateEvent:(id)sender;

@end
