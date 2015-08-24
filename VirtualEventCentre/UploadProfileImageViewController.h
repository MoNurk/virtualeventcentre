//
//  UploadProfileImageViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 03/04/2013.
//
//

#import <UIKit/UIKit.h>

@interface UploadProfileImageViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDataDelegate>
{
    UIImageView *imageView;
    UIImage * image;
    UIProgressView *progressBar;
    int presenterId;
}

@property (retain, nonatomic) IBOutlet UIProgressView * progressBar;
@property (retain, nonatomic) IBOutlet UIImageView * imageView;
@property (retain, nonatomic) UIImage * image;
@property (nonatomic) int presenterId;

- (IBAction)choosePhoto:(id)sender;
- (IBAction)upload:(id)sender;
- (void) initPresenterId:(int)thePresenterId;

@end
