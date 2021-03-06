//
//  MasterViewController.m
//  EarthquakeMonitor
//
//  This is the master view of the split view. The summary of the eathquakes will be shown as a list in the summary view.
//  Navigation bar:
//  This master view supports pull-to-refresh and press-button-to-refresh. The refresh button is placed at the right of the navigation bar
//  The left button of the navigation bar points to a controller that display summary of earthquakes on a map.
//  Row/Cells:
//  Each row is colored and labeled according to the magnitude of the earthquake. Place of the earthquake is shown in the cell
//  Each row is marked with a detail-disclosure-indicator
//  Row height is calculated based on the length of string
//
//  Created by Guanyu Zhou on 11/10/15.
//  Copyright (c) 2015 Guanyu Zhou. All rights reserved.
//

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "USGSDataFeeder.h"
#import "SummaryMapViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)awakeFromNib {
    [super awakeFromNib];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UIBarButtonItem *summaryOnMap = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"world.png"] style:UIBarButtonItemStylePlain target:self action:@selector(summaryOnMapPressed)];
    self.navigationItem.leftBarButtonItem = summaryOnMap;

    //UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(insertNewObject:)];
    //self.navigationItem.rightBarButtonItem = addButton;
    self.detailViewController = (DetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    
    [self sendRequestForEarthquakeData];
    
    //to add the UIRefreshControl to UIView
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Please Wait..."]; //to give the attributedTitle
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:refreshControl];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refreshPressed)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setToolbarHidden:false];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// insertion of data to the list (not used)
- (void)insertNewObject:(id)data {
    if (!self.objects) {
        self.objects = [[NSMutableArray alloc] init];
    }
    [self.objects insertObject:data atIndex:0];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

// download and refresh the list from pull-to-refresh
- (void)refresh:(UIRefreshControl *)refreshControl
{
    [self sendRequestForEarthquakeData];
    [refreshControl endRefreshing];
}

// display summary on a map. go to another controller
- (void)summaryOnMapPressed {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SummaryMap"];
    [self.navigationController pushViewController:controller animated:YES];
    controller.navigationItem.title = self.title;
    ((SummaryMapViewController *)controller).data = self.objects;
    
}

// download and refresh the list from prefresh button
- (void)refreshPressed {
    [self sendRequestForEarthquakeData];
}

#pragma mark - Segues
// go to the detail view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        NSDate *object = self.objects[indexPath.row];
        DetailViewController *controller = (DetailViewController *)[[segue destinationViewController] topViewController];
        [controller setDetailItem:object];
        controller.navigationItem.leftBarButtonItem = self.splitViewController.displayModeButtonItem;
        controller.navigationItem.leftItemsSupplementBackButton = YES;
    }
}

#pragma mark - Table View
// data delegates of the table view
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.objects.count;
}
// load/reuse/create cells
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

    NSDictionary *featureObject = self.objects[indexPath.row];
    NSDictionary *properties = [featureObject valueForKey:@"properties"];
    NSString *place = [properties valueForKey:@"place"];
    NSNumber *mag = [properties valueForKey:@"mag"];
    [cell.textLabel setHidden:true];
    
    UILabel *magLabel;
    if(![cell viewWithTag:1])
    {
        magLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 70, cell.frame.size.height-1)];
        [cell.contentView addSubview:magLabel];
        magLabel.textAlignment = NSTextAlignmentCenter;
        magLabel.tag = 1;
    }
    else
        magLabel = (UILabel *)[cell viewWithTag:1];
    magLabel.backgroundColor = [USGSDataFeeder getColorForMagnitude:mag.doubleValue];
    [magLabel setFont:[UIFont boldSystemFontOfSize:23]];
    if(mag.stringValue.length>4)
        magLabel.text = [NSString stringWithFormat:@"%@", [mag.stringValue substringToIndex:4]];
    else
        magLabel.text = [NSString stringWithFormat:@"%@", mag.stringValue];
    
    UILabel *textLabel;
    if(![cell viewWithTag:2])
    {
        textLabel = [[UILabel alloc] initWithFrame:CGRectMake(75, 0, cell.textLabel.frame.size.width-75, cell.frame.size.height-1)];
        textLabel.tag = 2;
        [cell.contentView addSubview:textLabel];
    }
    else
        textLabel = (UILabel *)[cell viewWithTag:2];
    [textLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [textLabel setNumberOfLines:0];
    [textLabel setLineBreakMode:NSLineBreakByWordWrapping];
    textLabel.text = place;
    
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleDefault;
    
    return cell;
}
//  we won't allow users to edit rows
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.objects removeObjectAtIndex:indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }
}
//  automatically adjust row height based on the length of the string
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *featureObject = self.objects[indexPath.row];
    NSDictionary *properties = [featureObject valueForKey:@"properties"];
    NSString *place = [properties valueForKey:@"place"];
    CGSize size = [place sizeWithAttributes:
                   @{NSFontAttributeName:
                         [UIFont boldSystemFontOfSize:20]}];
    return ceil(size.width/225)*24+20;
}

/*  connection lib
    delegates of NSURLConnection
    handle data transmission with server
 
 */
#pragma mark NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    self._responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self._responseData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
                  willCacheResponse:(NSCachedURLResponse*)cachedResponse {
    // Return nil to indicate not necessary to store a cached response for this connection
    return nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // The request is complete and data has been received
    // You can parse the stuff in your instance variable now
    NSString *responseString = [[NSString alloc] initWithData:self._responseData encoding:NSUTF8StringEncoding];
    self._responseData = nil;
    NSLog(@"%@",responseString);
    // parse the json string
    NSDictionary *geojsonDict = [USGSDataFeeder loadDataFromUSGS:responseString];
    [self configureTable:geojsonDict];
    
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    // The request has failed for some reason!
    // Check the error var
    NSLog(@"%@",error);
    
    NSDictionary *geojsonDict = [USGSDataFeeder loadDataFromCache];
    [self configureTable:geojsonDict];
}

//  Call this method to send a request to USGS
//  We can easily secure the request with HTTPS
- (void) sendRequestForEarthquakeData {
    NSMutableString *url = [[NSMutableString alloc] initWithString:@"http://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.geojson"];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithString:url ]]];
    
    // Specify that it will be a POST request
    request.HTTPMethod = @"GET";
    
    // Create url connection and fire request
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    if(!conn)
    {
        
    }
}

/*  Configuration method
    Given a collection of earthquakes, set up the table and title
*/


- (void)configureTable:(NSDictionary *)geojsonDict {
    if(geojsonDict)
    {
        self.objects = [geojsonDict valueForKey:@"features"];
        [self.tableView reloadData];
        NSDictionary *metadata = [geojsonDict valueForKey:@"metadata"];
        self.title = [metadata valueForKey:@"title"];
        
        if(self.objects.count==0)
        {
            UIAlertView *noEarthquakeAlert = [[UIAlertView alloc] initWithTitle:@"No Earthquakes" message:nil delegate:nil cancelButtonTitle:@"Good" otherButtonTitles:nil];
            [noEarthquakeAlert show];
        }
    }
    else
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"Malformed data"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}


@end
