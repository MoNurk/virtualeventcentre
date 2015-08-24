//
//  EditPresenterViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 25/03/2013.
//
//

#import <UIKit/UIKit.h>
#import "AddPresenterViewController.h"
#import "Presenter.h"

@interface EditPresenterViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, AddPresenterViewControllerDelegate>
{
    UITableView * presenterTable;
    Presenter *presenter;
}


@property (nonatomic, retain) NSMutableArray* presenters;
@property (nonatomic, retain) NSMutableArray* json;
@property (nonatomic, retain) Presenter * presenter;
@property (retain, strong) IBOutlet UITableView * presenterTable;

- (IBAction) addButtonPressed:(id)sender;
- (void) populatePresenters;

@end
