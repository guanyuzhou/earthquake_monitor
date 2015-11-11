//
//  SummaryMapViewController.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EarthquakeMapView.h"

@interface SummaryMapViewController : UIViewController

@property EarthquakeMapView *earthquakeMapView;
@property id data;

@end
