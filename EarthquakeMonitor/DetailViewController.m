//
//  DetailViewController.m
//  EarthquakeMonitor
//
//  This is the detail view controller
//  In this controller, we show more information about the selected earthquake
//  e.g., place, location, date, time and depth
//  A map is shown at the bottom half of the screen, with a labeled and colored pin pointing to the epi-center
//  
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import "DetailViewController.h"
#import "USGSDataFeeder.h"
#import "ARCGISHelper.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

//  Here we configure the views (only the data/contents) in this controller
- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        
        NSDictionary *properties = [self.detailItem valueForKey:@"properties"];
        NSDictionary *geometry = [self.detailItem valueForKey:@"geometry"];
        NSString *place = [properties valueForKey:@"place"];
        NSNumber *mag = [properties valueForKey:@"mag"];
        NSNumber *time = [properties valueForKey:@"time"];
        NSArray *coordinates = [geometry valueForKey:@"coordinates"];
        
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:time.longLongValue/1000];
        NSDateFormatter *formatter= [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateFormat:@"MM/dd/yyyy"];
        NSString *dateString = [formatter stringFromDate:date];
        [formatter setDateFormat:@"hh:mm a"];
        NSString *timeString = [formatter stringFromDate:date];
        
        //self.navigationItem.title = place;
        
        if(mag.stringValue.length>4)
            self.label_mag.text = [NSString stringWithFormat:@"%@", [mag.stringValue substringToIndex:4]];
        else
            self.label_mag.text = [NSString stringWithFormat:@"%@", mag.stringValue];
        
        //self.label_mag.text = [NSString stringWithFormat:@"%@",mag.stringValue];
        self.label_mag.textColor = [USGSDataFeeder getColorForMagnitude:mag.doubleValue];
        
        self.label_place.text = place;
        self.label_date.text = dateString;
        self.label_time.text = timeString;
        self.label_location.text = [NSString stringWithFormat:@"%@ , %@",((NSNumber *)[coordinates objectAtIndex:0]).stringValue,((NSNumber *)[coordinates objectAtIndex:1]).stringValue];
        self.label_depth.text = [NSString stringWithFormat:@"%@ km",((NSNumber *)[coordinates objectAtIndex:2]).stringValue];
        
        [self.earthquakeMapView configurePins:self.detailItem];
        
        
    }
}

//  Here we configure the views (only the views/containers) in this controller
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    float baseline = self.navigationController.navigationBar.frame.size.height;
    float heightunit = self.view.frame.size.width/16;
    float maglabel_width = self.view.frame.size.width/6;
    
    self.label_mag = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.width-maglabel_width, 20+baseline+heightunit, maglabel_width, 4*heightunit)];
    self.label_mag.textAlignment = NSTextAlignmentCenter;
    self.label_mag.font = [UIFont boldSystemFontOfSize:maglabel_width*0.4];
    [self.view addSubview:self.label_mag];
    
    self.label_place = [[UILabel alloc] initWithFrame:CGRectMake(heightunit/2, 20+baseline, self.view.frame.size.width-heightunit, heightunit)];
    self.label_place.textAlignment = NSTextAlignmentLeft;
    self.label_place.font = [UIFont boldSystemFontOfSize:heightunit*0.6];
    [self.view addSubview:self.label_place];
    
    self.label_date = [[UILabel alloc] initWithFrame:CGRectMake(heightunit*1.5, 20+baseline+heightunit, self.view.frame.size.width-maglabel_width-2*heightunit, heightunit)];
    self.label_date.textAlignment = NSTextAlignmentLeft;
    self.label_date.font = [UIFont systemFontOfSize:heightunit*0.6];
    [self.view addSubview:self.label_date];
    
    self.label_time = [[UILabel alloc] initWithFrame:CGRectMake(heightunit*1.5, 20+baseline+2*heightunit, self.view.frame.size.width-maglabel_width-2*heightunit, heightunit)];
    self.label_time.textAlignment = NSTextAlignmentLeft;
    self.label_time.font = [UIFont systemFontOfSize:heightunit*0.6];
    [self.view addSubview:self.label_time];
    
    self.label_location = [[UILabel alloc] initWithFrame:CGRectMake(heightunit*1.5, 20+baseline+3*heightunit, self.view.frame.size.width-maglabel_width-2*heightunit, heightunit)];
    self.label_location.textAlignment = NSTextAlignmentLeft;
    self.label_location.font = [UIFont systemFontOfSize:heightunit*0.6];
    [self.view addSubview:self.label_location];
    
    self.label_depth = [[UILabel alloc] initWithFrame:CGRectMake(heightunit*1.5, 20+baseline+4*heightunit, self.view.frame.size.width-maglabel_width-2*heightunit, heightunit)];
    self.label_depth.textAlignment = NSTextAlignmentLeft;
    self.label_depth.font = [UIFont systemFontOfSize:heightunit*0.6];
    [self.view addSubview:self.label_depth];
    
    self.imageview_date = [[UIImageView alloc] initWithFrame:CGRectMake(heightunit*0.5, 20+baseline+1.1*heightunit, heightunit*0.8, heightunit*0.8)];
    self.imageview_date.image = [UIImage imageNamed:@"date.png"];
    [self.view addSubview:self.imageview_date];
    
    self.imageview_time = [[UIImageView alloc] initWithFrame:CGRectMake(heightunit*0.5, 20+baseline+2.1*heightunit, heightunit*0.8, heightunit*0.8)];
    self.imageview_time.image = [UIImage imageNamed:@"time.png"];
    [self.view addSubview:self.imageview_time];
    
    self.imageview_location = [[UIImageView alloc] initWithFrame:CGRectMake(heightunit*0.5, 20+baseline+3.1*heightunit, heightunit*0.8, heightunit*0.8)];
    self.imageview_location.image = [UIImage imageNamed:@"location.png"];
    [self.view addSubview:self.imageview_location];
    
    self.imageview_depth = [[UIImageView alloc] initWithFrame:CGRectMake(heightunit*0.5, 20+baseline+4.1*heightunit, heightunit*0.8, heightunit*0.8)];
    self.imageview_depth.image = [UIImage imageNamed:@"depth.png"];
    [self.view addSubview:self.imageview_depth];
    
    self.earthquakeMapView = [[EarthquakeMapView alloc] initWithFrame:CGRectMake(0, 20+baseline+5*heightunit , self.view.frame.size.width, self.view.frame.size.height-(20+baseline+5*heightunit))];
    self.earthquakeMapView.controller = self;
    [self.view addSubview:self.earthquakeMapView];
    
    
    [self configureView];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
