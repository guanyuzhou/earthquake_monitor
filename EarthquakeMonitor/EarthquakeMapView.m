//
//  EarthquakeMapView.m
//  EarthquakeMonitor
//
//  View of the map that displays epi-center
//  Support colored and labeled pins based on the magnitude
//  Support multuple pins
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import "EarthquakeMapView.h"
#import "ARCGISHelper.h"
#import "USGSDataFeeder.h"
#import "MaptypeViewController.h"

@implementation EarthquakeMapView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.mapView = [[AGSMapView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    
    NSURL* url = [NSURL URLWithString:[ARCGISHelper getMapServiceURL: [ARCGISHelper getMaptype]]];
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView addMapLayer:tiledLayer withName:@"Basemap Tiled Layer"];
    [self.mapView enableWrapAround];
    //Set the map view's layerDelegate
    self.mapView.layerDelegate = self;
    [self addSubview:self.mapView];
    
    self.pinLayer = [[AGSGraphicsLayer alloc] initWithSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
    [self.mapView addMapLayer:self.pinLayer];
    
    
    // if we have Esri's client id, put it here to elimite the developer use watermark
    NSError *error;
    [AGSRuntimeEnvironment setClientID:CLIENT_ID error:&error];
    if(error){
        // We had a problem using our client ID
        NSLog(@"Error using client ID : %@",[error localizedDescription]);
    }
    
    // add a toolbar
    UIToolbar *toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, frame.size.height-44, frame.size.width, 44)];
    [toolbar setTintColor:[UIColor whiteColor]];
    [toolbar setBarStyle:UIBarStyleBlack];
    [self addSubview:toolbar];
    
    // add a button where user can choose base map type
    UIBarButtonItem *mapTypeButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"layers.png"] style:UIBarButtonItemStylePlain target:self action:@selector(mapTypeButtonPressed)];
    toolbar.items = @[mapTypeButton];
    return self;
}

// call the controller where user can change base map type
- (void)mapTypeButtonPressed {
    
    MaptypeViewController *mUIViewController = [self.controller.storyboard instantiateViewControllerWithIdentifier:@"MaptypeViewController"];
    [self.controller.navigationController pushViewController:mUIViewController animated:YES];;
    mUIViewController.maptypeChangedTarget = self;
}

// the callback of map type being changed
- (void)mapTypeChanged {
    NSURL* url = [NSURL URLWithString:[ARCGISHelper getMapServiceURL: [ARCGISHelper getMaptype]]];
    NSLog(@"%@",[ARCGISHelper getMaptype]);
    AGSTiledMapServiceLayer *tiledLayer = [AGSTiledMapServiceLayer tiledMapServiceLayerWithURL:url];
    [self.mapView removeMapLayerWithName:@"Basemap Tiled Layer"];
    [self.mapView insertMapLayer:tiledLayer withName:@"Basemap Tiled Layer" atIndex:0];
    [self setNeedsDisplay];
}

