//
//  SessionDetailViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 09/09/2012.
//
//

#import "SessionDetailViewController.h"
#import "DocumentsViewController.h"
#import "TitleDetail.h"
#import "WebPageViewController.h"
#import <Twitter/Twitter.h>
#import <EventKit/EventKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SessionDetailViewController ()

@end

@implementation SessionDetailViewController

@synthesize selectedSession, myTableView, titlesAndText, documentDetailText, documentTitle;

- (void) setMySession:(Session *)session
{
    self.selectedSession = session;
    
    documentTitle = @"Documents";
    documentDetailText = @"View Documents";
    
    [self populateSessionTitles];
}

/*
No longer using this method, using action sheet instead of button.  
- (void) addButtonsToTable
{
    // create a UIButton (Deconnect button)
    UIButton *btnSubscribe = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btnSubscribe.frame = CGRectMake(75, 0, 130, 40);
    [btnSubscribe setTitle:@"Add to Calendar" forState:UIControlStateNormal];
    [btnSubscribe addTarget:self action:@selector(createEvent) forControlEvents:UIControlEventTouchUpInside];

    // create a UIButton (Change pseudo button)
    UIButton *tweetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    tweetButton.frame = CGRectMake(75, 50, 130, 40);
    [tweetButton setTitle:@"Tweet It" forState:UIControlStateNormal];
    [tweetButton addTarget:self action:@selector(showTweetSheet) forControlEvents:UIControlEventTouchUpInside];

    //create a footer view on the bottom of the tabeview
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(20, 0, 280, 60)];
    [footerView addSubview:btnSubscribe];
    //[footerView addSubview:tweetButton];

    [myTableView setTableFooterView:footerView];
}*/

- (void) createEvent
{
    UIActivityIndicatorView* activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    UIBarButtonItem * barButton = [[UIBarButtonItem alloc] initWithCustomView:activityIndicator];
    [self navigationItem].rightBarButtonItem = barButton;
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        EKEventStore *eventStore = [[EKEventStore alloc] init];
        EKEvent *event  = [EKEvent eventWithEventStore:eventStore];
        [eventStore requestAccessToEntityType:EKCalendarTypeLocal completion:^(BOOL granted, NSError *error) {
            event.title     = [selectedSession sessionName];
            event.notes     = [selectedSession sessionDescription];
            event.startDate = [selectedSession dateFrom];
            event.endDate   = [selectedSession dateTo];
            
            [event setCalendar:[eventStore defaultCalendarForNewEvents]];
            NSError *err;
            [eventStore saveEvent:event span:EKSpanThisEvent error:&err]; 
        }];
        dispatch_async( dispatch_get_main_queue(), ^{
            [activityIndicator stopAnimating];
            UIAlertView *eventAlert = [[UIAlertView alloc] initWithTitle:@"Event Saved" message:@"The event has been created in your calendar." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [eventAlert show];
            
            UIBarButtonItem * actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
            [self navigationItem].rightBarButtonItem = actionButton;
        });
    });
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
    
    UIBarButtonItem * actionButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActionSheet)];
    [self navigationItem].rightBarButtonItem = actionButton;
    
    UIActivityIndicatorView * loadingBanner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [loadingBanner setFrame:CGRectMake(0, 5, 320, 25)];
    
    if ([[selectedSession imageUrl] hasPrefix:@"http://"])
    {
        UIView * activityView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
        
        [loadingBanner setHidesWhenStopped:YES];
        [loadingBanner startAnimating];
        
        [activityView addSubview:loadingBanner];
        [myTableView setTableHeaderView:activityView];
    }
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        UIImageView* imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 160)];
        UIImage* image;
        
        if ([[selectedSession imageUrl] hasPrefix:@"http://"])
        {
            NSData * imageData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString:[selectedSession imageUrl]]];
            image = [UIImage imageWithData:imageData];
            [imageView setContentMode:UIViewContentModeScaleAspectFill];
            [imageView setClipsToBounds:YES];
            
            
            [loadingBanner stopAnimating];
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([[selectedSession imageUrl] hasPrefix:@"http://"])
            {
                [imageView setImage:image];
                [view addSubview:imageView];
                [myTableView setTableHeaderView:view];
            }
        });
    });

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) showActionSheet
{
    UIActionSheet * actionSheet = [[UIActionSheet alloc] initWithTitle:@"Share" delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle: nil otherButtonTitles: @"Twitter", @"Facebook", @"Add to Calendar", nil];
    [actionSheet showFromTabBar:self.tabBarController.tabBar];
}

- (void) actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%i", buttonIndex);
    
    if (buttonIndex == 0)
    {
        [self showTweetSheet];
    }
    else if (buttonIndex == 1)
    {
        [self postToFacebook];
    }
    else if (buttonIndex == 2)
    {
        [self createEvent];
    }
}

