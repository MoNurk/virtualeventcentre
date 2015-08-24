//
//  RegisterUserViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 15/09/2012.
//
//

#import "RegisterUserViewController.h"
#import "TextFieldCell.h"

@interface RegisterUserViewController ()

@end

@implementation RegisterUserViewController

@synthesize username, password, confirmPassword, myTableView, originalCenter;

- (IBAction)registerUser:(id)sender
{
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL duplicateShown = NO;
        NSHTTPURLResponse* urlResponse = nil;
        //NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/user/%@", IP_ADDRESS_AMAZON_AWS, username]]];
        __autoreleasing NSError* error = nil;
        //if (data != nil && error == nil) {
            
            //if ([data length] == 2) {
                if ([password isEqualToString:confirmPassword]) {
                    duplicateShown = NO;
                    
                    NSMutableDictionary *outer = [[NSMutableDictionary alloc] init];
                    NSMutableDictionary *dataToSend = [[NSMutableDictionary alloc] init];
                    
                    [dataToSend setObject:username forKey:@"username"];
                    [dataToSend setObject:confirmPassword forKey:@"password"];
                    [dataToSend setObject:@"0" forKey:@"isAdmin"];
                    [outer setObject:dataToSend forKey:@"user"];
                    
                    NSError *errorJson = nil;
                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:outer options:NSJSONWritingPrettyPrinted error:&errorJson];
                    
                    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/user", IP_ADDRESS_AMAZON_AWS]]];
                    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
                    [request setHTTPBody:jsonData];
                    [request setHTTPMethod:@"POST"];
                    [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
                }
            //} else {
              //  duplicateShown = YES;
    //}
        //}
        dispatch_async( dispatch_get_main_queue(), ^{
            if ([urlResponse statusCode] == 202) {
                [self dismissViewControllerAnimated:YES completion:^{}];
            }
            else if (duplicateShown == NO) {
                UIAlertView *failedAdd = [[UIAlertView alloc] initWithTitle:@"Failed" message:@"There was an error registering. Please try again. Ensure passwords match." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [failedAdd show];
            }
            else if (duplicateShown == YES) {
                UIAlertView *userExistsAlert = [[UIAlertView alloc] initWithTitle:@"User Exists" message:@"A user with the specified username already exists, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [userExistsAlert show];
            }

        });
    });
}

- (IBAction)backToLogin:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = (TextFieldCell *)[tableView
                                    dequeueReusableCellWithIdentifier:@"LoginCell"];
    if (indexPath.row == 0) {
        cell.cellTextField.placeholder = @"Username";
    } else if (indexPath.row == 1) {
        cell.cellTextField.placeholder = @"Password";
        cell.cellTextField.secureTextEntry = YES;
        cell.cellTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    } else if (indexPath.row ==2) {
        cell.cellTextField.placeholder = @"Confirm password";
        cell.cellTextField.secureTextEntry = YES;
        cell.cellTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    }
    
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    originalCenter = self.view.center;
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[textField superview] superview]]; // this should return you your current indexPath
    
    if (indexPath.row == 2 || indexPath.row == 1) {
        //self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 40);
    }
}

- (void) textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[textField superview] superview]]; // this should return you your current indexPath
    
    // From here on you can (switch) your indexPath.section or indexPath.row
    // as appropriate to get the textValue and assign it to a variable, for instance:
    if (indexPath.row == 0) {
        self.username = [NSString stringWithString:[textField text]];
    } else if (indexPath.row == 1) {
        self.password = [NSString stringWithString:[textField text]];
        self.view.center = originalCenter;
    } else if (indexPath.row == 2) {
        self.confirmPassword = [NSString stringWithString:[textField text]];
        self.view.center = originalCenter;
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //UITouch *touch = [touches anyObject];
    
    [self.view endEditing:YES];
}

- (IBAction) updateUserDetails:(id)sender
{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[sender superview] superview]];
    
    if (indexPath.row == 0) {
        username = ((UITextField *)sender).text;
    } else if (indexPath.row == 1) {
        password = ((UITextField *)sender).text;
    } else if (indexPath.row == 2) {
        confirmPassword = ((UITextField *)sender).text;
    }
}

@end
