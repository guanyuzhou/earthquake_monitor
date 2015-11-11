//
//  MasterViewController.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DetailViewController;

@interface MasterViewController : UITableViewController <NSURLConnectionDelegate>

@property (strong, nonatomic) DetailViewController *detailViewController;
@property NSMutableData *_responseData;

@end

