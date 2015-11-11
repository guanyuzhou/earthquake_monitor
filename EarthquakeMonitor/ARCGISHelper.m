//
//  ARCGISHelper.m
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import "ARCGISHelper.h"

@implementation ARCGISHelper

+(NSString *)getOfflineMapServiceURL:(NSString *)type {
    if([type isEqualToString:type_satellite])
        return @"http://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Imagery/MapServer";
    else if([type isEqualToString:type_topo])
        return @"http://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Topo_Map/MapServer";
    else
        return @"http://tiledbasemaps.arcgis.com/arcgis/rest/services/World_Street_Map/MapServer";
}

+(NSString *)getMapServiceURL:(NSString *)type {
    if([type isEqualToString:type_satellite])
        return @"http://services.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer";
    else if([type isEqualToString:type_topo])
        return @"http://services.arcgisonline.com/ArcGIS/rest/services/World_Topo_Map/MapServer";
    else
        return @"http://services.arcgisonline.com/ArcGIS/rest/services/World_Street_Map/MapServer";
}

static NSString *maptype = nil;

+(NSString *)getMaptype
{
    @synchronized(self)
    {
        if(maptype==nil)
        {
            maptype = type_street;
        }
    }
    return maptype;
}

+(void)setMaptype:(NSString *)newtype {
    maptype = newtype;
}

@end
