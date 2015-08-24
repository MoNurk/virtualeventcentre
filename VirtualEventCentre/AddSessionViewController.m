//
//  AddSessionViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 05/10/2012.
//
//

#import "AddSessionViewController.h"
#import "TextFieldCell.h"
#import "Event.h"
#import "Presenter.h"
#import "ConnectionToServer.h"

@interface AddSessionViewController ()

@end

@implementation AddSessionViewController

@synthesize navBar, delegate=_delegate, dateFromTemp, dateToTemp, sessionTableInfo, myTableView, dateFromPicker, dateToPicker, eventPicker, dateFromTitle, dateToTitle, eventPickerArray, presenterPickerArray, presenterPicker, sessionToPost, eventToPost, presenterToPost;

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
    
    sessionToPost = [[Session alloc] init];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        eventPickerArray = [[NSMutableArray alloc] init];
        
        NSMutableArray * json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/events", IP_ADDRESS_AMAZON_AWS]]];
        
        for (NSDictionary* item in json) {
            int eventId = [[[item objectForKey:@"event"] objectForKey:@"eventId"] integerValue];
            NSString* eventName = (NSString *)[[item objectForKey:@"event"] objectForKey:@"eventName"];
            NSString* eventDescription = (NSString *)[[item objectForKey:@"event"] objectForKey:@"eventDescription"];
            
            Event * event = [[Event alloc] initWithEventId:eventId eventName:eventName eventDescription:eventDescription];
            [eventPickerArray addObject:event];
        }
        
        presenterPickerArray = [[NSMutableArray alloc] init];
        
        json = [ConnectionToServer makeGETRequestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/presenter", IP_ADDRESS_AMAZON_AWS]]];
        
        for (NSDictionary* item in json) {
            int presenterId = [[[item objectForKey:@"presenter"] objectForKey:@"presenterId"] integerValue];
            NSString* firstName = (NSString *)[[item objectForKey:@"presenter"] objectForKey:@"firstName"];
            NSString* surname = (NSString *)[[item objectForKey:@"presenter"] objectForKey:@"surname"];
            NSString* jobTitle = (NSString *)[[item objectForKey:@"presenter"] objectForKey:@"jobTitle"];
            
            Presenter * presenter = [[Presenter alloc] initWithPresenterId:presenterId firstName:firstName surname:surname jobTitle:jobTitle  profileImage:nil];
            [presenterPickerArray addObject:presenter];
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            presenterToPost = [presenterPickerArray objectAtIndex:0];
            eventToPost = [eventPickerArray objectAtIndex:0];
        });
    });
    
    sessionTableInfo = [[NSMutableArray alloc] initWithObjects:@"Session Name", @"Session Description", @"Session Video URL", @"Associated Event", @"Presenter", @"Date From (YYYY-MM-DD HH:MM)", @"Date To (YYYY-MM-DD HH:MM)", nil];
    
    self.navBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickers)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.myTableView addGestureRecognizer:gestureRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hidePickers
{
    [self.view endEditing:YES];
    
    if (dateFromPicker) {
        [dateFromPicker removeFromSuperview];
    }
    if (dateToPicker) {
        [dateToPicker removeFromSuperview];
    }
    if (eventPicker) {
        [eventPicker removeFromSuperview];
    }
    if (presenterPicker) {
        [presenterPicker removeFromSuperview];
    }
    
    NSLog(@"Done.");
}

