//
//  USGSDataFeeder.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <math.h>
#define   DEGREES_TO_RADIANS(degrees)  ((3.1415926 * degrees)/ 180)

@interface USGSDataFeeder : NSObject

+ (NSDictionary *) loadDataFromUSGS:(NSString *)geojsonString;
+ (UIColor *) getColorForMagnitude:(double) magnitude;
+ (UIImage *) getColoredPinForMagnitude:(NSNumber *) magnitude;
+ (NSDictionary *) loadDataFromCache;
@end
