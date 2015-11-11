//
//  ARCGISHelper.h
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <Foundation/Foundation.h>

#define type_street @"Street Map"
#define type_satellite @"Satellite Imagery"
#define type_topo @"Topographic Map"

@interface ARCGISHelper : NSObject

+(NSString *)getMapServiceURL:(NSString *)type;
+(NSString *)getOfflineMapServiceURL:(NSString *)type;
+(NSString *)getMaptype;
+(void)setMaptype:(NSString *)newtype;
@end