// configure the pins on map
- (void)configurePins:(id)data {
    [self.pinLayer removeAllGraphics];
    self.detailItem = data;
    AGSGeometryEngine *engine = [AGSGeometryEngine defaultGeometryEngine];
    
    if([self.detailItem isKindOfClass:[NSDictionary class]])
    {
        //if a single pin is being displayed
        NSDictionary *properties = [self.detailItem valueForKey:@"properties"];
        NSDictionary *geometry = [self.detailItem valueForKey:@"geometry"];
        NSNumber *mag = [properties valueForKey:@"mag"];
        NSArray *coordinates = [geometry valueForKey:@"coordinates"];
        
        self.pin = [engine projectGeometry:[AGSPoint pointWithX:((NSNumber *)[coordinates objectAtIndex:0]).doubleValue y:((NSNumber *)[coordinates objectAtIndex:1]).doubleValue spatialReference:[AGSSpatialReference wgs84SpatialReference]] toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
        [self.pinLayer addGraphic:[AGSGraphic graphicWithGeometry:self.pin symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[USGSDataFeeder getColoredPinForMagnitude:mag]] attributes:nil]];
    }
    else if([self.detailItem isKindOfClass:[NSArray class]] && ((NSArray *)self.detailItem).count>1)
    {
        //if multiple pins are being displayed
        AGSMutableMultipoint *rawGeometry = [[AGSMutableMultipoint alloc] initWithSpatialReference:[AGSSpatialReference wgs84SpatialReference]];
        for (NSDictionary *item in self.detailItem) {
            NSDictionary *properties = [item valueForKey:@"properties"];
            NSDictionary *geometry = [item valueForKey:@"geometry"];
            NSNumber *mag = [properties valueForKey:@"mag"];
            NSArray *coordinates = [geometry valueForKey:@"coordinates"];
            
            [rawGeometry addPoint:[AGSPoint pointWithX:((NSNumber *)[coordinates objectAtIndex:0]).doubleValue y:((NSNumber *)[coordinates objectAtIndex:1]).doubleValue spatialReference:[AGSSpatialReference wgs84SpatialReference]]];
            
            AGSGeometry* pin = [engine projectGeometry:[AGSPoint pointWithX:((NSNumber *)[coordinates objectAtIndex:0]).doubleValue y:((NSNumber *)[coordinates objectAtIndex:1]).doubleValue spatialReference:[AGSSpatialReference wgs84SpatialReference]] toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
            [self.pinLayer addGraphic:[AGSGraphic graphicWithGeometry:pin symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[USGSDataFeeder getColoredPinForMagnitude:mag]] attributes:nil]];
        }
        self.pin = [engine projectGeometry:rawGeometry toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
        
    }
    else if([self.detailItem isKindOfClass:[NSArray class]] && ((NSArray *)self.detailItem).count==1)
    {
        //if a single pin is being displayed in the summary map view
        NSDictionary *properties = [[self.detailItem firstObject] valueForKey:@"properties"];
        NSDictionary *geometry = [[self.detailItem firstObject] valueForKey:@"geometry"];
        NSNumber *mag = [properties valueForKey:@"mag"];
        NSArray *coordinates = [geometry valueForKey:@"coordinates"];
        
        self.pin = [engine projectGeometry:[AGSPoint pointWithX:((NSNumber *)[coordinates objectAtIndex:0]).doubleValue y:((NSNumber *)[coordinates objectAtIndex:1]).doubleValue spatialReference:[AGSSpatialReference wgs84SpatialReference]] toSpatialReference:[AGSSpatialReference webMercatorSpatialReference]];
        [self.pinLayer addGraphic:[AGSGraphic graphicWithGeometry:self.pin symbol:[AGSPictureMarkerSymbol pictureMarkerSymbolWithImage:[USGSDataFeeder getColoredPinForMagnitude:mag]] attributes:nil]];
    }
    
}

/*
    ArcGis map's delegate
    When map is loaded, we zoon to the best/minimal envelope that contains all pins
    Since earth is a globe and sometimes it does not give the best/minimal envelope
 */

- (void)mapViewDidLoad:(AGSMapView *) mapView {
    //now the map is loaded
    //zoom the map to appropriate envelope
    [mapView.locationDisplay startDataSource];
    
    double delayInSeconds = 0.4;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        //code to be executed on the main queue after delay
        NSLog(@"%@",self.pin);
        if(self.pin && [self.pin isKindOfClass:[AGSPoint class]])
        {
            //if a single pin is displayed
            [self.mapView zoomToResolution:5000 withCenterPoint:(AGSPoint *)self.pin animated:YES];
        }
        else if(self.pin)
        {
            //if more pins are displayed
            [self.mapView zoomToResolution:5000 animated:NO];
            [self.mapView zoomToGeometry:self.pin withPadding:20000 animated:YES];
        }
        
        
        
    });
    
}

@end
