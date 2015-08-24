//
//  AddPresenterViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 25/03/2013.
//
//

#import <UIKit/UIKit.h>

@class AddPresenterViewController;

@protocol AddPresenterViewControllerDelegate <NSObject>

@optional

- (void)myModalViewControllerDidFinishAddingPresenter:(AddPresenterViewController *)controller;
- (void)myModalViewControllerDidCancel:(AddPresenterViewController *)controller;

@end

@interface AddPresenterViewController : UIViewController
{
    id <AddPresenterViewControllerDelegate> delegate;
    UITextField * firstName;
    UITextField * surname;
    UITextField * jobTitle;
}

@property (nonatomic, retain) IBOutlet UINavigationBar * navBar;

@property (assign) id <AddPresenterViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITextField * firstName;
@property (nonatomic, retain) IBOutlet UITextField * surname;
@property (nonatomic, retain) IBOutlet UITextField * jobTitle;

@end
