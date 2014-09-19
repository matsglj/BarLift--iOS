//
//  SMSettingsViewController.h
//  BarLift
//
//  Created by Shikhar Mohan on 9/18/14.
//  Copyright (c) 2014 Shikhar Mohan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SMSettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate>
@property (strong, nonatomic) PFObject *deal;
@property (strong, nonatomic) NSMutableArray *locationSettingsArray;
@end