- (IBAction)cancel:(id)sender
{
    NSLog(@"Cancel");
    [self.delegate myModalViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    dispatch_async ( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0 ), ^{
        NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *eventData = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *presenterData = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        NSLog(@"%@  %@", dateFromTemp, dateToTemp);
        
        [eventData setObject:[NSNumber numberWithLong:[eventToPost eventId]] forKey:@"eventId"];
        [eventData setObject:[eventToPost eventName] forKey:@"eventName"];
        
        [presenterData setObject:[NSNumber numberWithLong:[presenterToPost presenterId]] forKey:@"presenterId"];
        [presenterData setObject:[presenterToPost firstName] forKey:@"firstName"];
        [presenterData setObject:[presenterToPost surname] forKey:@"surname"];
        
        [data setObject:[sessionToPost sessionName] forKey:@"sessionName"];
        [data setObject:[sessionToPost sessionDescription] forKey:@"sessionDescription"];
        if ([sessionToPost videoUrl] == nil) {
            [sessionToPost setVideoUrl:@""];
        }
        [data setObject:[sessionToPost videoUrl] forKey:@"videoUrl"];
        [data setObject:dateFromTemp forKey:@"dateFromString"];
        [data setObject:dateToTemp forKey:@"dateToString"];
        [data setObject:eventData forKey:@"event"];
        [data setObject:presenterData forKey:@"presenter"];
        [outer setObject:data forKey:@"session"];
        
        NSLog(@"%@", outer);
        
        NSHTTPURLResponse * urlResponse = [ConnectionToServer makePOSTReqeustWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/sessions", IP_ADDRESS_AMAZON_AWS]] jsonData:outer];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([urlResponse statusCode] == 201
                ) {
                [self.delegate myModalViewControllerDidFinishAddingSession:self];
            }
            else {
                UIAlertView *failedAdd = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"There was an error adding the Session. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [failedAdd show];
            }
        });
    });

    NSLog(@"Done");
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [sessionTableInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"AddSessionCell"];
    TextFieldCell *dateCell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"AddSessionDateCell"];
    
    if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
        NSString * placeholder = [sessionTableInfo objectAtIndex:indexPath.row];
        cell.cellTextField.placeholder = placeholder;
        
        return cell;
    } else if (indexPath.row == 3){
        dateCell.textLabel.text = @"Associated Event";
        return dateCell;
    } else if (indexPath.row == 4) {
        dateCell.textLabel.text = @"Presenter";
        return dateCell;
    } else if (indexPath.row == 5) {
        if (dateFromTitle) {
            dateCell.textLabel.text = dateFromTitle;
        } else {
            dateCell.textLabel.text = @"Set Date From";
        }
        return dateCell;
    } else {
        if (dateToTitle) {
            dateCell.textLabel.text = dateToTitle;
        } else {
            dateCell.textLabel.text = @"Set Date To";
        }
        return dateCell;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    CGRect pickerFrame = CGRectMake(0, 0, 0, 0);
    
    if (indexPath.row == 3)
    {
        eventPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        [eventPicker setShowsSelectionIndicator:YES];
        [eventPicker setDelegate:self];
        [eventPicker setDataSource:self];
        
        [self.view addSubview:eventPicker];
        eventPicker.alpha = 0;
        
        [self animatePicker:eventPicker];
    }
    else if (indexPath.row == 4)
    {
        presenterPicker = [[UIPickerView alloc] initWithFrame:pickerFrame];
        [presenterPicker setShowsSelectionIndicator:YES];
        [presenterPicker setDelegate:self];
        [presenterPicker setDataSource:self];
        
        [self.view addSubview:presenterPicker];
        presenterPicker.alpha = 0;
        
        [self animatePicker:presenterPicker];
    }
    else if (indexPath.row == 5)
    {
        dateFromPicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        [dateFromPicker addTarget:self action:@selector(dateFromPickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:dateFromPicker];
        dateFromPicker.alpha = 0;
        
        [self animateDatePicker:dateFromPicker];
    }
    else if (indexPath.row == 6)
    {   
        dateToPicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        [dateToPicker setTimeZone:[NSTimeZone systemTimeZone]];
        [dateToPicker addTarget:self action:@selector(dateToPickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:dateToPicker];
        dateToPicker.alpha = 0;
        
        [self animateDatePicker:dateToPicker];
    }
}

- (void) animatePicker:(UIPickerView *) picker
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 335);
    picker.transform = transfrom;
    picker.alpha = picker.alpha * (-1) + 1;
    [UIView commitAnimations];
}

- (void) animateDatePicker:(UIDatePicker *) picker
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.6];
    CGAffineTransform transfrom = CGAffineTransformMakeTranslation(0, 335);
    picker.transform = transfrom;
    picker.alpha = picker.alpha * (-1) + 1;
    [UIView commitAnimations];
}

- (void)dateFromPickerChanged:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateFromString = [dateFormatter stringFromDate:[sender date]];
    dateFromTemp = dateFromString;
    dateFromTitle = dateFromString;
    [myTableView reloadData];
}

- (void)dateToPickerChanged:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateToString = [dateFormatter stringFromDate:[sender date]];
    dateToTemp = dateToString;
    dateToTitle = dateToString;
    [myTableView reloadData];
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Session Information";
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
    
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
    
    if (thePickerView == eventPicker) {
        return [eventPickerArray count];
    }
    else
    {
        return [presenterPickerArray count];
    }
}

- (NSString *)pickerView:(UIPickerView *)thePickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (thePickerView == eventPicker) {
        Event * event = [eventPickerArray objectAtIndex:row];
        return [event eventName];
    } else {
        Presenter * presenter = [presenterPickerArray objectAtIndex:row];
        return [NSString stringWithFormat:@"%@ %@", [presenter firstName], [presenter surname]];
    }
}

- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (thePickerView == eventPicker) {
        Event * event = [eventPickerArray objectAtIndex:row];
        eventToPost = event;
        NSLog(@"Selected Color: %@. Index of selected color: %i", [event eventName], row);
    } else {
        Presenter * presenter = [presenterPickerArray objectAtIndex:row];
        presenterToPost = presenter;
        NSLog(@"Selected Color: %@. Index of selected color: %i", [presenter firstName], row);
    }
}

- (IBAction)updateSessionDetails:(id)sender
{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[sender superview] superview]];
    
    if (indexPath.row == 0) {
        sessionToPost.sessionName = ((UITextField *)sender).text;
    } else if (indexPath.row == 1) {
        sessionToPost.sessionDescription = ((UITextField *)sender).text;
    } else if (indexPath.row == 2) {
        sessionToPost.videoUrl = ((UITextField *)sender).text;
    }

}

@end
