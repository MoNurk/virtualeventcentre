//
//  UploadImageVideoViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 02/04/2013.
//
//

#import "UploadImageVideoViewController.h"

@interface UploadImageVideoViewController ()

@end

@implementation UploadImageVideoViewController

@synthesize progressBar, imageView, image, urlCameraRoll;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setSessionId:(int)theSessionId
{
    sessionId = theSessionId;
}

/*
 * Upload code example taken from: http://stackoverflow.com/questions/8042360/nsdata-and-uploading-images-via-post-in-ios
 */
- (IBAction)upload:(id)sender
{
    if (isImage == YES)
    {
        NSData* imageData = UIImageJPEGRepresentation(image, 0.5);
        NSString *urlString = [NSString stringWithFormat:@"%@resteasy/sessions/upload/%i", IP_ADDRESS_AMAZON_AWS, sessionId];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSInteger randomNumber = arc4random() % 1000000;
        
        NSString* cd = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedFile\"; filename=\"image%i.%@\"\r\n", randomNumber, fileType];
        NSData* contentDisposition = [cd dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString* ct = [NSString stringWithFormat:@"Content-Type: image/%@\r\n\r\n", fileType];
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
    else if (isImage == NO)
    {   
        NSData* videoData = [[NSData alloc] initWithContentsOfURL:urlCameraRoll];
        NSString *urlString = [NSString stringWithFormat:@"%@resteasy/sessions/upload/%i", IP_ADDRESS_AMAZON_AWS, sessionId];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSInteger randomNumber = arc4random() % 1000000;
        
        NSString* cd = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedFile\"; filename=\"video%i.MOV\"\r\n", randomNumber];
        NSData* contentDisposition = [cd dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString* ct = [NSString stringWithFormat:@"Content-Type: video/mov\r\n\r\n"];
        NSData* contentTypeBody = [ct dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:contentDisposition];
        [body appendData:contentTypeBody];
        [body appendData:[NSData dataWithData:videoData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        (void)[[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
    }
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
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Uploaded" message:@"Image/Video has been uploaded successfully" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        });
    }
    else {
        dispatch_async( dispatch_get_main_queue(), ^{
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Upload Failed" message:@"Image/Video upload failed" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            
            [alert show];
        });
    }
}


- (IBAction)choosePhotoVideo:(id)sender
{
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.mediaTypes = [NSArray arrayWithObjects:
                          (NSString *) kUTTypeImage,
                          (NSString *) kUTTypeMovie, nil];
    [pickerC setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    [pickerC setVideoQuality:UIImagePickerControllerQualityTypeMedium];
    [pickerC setDelegate:self];
    [self presentViewController:pickerC animated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:YES completion:nil];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    //Media is image
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {
        isImage = YES;
        image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [imageView setImage:image];
    }
    //Media is video
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie]) {
        isImage = NO;
        urlCameraRoll = [info objectForKey:UIImagePickerControllerMediaURL];
        [imageView setImage:[UIImage imageNamed:@"video_64.png"]];
    }
    
    if ([[[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString] rangeOfString:@"PNG"].location != NSNotFound) {
        fileType = @"PNG";
    } else if ([[[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString] rangeOfString:@"JPG"].location != NSNotFound) {
        fileType = @"JPG";
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-gradient-2.png"]];
    
    [self.imageView setClipsToBounds:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
