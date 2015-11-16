//
//  EarthquakeMonitorTests.m
//  EarthquakeMonitorTests
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "USGSDataFeeder.h"

@interface EarthquakeMonitorTests : XCTestCase

@end

@implementation EarthquakeMonitorTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testJsonParser {
    // This is an example of a functional test case.
    NSBundle *testbundle = [NSBundle bundleForClass:[self class]];
    NSURL *resourceurl = [testbundle URLForResource:@"geojson_hour" withExtension:@"json"];
    NSString *resourcedata = [NSString stringWithContentsOfURL:resourceurl encoding:NSUTF8StringEncoding error:nil];
    NSDictionary *geojsonDict = [USGSDataFeeder loadDataFromUSGS:resourcedata];
    NSArray *features = [geojsonDict valueForKey:@"features"];
    XCTAssertEqual(features.count, 5);
}

- (void)testPerformanceJsonParser {
    // This is an example of a performance test case.
    NSURL *resourceurl = [NSURL URLWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson"];
    NSString *resourcedata = [NSString stringWithContentsOfURL:resourceurl encoding:NSUTF8StringEncoding error:nil];
    
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
        
        NSDictionary *geojsonDict = [USGSDataFeeder loadDataFromUSGS:resourcedata];
        [geojsonDict valueForKey:@"features"];
    }];
}

@end
