//
//  TestingViewController.h
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 27/08/2012.
//
//

#import <UIKit/UIKit.h>

@interface TestingViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate> {
    
    UIImageView *imageView;
    UIButton *choosePhotoButton;
    UIButton *playVideoButton;
    NSURL *urlCameraRoll;
}

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UIButton *choosePhotoButton;
@property (nonatomic, retain) IBOutlet UIButton *playVideoButton;
@property (nonatomic, retain) NSURL *urlCameraRoll;

- (IBAction)choosePhoto:(id)sender;
- (IBAction)playMovie:(id)sender;
- (IBAction)deleteFilesFromDocs:(id)sender;
- (void)embedYouTube:(NSString *)urlString frame:(CGRect)frame;


@end
