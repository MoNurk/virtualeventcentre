//
//  AddEventViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 24/09/2012.
//
//

#import "AddEventViewController.h"
#import "ConnectionToServer.h"
#import "TextFieldCell.h"

@interface AddEventViewController ()

@end

@implementation AddEventViewController

@synthesize delegate = _delegate, navBar, eventTableInfo, myTableView, event, datePicker, dateToPicker, dateFromTemp, dateToTemp;

- (IBAction)cancel:(id)sender
{
    [self.delegate myModalViewControllerDidCancel:self];
}

- (IBAction)done:(id)sender
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
        NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
        
        NSLog(@"%@  %@", dateFromTemp, dateToTemp);
        
        [data setObject:[event eventName] forKey:@"eventName"];
        [data setObject:[event eventDescription] forKey:@"eventDescription"];
        [data setObject:dateFromTemp forKey:@"dateFromString"];
        [data setObject:dateToTemp forKey:@"dateToString"];
        [outer setObject:data forKey:@"event"];
        
        NSHTTPURLResponse * urlResponse = [ConnectionToServer makePOSTReqeustWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/events", IP_ADDRESS_AMAZON_AWS]] jsonData:outer];
        
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([urlResponse statusCode] == 202) {
                [self.delegate myModalViewControllerDidFinishAddingEvent:self];
            }
            else {
                UIAlertView *failedAdd = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"There was an error adding the vehicle. Please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [failedAdd show];
            }
        });
    });
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
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
    
    event = [[Event alloc] init];
    
    self.navBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    
    eventTableInfo = [[NSMutableArray alloc] initWithObjects:@"Event Name", @"Event Description", @"Date From (YYYY-MM-DD HH:MM)", @"Date To (YYYY-MM-DD HH:MM)", nil];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    gestureRecognizer.cancelsTouchesInView = NO;
    [self.myTableView addGestureRecognizer:gestureRecognizer];
    
    UITapGestureRecognizer *gestureRecognizer2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hidePickers)];
    gestureRecognizer2.cancelsTouchesInView = NO;
    [self.myTableView addGestureRecognizer:gestureRecognizer2];
}

- (void) hidePickers
{
    [self.view endEditing:YES];
    
    if (datePicker) {
        [datePicker removeFromSuperview];
    }
    if (dateToPicker) {
        [dateToPicker removeFromSuperview];
    }
    
    NSLog(@"Done.");
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) hideKeyboard
{
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [eventTableInfo count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"AddEventCell"];
    TextFieldCell *dateCell = (TextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"AddEventDateCell"];
    
    if (indexPath.row == 0 || indexPath.row == 1) {
        NSString * placeholder = [eventTableInfo objectAtIndex:indexPath.row];
        cell.cellTextField.placeholder = placeholder;
        
        return cell;
    } else if (indexPath.row == 2){
        dateCell.textLabel.text = @"Set Date From";
        return dateCell;
    } else {
        dateCell.textLabel.text = @"Set Date To";
        return dateCell;
    }
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 2) {
        
        CGRect pickerFrame = CGRectMake(0, 0, 0, 0);
        
        datePicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        [datePicker addTarget:self action:@selector(dateFromPickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:datePicker];
        datePicker.alpha = 0;
        
        [self animatePicker:datePicker];
        
    } else if (indexPath.row == 3) {
        CGRect pickerFrame = CGRectMake(0, 0, 0, 0);
        
        dateToPicker = [[UIDatePicker alloc] initWithFrame:pickerFrame];
        [dateToPicker setTimeZone:[NSTimeZone systemTimeZone]];
        [dateToPicker addTarget:self action:@selector(dateToPickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        [self.view addSubview:dateToPicker];
        dateToPicker.alpha = 0;
        
        [self animatePicker:dateToPicker];
    }
}

- (void) animatePicker:(UIDatePicker *) picker
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
}

- (void)dateToPickerChanged:(id)sender
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateToString = [dateFormatter stringFromDate:[sender date]];
    dateToTemp = dateToString;
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Event Information"; 
}

- (IBAction)updateEvent:(id)sender
{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[sender superview] superview]];
    
    if (indexPath.row == 0) {
        event.eventName = ((UITextField *)sender).text;
    } else if (indexPath.row == 1) {
        event.eventDescription = ((UITextField *)sender).text;
    }
}

@end
