//
//  UploadBannerViewController.h
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 08/11/2012.
//
//

#import <UIKit/UIKit.h>

@interface UploadBannerViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, NSURLConnectionDataDelegate> {
    
    NSString * sessionId;
    
    UIImageView * bannerImage;
    UIImage * image;
    UIProgressView * progressBar;
}

@property (nonatomic, retain) NSString * sessionId;

@property (nonatomic, retain) IBOutlet UIImageView * bannerImage;
@property (nonatomic, retain) UIImage * image; 
@property (nonatomic, retain) IBOutlet UIProgressView * progressBar;

- (void) uploadBannerToEventId:(NSString *) uploadId;
- (IBAction)choosePhoto:(id)sender;
- (IBAction)uploadBanner:(id)sender;

@end
