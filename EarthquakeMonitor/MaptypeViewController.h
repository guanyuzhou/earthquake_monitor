//
//  MaptypeViewController.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ARCGISHelper.h"
#import "EarthquakeMapView.h"

@interface MaptypeViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property NSMutableArray *maptypes;
@property NSIndexPath *lastIndexPath;
@property (weak) EarthquakeMapView *maptypeChangedTarget;
@end
