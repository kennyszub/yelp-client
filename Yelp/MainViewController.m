//
//  MainViewController.m
//  Yelp
//
//  Created by Timothy Lee on 3/21/14.
//  Copyright (c) 2014 codepath. All rights reserved.
//

#import "MainViewController.h"
#import "YelpClient.h"
#import "Business.h"
#import "BusinessCell.h"
#import "FiltersViewController.h"
#import "UIScrollView+SVInfiniteScrolling.h"

NSString * const kYelpConsumerKey = @"vxKwwcR_NMQ7WaEiQBK_CA";
NSString * const kYelpConsumerSecret = @"33QCvh5bIF5jIHR5klQr7RtBDhQ";
NSString * const kYelpToken = @"uRcRswHFYa1VkDrGV6LAW2F8clGh5JHV";
NSString * const kYelpTokenSecret = @"mqtKIxMIR4iBtBPZCmCLEb-Dz3Y";

@interface MainViewController () <UITableViewDataSource, UITableViewDelegate, FiltersViewControllerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) YelpClient *client;
@property (nonatomic, strong) NSMutableArray *businesses;
@property (weak, nonatomic) UISearchBar *searchBar;
@property (strong, nonatomic) UIGestureRecognizer *screenTapRecognizer;
@property (strong, nonatomic) NSString *searchTerm;
@property (strong, nonatomic) NSDictionary *currentFilters;
@property (nonatomic, assign) NSInteger currentOffset;

- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params offset:(NSInteger)offset;

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
        self.client = [[YelpClient alloc] initWithConsumerKey:kYelpConsumerKey consumerSecret:kYelpConsumerSecret accessToken:kYelpToken accessSecret:kYelpTokenSecret];
        
        [self fetchBusinessesWithQuery:@"Restaurants" params:nil offset:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"BusinessCell" bundle:nil] forCellReuseIdentifier:@"BusinessCell"];
    
    [self.tableView addInfiniteScrollingWithActionHandler:^{
        [self getMoreData];
    }];
    
    // calculates row height using autolayout params (in iOS8 only)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    self.title = @"Yelp";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Filter" style:UIBarButtonItemStylePlain target:self action:@selector(onFilterButton)];
    self.searchTerm = @"Restaurants";
    self.currentFilters = nil;
    self.currentOffset = 0;
    
    // add and setup search bar
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    self.searchBar = searchBar;
    self.searchBar.text = self.searchTerm;
    self.navigationItem.titleView = self.searchBar;
    self.searchBar.delegate = self;
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    self.screenTapRecognizer = gestureRecognizer;
    UITextField *textField = [self.searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search methods
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    self.searchTerm = searchBar.text;
    [self hideKeyboard];
    self.currentFilters = nil;
    self.currentOffset = 0;
    [self fetchBusinessesWithQuery:self.searchTerm params:nil offset:0];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.tableView addGestureRecognizer:self.screenTapRecognizer];
    self.searchBar.showsCancelButton = YES;
    // add clear button
    UITextField *textField = [searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeWhileEditing;
}

- (void)searchBarTextDidEndEditing:(UISearchBar *)searchBar {
    [self.tableView removeGestureRecognizer:self.screenTapRecognizer];
    // remove clear button
    UITextField *textField = [self.searchBar valueForKey:@"_searchField"];
    textField.clearButtonMode = UITextFieldViewModeNever;
    if ([self.searchBar.text length] == 0) {
        self.searchBar.text = self.searchTerm;
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self hideKeyboard];
    [self.tableView removeGestureRecognizer:self.screenTapRecognizer];
}

-(void)hideKeyboard {
    self.searchBar.showsCancelButton = NO;
    [self.navigationItem.titleView endEditing:YES];
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.businesses.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BusinessCell *cell = [tableView dequeueReusableCellWithIdentifier:@"BusinessCell" forIndexPath:indexPath];
    cell.business = self.businesses[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}


#pragma mark - Filter delegate methods
- (void)filtersViewController:(FiltersViewController *)filtersViewController didChangeFilters:(NSDictionary *)filters {
    // fire a new network event.
    NSLog(@"fire new network event: %@", filters);
    self.currentFilters = filters;
    self.currentOffset = 0;
    [self fetchBusinessesWithQuery:self.searchTerm params:filters offset:0];
}

#pragma mark - Private methods
- (void)fetchBusinessesWithQuery:(NSString *)query params:(NSDictionary *)params offset:(NSInteger)offset {
    [self.client searchWithTerm:query params:params offset:offset success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessDictionaries = response[@"businesses"];
        self.businesses = [Business businessesWithDictionaries:businessDictionaries];
        [self.tableView reloadData];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void)getMoreData {
    self.currentOffset += 20;
    [self.client searchWithTerm:self.searchTerm params:self.currentFilters offset:self.currentOffset success:^(AFHTTPRequestOperation *operation, id response) {
        NSLog(@"response: %@", response);
        NSArray *businessDictionaries = response[@"businesses"];
        if (businessDictionaries.count > 0) {
            [self.businesses addObjectsFromArray:[Business businessesWithDictionaries:businessDictionaries]];
            [self.tableView reloadData];
        }

        [self.tableView.infiniteScrollingView stopAnimating];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"error: %@", [error description]);
    }];
}

- (void) onFilterButton {
    FiltersViewController *vc = [[FiltersViewController alloc] init];
    vc.delegate = self;
    
    UINavigationController *nvc = [[UINavigationController alloc] initWithRootViewController:vc];
    [self presentViewController:nvc animated:YES completion:nil];
}

@end
