//
//  AddSessionViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/10/2012.
//
//

#import <UIKit/UIKit.h>
#import "Session.h"
#import "Event.h"
#import "Presenter.h"

@class AddSessionViewController;

@protocol AddSessionViewControllerDelegate <NSObject>

@optional

- (void)myModalViewControllerDidFinishAddingSession:(AddSessionViewController *)controller;
- (void)myModalViewControllerDidCancel:(AddSessionViewController *)controller;

@end

@interface AddSessionViewController : UIViewController <UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate> {
    
    UINavigationBar *navBar;
    
    NSMutableArray * sessionTableInfo;
    NSMutableArray* eventPickerArray;
    NSMutableArray* presenterPickerArray;
    
    id <AddSessionViewControllerDelegate> delegate;
    
    UIDatePicker * dateFromPicker;
    UIDatePicker * dateToPicker;
    UIPickerView * eventPicker;
    UIPickerView * presenterPicker;
    
    NSString * dateFromTemp;
    NSString * dateToTemp;
    
    UITableView * myTableView;
    
    NSString * dateFromTitle;
    NSString * dateToTitle;
    
    Session * sessionToPost;
    Event * eventToPost;
    Presenter * presenterToPost; 
}

@property (nonatomic, retain) IBOutlet UINavigationBar * navBar;

@property (retain, nonatomic) NSMutableArray * sessionTableInfo;
@property (retain, nonatomic) NSMutableArray * eventPickerArray;
@property (retain, nonatomic) NSMutableArray * presenterPickerArray;

@property (assign) id <AddSessionViewControllerDelegate> delegate;

@property (retain, nonatomic) UIDatePicker * dateFromPicker;
@property (retain, nonatomic) UIDatePicker * dateToPicker;
@property (retain, nonatomic) UIPickerView * eventPicker;
@property (retain, nonatomic) UIPickerView * presenterPicker;

@property (retain, nonatomic) NSString * dateFromTemp;
@property (retain, nonatomic) NSString * dateToTemp;
@property (retain, nonatomic) NSString * dateFromTitle;
@property (retain, nonatomic) NSString * dateToTitle;

@property (retain, nonatomic) IBOutlet UITableView * myTableView;

@property (retain, nonatomic) Session * sessionToPost;
@property (retain, nonatomic) Event * eventToPost;
@property (retain, nonatomic) Presenter * presenterToPost;

- (IBAction)updateSessionDetails:(id)sender;

@end
