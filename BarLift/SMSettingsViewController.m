//
//  SMSettingsViewController.m
//  BarLift
//
//  Created by Shikhar Mohan on 9/18/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import "SMSettingsViewController.h"
#import "Reachability.h"

@interface SMSettingsViewController ()
@property (strong, nonatomic) Reachability *internetReachableFoo;


@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UITextField *textField;
@property (strong, nonatomic) IBOutlet UIButton *submitButton;
@property (strong, nonatomic) IBOutlet UIButton *poppinButton;
@property (strong, nonatomic) IBOutlet UIPickerView *locationPicker;


//data
@property (strong, nonatomic) NSArray *days;
@property (strong, nonatomic) NSMutableArray *push;
@property (strong, nonatomic) NSString *todaysDate;

@end

@implementation SMSettingsViewController
@synthesize deal;
@synthesize locationSettingsArray;

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
    [self testInternetConnection];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.days = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday"];
    self.push = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser][@"Monday"],[PFUser currentUser][@"Tuesday"],[PFUser currentUser][@"Wednesday"],[PFUser currentUser][@"Thursday"],[PFUser currentUser][@"Friday"],[PFUser currentUser][@"Saturday"],[PFUser currentUser][@"Sunday"],nil];
    [self getDate];
    //keyboard listeners
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    if([[PFUser currentUser][@"barlift_rep"] isEqualToValue:@YES] && [self.todaysDate isEqualToString:deal[@"deal_date"]])
    {
        self.poppinButton.hidden = NO;
    }
    else
    {
        self.poppinButton.hidden = YES;
    }
    // Do any additional setup after loading the view.
    if(!locationSettingsArray)
    {
        locationSettingsArray = [[NSMutableArray alloc] initWithObjects:[PFUser currentUser][@"university_name"], nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - Push Settings
    
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.days count];

}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingsCell"];
    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"settingsCell"];
    }
    cell.textLabel.text = self.days[indexPath.row];
    if([self.push[indexPath.row]  isEqual: @YES])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath   *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    
    UITableViewCell *theCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (theCell.accessoryType == UITableViewCellAccessoryNone) {
        theCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [PFUser currentUser][self.days[indexPath.row]] = @YES;
    }
    
    else if (theCell.accessoryType == UITableViewCellAccessoryCheckmark) {
        theCell.accessoryType = UITableViewCellAccessoryNone;
        [PFUser currentUser][self.days[indexPath.row]] = @NO;
    }

}

#pragma mark - BarLift Reps
- (void)keyboardWasShown:(NSNotification *)notification
{
    
    // Step 1: Get the size of the keyboard.
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    
    // Step 2: Adjust the bottom content inset of your scroll view by the keyboard height.
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
    
    // Step 3: Scroll the target text field into view.
    CGRect aRect = self.view.frame;
    aRect.size.height -= keyboardSize.height;
    if (!CGRectContainsPoint(aRect, self.textField.frame.origin) ) {
        CGPoint scrollPoint = CGPointMake(0.0, self.textField.frame.origin.y - (keyboardSize.height-15));
        [self.scrollView setContentOffset:scrollPoint animated:YES];
    }
}
- (void) keyboardWillHide:(NSNotification *)notification {
    
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.textField = textField;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.textField = nil;
}

- (IBAction)dismissKeyboard:(UITextField *)sender
{
    [self checkBarliftRep];
    [self resignFirstResponder];

}

- (IBAction)submitButtonPressed:(UIButton *)sender
{
    [self checkBarliftRep];
    [self resignFirstResponder];
}

- (void) checkBarliftRep
{
    [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
        if(!error)
        {
            NSString *key = config[@"barlift_rep_key"];
            if([key isEqualToString:self.textField.text])
            {
                [PFUser currentUser][@"barlift_rep"] = @YES;
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Welcome BarLift Rep!" message:@"You now get access to the It's Poppin' button!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
                [[PFUser currentUser] saveInBackground];
                self.poppinButton.hidden = NO;
            }
            else{
                UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Incorrect Rep Code" message:@"Please try again or contact BarLift." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];

            }
        
        }
    }];

}

- (IBAction)poppinButtonPressed:(UIButton *)sender {
    
    NSLog(@"It's Popping");
}


- (void) getDate
{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd'"]; // Set date and time styles
    [dateFormatter setTimeZone:[NSTimeZone localTimeZone]];
    self.todaysDate = [dateFormatter stringFromDate:date];
    
}


#pragma mark - Location Settings

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent: (NSInteger)component
{
    return [locationSettingsArray count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row   forComponent:(NSInteger)component
{
    return [locationSettingsArray objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row   inComponent:(NSInteger)component
{
    NSLog(@"Selected Row %d", row);
    [PFUser currentUser][@"university_name"] = locationSettingsArray[row];
    [[PFUser currentUser] saveInBackground];

}


#pragma mark - Reachability
// Checks if we have an internet connection or not
- (void)testInternetConnection
{
    self.internetReachableFoo = [Reachability reachabilityWithHostname:@"www.google.com"];
    
    // Internet is reachable
    self.internetReachableFoo.reachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"Yayyy, we have the interwebs!");
        });
    };
    
    // Internet is not reachable
    self.internetReachableFoo.unreachableBlock = ^(Reachability*reach)
    {
        // Update the UI on the main thread
        dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Network Connection Issue" message:@"Please check your connection and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
            [alertView show];
            NSLog(@"Someone broke the internet :(");
        });
    };
    
    [self.internetReachableFoo startNotifier];
}


@end