//
//  TestingViewController.m
//  WebViewDelegate
//
//  Created by Muhammed Nurkerim on 27/08/2012.
//
//

#import "TestingViewController.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface TestingViewController ()

@end

@implementation TestingViewController

@synthesize choosePhotoButton, imageView, playVideoButton, urlCameraRoll;

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
    
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-gradient-2.png"]];
    
	// Do any additional setup after loading the view.
    
    //[self embedYouTube:@"http://www.youtube.com/embed/s_SzUnkYcR4?vq=hd720&autoplay=1" frame:CGRectMake(20, 20, 280, 180)];
}

/*- (void)embedYouTube:(NSString *)urlString frame:(CGRect)frame {
    //NSString *embedHTML = @"<iframe  src=\"%@\" width=\"%100.0f\" height=\"100\" frameborder=\"0\" allowfullscreen></iframe>";
    NSString *html = [NSString stringWithFormat:@"<html><body style=\"margin:0\"> <iframe  src=\"%@\" width=\"%100.0f\" height=\"%100.0f\" frameborder=\"0\" allowfullscreen></iframe></body></html>", urlString, frame.size.width, frame.size.height];
    UIWebView *videoView = [[UIWebView alloc] initWithFrame:frame];
    NSLog(@"%@", html);
    [videoView loadHTMLString:html baseURL:nil];
    [[videoView scrollView] setBounces:NO];
    [self.view addSubview:videoView];
}*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)deleteFilesFromDocs:(id)sender
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSError *error = nil;
    NSArray *directoryContents = [fileManager contentsOfDirectoryAtPath:documentsDirectory error:&error];
    if (error == nil) {
        for (NSString *path in directoryContents) {
            NSString *fullPath = [documentsDirectory stringByAppendingPathComponent:path];
            BOOL removeSuccess = [fileManager removeItemAtPath:fullPath error:&error];
            NSLog(@"Removed %@", fullPath);
            if (!removeSuccess) {
                NSLog(@"Failed Remove");
            }
        }
    } else {
        NSLog(@"Error occured");
    }
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Cleared" message:@"All data has been deleted" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];

    [alert show];
}

- (IBAction)choosePhoto:(id)sender
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

- (IBAction)playMovie:(id)sender
{
    //NSString * pathv = [[NSBundle mainBundle] pathForResource:@"IMG_0013" ofType:@"MOV"];
    MPMoviePlayerViewController *playerv = [[MPMoviePlayerViewController alloc] initWithContentURL:urlCameraRoll];
    
    [self presentMoviePlayerViewControllerAnimated:playerv];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    
    NSString * fileType;
    
    if ([[[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString] rangeOfString:@"PNG"].location != NSNotFound) {
        fileType = @"PNG";
    } else if ([[[info objectForKey:UIImagePickerControllerReferenceURL] absoluteString] rangeOfString:@"JPG"].location != NSNotFound) {
        fileType = @"JPG";
    }
    
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage])
    {
        // Media is an image
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [imageView setImage:image];
        [self dismissViewControllerAnimated:YES completion:nil];
                
        NSData* imageData = UIImageJPEGRepresentation(image, 1.0);
        NSString *urlString = [NSString stringWithFormat:@"%@resteasy/presenter/upload/3", IP_ADDRESS_AMAZON_AWS];
        
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
        
        NSData *returnData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);
    }
    else if ([mediaType isEqualToString:(NSString *)kUTTypeMovie])
    {
        // Media is a video
        urlCameraRoll = [info objectForKey:UIImagePickerControllerMediaURL];
        [self dismissViewControllerAnimated:YES completion:nil];
        
        NSData* videoData = [[NSData alloc] initWithContentsOfURL:urlCameraRoll];
        NSString *urlString = [NSString stringWithFormat:@"%@resteasy/sessions/upload/1", IP_ADDRESS_AMAZON_AWS];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
        [request setURL:[NSURL URLWithString:urlString]];
        [request setHTTPMethod:@"POST"];
        
        NSString *boundary = @"---------------------------14737809831466499882746641449";
        NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary];
        [request addValue:contentType forHTTPHeaderField:@"Content-Type"];
        
        NSInteger randomNumber = arc4random() % 1000000;
        
        NSString* cd = [NSString stringWithFormat:@"Content-Disposition: form-data; name=\"uploadedFile\"; filename=\"video%i.MOV\"\r\n", randomNumber];
        NSData* contentDisposition = [cd dataUsingEncoding:NSUTF8StringEncoding];
        
        NSString* ct = [NSString stringWithFormat:@"Content-Type: video/%@\r\n\r\n", fileType];
        NSData* contentTypeBody = [ct dataUsingEncoding:NSUTF8StringEncoding];
        
        NSMutableData *body = [NSMutableData data];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [body appendData:contentDisposition];
        [body appendData:contentTypeBody];
        [body appendData:[NSData dataWithData:videoData]];
        [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
        [request setHTTPBody:body];
        
        NSData *returnData = [NSURLConnection  sendSynchronousRequest:request returningResponse:nil error:nil];
        NSString *returnString = [[NSString alloc] initWithData:returnData encoding:NSUTF8StringEncoding];
        NSLog(@"%@", returnString);

    }
}

@end
