//
//  LoginViewController.m
//  VirtualEventCentre
//
//  Created by Muhammed Nurkerim on 15/09/2012.
//
//

#import "LoginViewController.h"
#import "AppDelegate.h"
#import "Base64.h"
#import "User.h"
#import "TextFieldCell.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

@synthesize usernameLabel, passwordLabel, loginButton, userLabel, myTableView, username, password, switchView, originalCenter, delegate = _delegate, activityIndicator;

- (IBAction)signIn:(id)sender
{
    [activityIndicator setHidden:NO];
    [activityIndicator startAnimating];
    
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        BOOL isAdmin = NO;
        
        User * user;
        
        NSString* tempStr = [NSString stringWithFormat:@"%@:%@", username, password];
        NSString * tempEncoded = [Base64 encode:[tempStr dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSString * tempBasic64Encoded = [NSString stringWithFormat:@"Basic %@", tempEncoded];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@resteasy/user/%@", IP_ADDRESS_AMAZON_AWS, username]]];
        [request setValue:tempBasic64Encoded forHTTPHeaderField:@"Authorization"];
        
        NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
        
        __autoreleasing NSError* error = nil;
        if (data != nil && error == nil) {
            NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
            
            for (NSDictionary* item in json) {
                int userId = [[[item objectForKey:@"user"] objectForKey:@"userId"] integerValue];
                if (userId == 0) {
                    //do nothing
                } else {
                    NSString* jsonUsername = (NSString *)[[item objectForKey:@"user"] objectForKey:@"username"];
                    NSString* jsonPassword = (NSString *)[[item objectForKey:@"user"] objectForKey:@"password"];
                    
                    isAdmin = [[[item objectForKey:@"user"] objectForKey:@"isAdmin"] integerValue];
                    
                    user = [[User alloc] initWithUserId:userId username:jsonUsername password:jsonPassword];
                }
            }
        }
        dispatch_async( dispatch_get_main_queue(), ^{
            NSString * pass = [[NSString alloc] initWithData:[Base64 decode:[user password]] encoding:NSUTF8StringEncoding];
            if ([[user username] isEqualToString:username] && [pass isEqualToString:password])
            {
                AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                
                NSString* str = [NSString stringWithFormat:@"%@:%@", username, password];
                NSString * encoded = [Base64 encode:[str dataUsingEncoding:NSUTF8StringEncoding]];
                appDelegate.base64UserPass = [NSString stringWithFormat:@"Basic %@", encoded];
                appDelegate.isLoggedIn = YES;
                appDelegate.isAdmin = isAdmin;
                appDelegate.userId = [user userId];
                
                
                if (switchView.isOn) {
                    NSArray *values = [[NSArray alloc] initWithObjects:appDelegate.base64UserPass, [NSNumber numberWithBool:isAdmin], [NSNumber numberWithInt:appDelegate.userId], nil];
                    [values writeToFile:[self saveFilePath] atomically:YES];
                } else {
                    NSArray *values = [[NSArray alloc] initWithObjects:@"",nil];
                    [values writeToFile:[self saveFilePath] atomically:YES];
                }
                
                [self.delegate myModalViewControllerDidFinishLogin:self];
            } else {
                UIAlertView* failedLogin = [[UIAlertView alloc] initWithTitle:@"Failed Log In" message:@"Incorrect username or password, please try again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [failedLogin show];
            }
            [activityIndicator stopAnimating];
        });
    });
}

- (NSString *) saveFilePath
{
	NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
	return [[path objectAtIndex:0] stringByAppendingPathComponent:@"savefile.plist"];
}

- (IBAction) goToRegisterView:(id)sender
{
    [self performSegueWithIdentifier:@"RegisterSegue" sender:self];
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
    
    
    //Change colour of nav bar
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    [[self navigationController] setNavigationBarHidden:NO];
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background-gradient-2.png"]];
    
    self.myTableView.backgroundColor = [UIColor clearColor];
    
    if ([userLabel isHidden] == NO) {
        int xPos = userLabel.frame.origin.x;
        int yPos = userLabel.frame.origin.y;
        int labelWidth = userLabel.frame.size.width;
        int labelHeight = userLabel.frame.size.height;
        UIView *underline = [[UIView alloc] initWithFrame:CGRectMake(xPos, yPos + (labelHeight - 5), labelWidth, 1)];
        [underline setBackgroundColor:[UIColor whiteColor]];
        
        [self.view addSubview:underline];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch* touch = [touches anyObject];
    
    if (touch.view.tag == 201) {
        [self performSegueWithIdentifier:@"RegisterSegue" sender:self];
    }
    
    [self.view endEditing:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextFieldCell *cell = (TextFieldCell *)[tableView
                                            dequeueReusableCellWithIdentifier:@"LoginCell"];
    
    if (indexPath.row == 0) {
        cell.cellTextField.placeholder = @"Username";
        return cell;
    } else {
        cell.cellTextField.placeholder = @"Password";
        cell.cellTextField.secureTextEntry = YES;
        cell.cellTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        cell.cellTextField.autocorrectionType = UITextAutocorrectionTypeNo;
        cell.cellTextField.returnKeyType = UIReturnKeyDone; 
        return cell;
    } 
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    originalCenter = self.view.center;
    
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[textField superview] superview]];
    
    if (indexPath.row == 1) {
        //self.view.center = CGPointMake(self.originalCenter.x, self.originalCenter.y - 40);
    }
}


- (void) textFieldDidEndEditing:(UITextField *)textField {
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[textField superview] superview]];
    
    // From here on you can (switch) your indexPath.section or indexPath.row
    // as appropriate to get the textValue and assign it to a variable, for instance:
    if (indexPath.row == 0) {
        username = textField.text;
    } else {
        password = textField.text;
        self.view.center = originalCenter;
    }
}

- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[textField superview] superview]];
    
    if(indexPath.row == 1)
    {
        password = textField.text;
        [self signIn:self];
    }
    
    return YES;
}

- (IBAction) updateUserDetails:(id)sender
{
    NSIndexPath *indexPath = [self.myTableView indexPathForCell:(TextFieldCell*)[[sender superview] superview]];
    
    if (indexPath.row == 0) {
        username = ((UITextField *)sender).text;
    } else if (indexPath.row == 1) {
        password = ((UITextField *)sender).text;
    }
}

@end