- (void) populateSessionTitles
{
    NSString * liveVideoUrlTitle = @"Live Video";
    
    titlesAndText = [[NSMutableArray alloc] init]; 
    
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateFromString = [dateFormatter stringFromDate:[selectedSession dateFrom]];
    NSString *dateToString = [dateFormatter stringFromDate:[selectedSession dateTo]];
    
    NSString * sessionId = [NSString stringWithFormat:@"%ld", [selectedSession sessionId]];
    NSArray* sessionArray = [[NSArray alloc] initWithObjects: sessionId, [selectedSession sessionName], [selectedSession sessionDescription], dateFromString, dateToString, documentDetailText, liveVideoUrlTitle, nil];
    NSArray* titles = [[NSArray alloc] initWithObjects:@"Session ID", @"Name", @"Description", @"Date From", @"Date To", documentTitle, liveVideoUrlTitle, nil];
    
    for (int i = 0; i < [sessionArray count]; i++) {
        TitleDetail *td = [[TitleDetail alloc] initWithTitle:[titles objectAtIndex:i] detailText:[sessionArray objectAtIndex:i]];
        
        [titlesAndText addObject:td];
    }
    
    [myTableView reloadData];
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [titlesAndText count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SessionDetailCell"];
    
    TitleDetail* titleDetail = [titlesAndText objectAtIndex:indexPath.row];
    
    cell.textLabel.text = titleDetail.title;
    cell.detailTextLabel.text = titleDetail.detailText;
    
    if ([[titleDetail detailText] isEqualToString:documentDetailText] || [[titleDetail detailText] isEqualToString:@"Live Video"]) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    else {
        [cell setAccessoryType:UITableViewCellAccessoryNone];
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    TitleDetail* td = [titlesAndText objectAtIndex:indexPath.row];
    
    if ([[td title] isEqualToString:documentTitle]) {
        [self performSegueWithIdentifier:@"DocumentSegue" sender:self];
    } else if ( [[td title] isEqualToString:@"Live Video"] ) {
        [self performSegueWithIdentifier:@"LoadVideoSegue" sender:self];
        //NSString * launchUrl = [selectedSession videoUrl];
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString: launchUrl]];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TitleDetail *td = [titlesAndText objectAtIndex:indexPath.row];
    if ([td.detailText length] > 30) {
        NSString* text = [td detailText];
        UIFont* f = [UIFont systemFontOfSize:18];
        CGSize s = [text sizeWithFont: f constrainedToSize:CGSizeMake(280, 640)];
        return s.height + 20; //Padding of 20 pixels
    }
    else {
        return 44;
    }
}

- (BOOL) tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:))
    {
        TitleDetail* td = [titlesAndText objectAtIndex:indexPath.row];
        
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        [pb setString:[td detailText]];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"DocumentSegue"])
    {
        DocumentsViewController* dvc = [segue destinationViewController];
        [dvc populateDocuments:[selectedSession sessionId]]; 
    }
    
    if ([[segue identifier] isEqualToString:@"LoadVideoSegue"])
    {
        WebPageViewController* wpvc = [segue destinationViewController];
        [wpvc setPageToLoadWithUrl:[NSURL URLWithString:[selectedSession videoUrl]]];
    }

}

- (void)showTweetSheet
{
    
    SLComposeViewController *mySLComposerSheet;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) //check if Twitter Account is linked
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *dateFromString = [dateFormatter stringFromDate:[selectedSession dateFrom]];
        NSString *dateToString = [dateFormatter stringFromDate:[selectedSession dateTo]];
        
        mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"I'm virtually attending %@. Starts at %@ until %@ #VEC", [selectedSession sessionName], dateFromString, dateToString]];
        //[mySLComposerSheet addImage:yourimage]; //an image you could post
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = @"Action Cancelled";
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            case SLComposeViewControllerResultDone:
                output = @"Post Successfull";
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
            default:
                [self dismissViewControllerAnimated:YES completion:nil];
                break;
        }
    }];
}

- (void) postToFacebook
{
    SLComposeViewController *mySLComposerSheet;
    
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) //check if Facebook Account is linked
    {
        NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        NSString *dateFromString = [dateFormatter stringFromDate:[selectedSession dateFrom]];
        NSString *dateToString = [dateFormatter stringFromDate:[selectedSession dateTo]];
        
        mySLComposerSheet = [[SLComposeViewController alloc] init]; //initiate the Social Controller
        mySLComposerSheet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        [mySLComposerSheet setInitialText:[NSString stringWithFormat:@"I'm virtually attending %@. Starts at %@ until %@ #VEC", [selectedSession sessionName], dateFromString, dateToString]];
        //[mySLComposerSheet addImage:yourimage]; //an image you could post
        [self presentViewController:mySLComposerSheet animated:YES completion:nil];
    }
    [mySLComposerSheet setCompletionHandler:^(SLComposeViewControllerResult result) {
        NSString *output;
        switch (result) {
            case SLComposeViewControllerResultCancelled:
                output = @"Action Cancelled";
                break;
            case SLComposeViewControllerResultDone:
                output = @"Post Successfull";
                break;
            default:
                break;
        }
    }];
}

@end
