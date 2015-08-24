//
//  UploadImageVideoViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 02/04/2013.
//
//

#import <UIKit/UIKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

@interface UploadImageVideoViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDataDelegate>
{
    UIImageView *imageView;
    UIImage * image;
    UIProgressView *progressBar;
    BOOL isImage;
    NSString * fileType;
    NSURL *urlCameraRoll;
    int sessionId;
}

@property (retain, nonatomic) IBOutlet UIImageView * imageView;
@property (retain, nonatomic) IBOutlet UIProgressView * progressBar;
@property (retain, nonatomic) UIImage * image;
@property (nonatomic, retain) NSURL *urlCameraRoll;

- (IBAction)choosePhotoVideo:(id)sender;
- (IBAction)upload:(id)sender;
- (void) setSessionId:(int)theSessionId;

@end
