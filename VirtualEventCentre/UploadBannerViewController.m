//
//  UploadBannerViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 08/11/2012.
//
//

#import "UploadBannerViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface UploadBannerViewController ()

@end

@implementation UploadBannerViewController

@synthesize sessionId, bannerImage, image, progressBar;

- (void) uploadBannerToEventId:(NSString *) uploadId
{
    self.sessionId = uploadId; 
}

/*
 * Upload code example taken from: http://stackoverflow.com/questions/8042360/nsdata-and-uploading-images-via-post-in-ios
 */
- (IBAction) uploadBanner:(id)sender
{
    NSData* imageData = UIImageJPEGRepresentation(image, 0.25);
    NSString *urlString = [NSString stringWithFormat:@"%@resteasy/sessions/uploadbanner/%@", IP_ADDRESS_AMAZON_AWS, self.sessionId];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
    [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
    
    NSInteger randomNumber = arc4random() % 1000000;
    
    NSString* cd = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedFile\"; filename=\"image%i.JPG\"\r\n", randomNumber];
    NSData* contentDisposition = [cd dataUsingEncoding:NSUTF8StringEncoding];
    
    NSString* ct = [NSString stringWithFormat:@"Content-Type: image/jpg\r\n\r\n"];
    NSData* contentTypeBody = [ct dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData *body = [NSMutableData data];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [body appendData:contentDisposition];
    [body appendData:contentTypeBody];
    [body appendData:[NSData dataWithData:imageData]];
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:body];
    
    
    (void)[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
}

- (void) connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
    float progress = (float)totalBytesWritten;
    float total = (float)totalBytesExpectedToWrite;
    progressBar.progress = progress/total;
}

- (void) connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([httpResponse statusCode] == 200) {
        dispatch_async( dispatch_get_main_queue(), ^{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uploaded" message:@"Image has been uploaded successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"Image upload failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        });
    }
}

- (IBAction) choosePhoto:(id)sender
{
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.mediaTypes = [NSArray arrayWithObjects:
                          (NSString *) kUTTypeImage, nil];
    [pickerC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [pickerC setDelegate:self];
    [self presentViewController:pickerC animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [bannerImage setImage:image];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-gradient-2.png"]];
    
    [self.bannerImage setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
