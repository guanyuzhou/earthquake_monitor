//
//  USGSDataFeeder.m
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import "USGSDataFeeder.h"

@implementation USGSDataFeeder

// parse GeoJson
+ (NSDictionary *) loadDataFromUSGS:(NSString *)geojsonString {
    NSError *error;
    NSDictionary *geojsonDict = [NSJSONSerialization JSONObjectWithData:[geojsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    
    //cache data to local drive
    dispatch_async( dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *document_folder=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject];
        NSString *path = [[document_folder path] stringByAppendingPathComponent:@"pasthour_cache"];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        NSError *fileWritenError;
        [[NSFileManager defaultManager] createFileAtPath:path contents:nil attributes:nil];
        [geojsonString writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:&fileWritenError];
        NSLog(@"%@",fileWritenError);
    });
    
    
    return geojsonDict;
}

+ (NSDictionary *) loadDataFromCache {
    
    NSDictionary *geojsonDict;
    NSURL *document_folder=[[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                   inDomains:NSUserDomainMask] lastObject];
    NSString *path = [[document_folder path] stringByAppendingPathComponent:@"pasthour_cache"];
    
    NSString *geojsonString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    if(!geojsonString)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Failed to load data"
                                                        message:@"Failed to connect server and no cached data is found"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Loaded from cached data"
                                                        message:nil
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        NSError *error;
        geojsonDict = [NSJSONSerialization JSONObjectWithData:[geojsonString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingMutableContainers error:&error];
    }
    
    
    
    return geojsonDict;
}

+ (UIColor *) getColorForMagnitude:(double) magnitude {
    if(magnitude>=9.0)
        return [UIColor colorWithRed:0.8 green:0.2 blue:0.1 alpha:1.0];
    else if(magnitude<=0.9)
        return [UIColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    else if(magnitude<3.0)
        return [UIColor colorWithRed:0.25 green:0.8 blue:0.05 alpha:1.0];
    else if(magnitude<6.0)
        return [UIColor colorWithRed:0.5 green:0.6 blue:0.05 alpha:1.0];
    else
        return [UIColor colorWithRed:0.7 green:0.4 blue:0.1 alpha:1.0];
}

+ (UIImage *) getColoredPinForMagnitude:(NSNumber *) magnitude {
    
    UIColor *color = [USGSDataFeeder getColorForMagnitude:magnitude.doubleValue];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(32,96), NO, 0);
    UIBezierPath* p = [UIBezierPath bezierPathWithArcCenter:CGPointMake(16, 16) radius:16 startAngle:DEGREES_TO_RADIANS(30) endAngle:DEGREES_TO_RADIANS(150) clockwise:false];
    [p addLineToPoint:CGPointMake(16, 48)];
    [p closePath];
    [color setFill];
    [[UIColor blackColor] setStroke];
    [p fill];
    [p stroke];
    CGRect rect = CGRectMake(2, 6, 28, 24);
    NSMutableParagraphStyle *style = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentCenter;
    [magnitude.stringValue drawInRect:CGRectIntegral(rect) withAttributes:@{NSFontAttributeName:
                                                                                [UIFont boldSystemFontOfSize:12], NSParagraphStyleAttributeName: style,
                                                                            NSForegroundColorAttributeName:magnitude.doubleValue<3.0?[UIColor blackColor]:[UIColor whiteColor]}];
    UIImage* pin = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return pin;
}

@end
