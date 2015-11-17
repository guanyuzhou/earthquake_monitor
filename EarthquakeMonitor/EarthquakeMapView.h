//
//  EarthquakeMapView.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ArcGIS/ArcGIS.h>

// Note that this id belongs to Guanyu Zhou. It shouldn't be abused out of this app
#define CLIENT_ID @"5Tz5DMOpLbPR0rx1"

@interface EarthquakeMapView : UIView <AGSMapViewLayerDelegate>

@property id detailItem;

- (void)configurePins:(id)data;

// map view
@property AGSMapView *mapView;
@property AGSGraphicsLayer *pinLayer;
@property AGSGeometry *pin;
@property (weak) UIViewController *controller;

- (void)mapTypeChanged;

@end
