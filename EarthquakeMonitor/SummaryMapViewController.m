//
//  SummaryMapViewController.m
//  EarthquakeMonitor
//
//  Created by Guanyu Zhou on 11/11/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import "SummaryMapViewController.h"

@interface SummaryMapViewController ()

@end

@implementation SummaryMapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.earthquakeMapView = [[EarthquakeMapView alloc] initWithFrame:CGRectMake(0, 0 , self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:self.earthquakeMapView];
    self.earthquakeMapView.controller = self;
    [self.earthquakeMapView configurePins:self.data];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu.png"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id<UIGestureRecognizerDelegate>)self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)back {
    [self.navigationController popViewControllerAnimated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
