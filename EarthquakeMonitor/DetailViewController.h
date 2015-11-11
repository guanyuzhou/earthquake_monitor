//
//  DetailViewController.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>
#import "EarthquakeMapView.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;
// textual labels
@property UILabel *label_mag;
@property UILabel *label_date;
@property UILabel *label_time;
@property UILabel *label_location;
@property UILabel *label_place;
@property UILabel *label_depth;
// icon views
@property UIImageView *imageview_date;
@property UIImageView *imageview_time;
@property UIImageView *imageview_location;
@property UIImageView *imageview_depth;
@property EarthquakeMapView *earthquakeMapView;

@end

