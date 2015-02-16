//
//  FiltersViewController.m
//  Yelp
//
//  Created by Ken Szubzda on 2/14/15.
//  Copyright (c) 2015 codepath. All rights reserved.
//

#import "FiltersViewController.h"
#import "SwitchCell.h"

@interface FiltersViewController () <UITableViewDataSource, UITableViewDelegate, SwitchCellDelegate>

@property (nonatomic, readonly) NSDictionary *filters;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *categories;
@property (nonatomic, strong) NSMutableSet *selectedCategories;
@property (nonatomic, assign) BOOL categoriesSectionIsExpanded;
@property (nonatomic, assign) BOOL offeringDeal;

@property (nonatomic, strong) NSArray *distances;
@property (nonatomic, strong) NSIndexPath *activeDistanceCellIndexPath;
@property (nonatomic, assign) BOOL distancesSectionIsExpanded;

@property (nonatomic, strong) NSArray *sortOptions;
@property (nonatomic, strong) NSIndexPath *activeSortOptionIndexPath;
@property (nonatomic, assign) BOOL sortSectionIsExpanded;

- (void) initCategories;

@end

@implementation FiltersViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        self.selectedCategories = [NSMutableSet set];
        self.categoriesSectionIsExpanded = NO;
        [self initCategories];
        [self initDistances];
        [self initSortOptions];
        self.activeDistanceCellIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
        self.distancesSectionIsExpanded = NO;
        self.activeSortOptionIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
        self.sortSectionIsExpanded = NO;
        self.offeringDeal = NO;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.title = @"Filters";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStylePlain target:self action:@selector(onCancelButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Apply" style:UIBarButtonItemStylePlain target:self action:@selector(onApplyButton)];
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView registerNib:[UINib nibWithNibName:@"SwitchCell" bundle:nil] forCellReuseIdentifier:@"SwitchCell"];
    [self.tableView registerNib:[UINib nibWithNibName:@"CaretCell" bundle:nil] forCellReuseIdentifier:@"CaretCell"];

    // calculates row height using autolayout params (in iOS8 only)
    self.tableView.rowHeight = UITableViewAutomaticDimension;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger rowsInSection = 0;
    switch (section) {
        case 0:
            // deals
            rowsInSection = 1;
            break;
        case 1:
            // distance
            if (self.distancesSectionIsExpanded) {
                rowsInSection = self.distances.count;
            } else {
                rowsInSection = 1;
            }
            break;
        case 2:
            // sort option
            if (self.sortSectionIsExpanded) {
                rowsInSection = self.sortOptions.count;
            } else {
                rowsInSection = 1;
            }
            break;
        case 3:
            // categories
            if (self.categoriesSectionIsExpanded) {
                rowsInSection = self.categories.count;
            } else {
                rowsInSection = 5;
            }
            break;
        default:
            break;
    }
    return rowsInSection;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *sectionName = @"";
    switch (section) {
        case 0:
            sectionName = @"Deals";
            break;
        case 1:
            sectionName = @"Distance";
            break;
        case 2:
            sectionName = @"Sort by";
            break;
        case 3:
            sectionName = @"Categories";
        default:
            break;
    }
    return sectionName;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // TODO fix CaretCells getting assigned to to switch cell
    SwitchCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwitchCell" forIndexPath:indexPath];
    [cell hideSwitch:NO];
    cell.accessoryType = UITableViewCellAccessoryNone;
    switch (indexPath.section) {
        case 0:
            cell.titleLabel.text = @"Offering a Deal";
            cell.on = self.offeringDeal;
            cell.delegate = self;
            return cell;
        case 1:
            if (!self.distancesSectionIsExpanded) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CaretCell"];
                cell.titleLabel.text = @"Best Match";
            } else {
                cell.titleLabel.text = self.distances[indexPath.row][@"distance"];
                [cell hideSwitch:YES];
                if (indexPath == self.activeDistanceCellIndexPath) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                cell.delegate = self;
            }
            return cell;
        case 2:
            if (!self.sortSectionIsExpanded) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CaretCell"];
                cell.titleLabel.text = @"Best Match";
            } else {
                cell.titleLabel.text = self.sortOptions[indexPath.row][@"name"];
                [cell hideSwitch:YES];
                if (indexPath == self.activeSortOptionIndexPath) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                cell.delegate = self;
            }
            return cell;
        case 3:
            if (!self.categoriesSectionIsExpanded && indexPath.row == 4) {
                cell = [tableView dequeueReusableCellWithIdentifier:@"CaretCell"];
                cell.titleLabel.text = @"See More";
            } else {
                cell.titleLabel.text = self.categories[indexPath.row][@"name"];
                cell.on = [self.selectedCategories containsObject:self.categories[indexPath.row]];
                cell.delegate = self;
            }
            return cell;
        default:
            break;
    }
    return cell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 4;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSIndexPath *firstDistanceIndexPath = [NSIndexPath indexPathForRow:0 inSection:1];
    NSIndexPath *firstSortIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    NSIndexPath *seeMoreCategoriesIndexPath = [NSIndexPath indexPathForRow:4 inSection:3];
    
    // expand rows logic
    if (indexPath == firstDistanceIndexPath && !self.distancesSectionIsExpanded) {
        // expand distance section
        self.distancesSectionIsExpanded = YES;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationFade];
    } else if (indexPath == firstSortIndexPath && !self.sortSectionIsExpanded) {
        // expand sort section
        self.sortSectionIsExpanded = YES;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationFade];
    } else if (indexPath == seeMoreCategoriesIndexPath && !self.categoriesSectionIsExpanded) {
        // expand categories section
        self.categoriesSectionIsExpanded = YES;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:3] withRowAnimation:UITableViewRowAnimationFade];
    }
    
    // sort checkmarks
    if (indexPath.section == 2 && self.sortSectionIsExpanded && indexPath != self.activeSortOptionIndexPath) {
        SwitchCell *oldActiveCell = (SwitchCell *)[self.tableView cellForRowAtIndexPath:self.activeSortOptionIndexPath];
        oldActiveCell.accessoryType = UITableViewCellAccessoryNone;
        SwitchCell *activeCell = (SwitchCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        activeCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.activeSortOptionIndexPath = indexPath;
    // distance checkmarks
    } else if (indexPath.section == 1 && self.distancesSectionIsExpanded && indexPath != self.activeDistanceCellIndexPath) {
        SwitchCell *oldActiveCell = (SwitchCell *)[self.tableView cellForRowAtIndexPath:self.activeDistanceCellIndexPath];
        oldActiveCell.accessoryType = UITableViewCellAccessoryNone;
        SwitchCell *activeCell = (SwitchCell *)[self.tableView cellForRowAtIndexPath:indexPath];
        activeCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.activeDistanceCellIndexPath = indexPath;
    }
    
}


- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

#pragma mark Switch cell delegate methods
- (void)switchCell:(SwitchCell *)cell didUpdateValue:(BOOL)value {
    NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];
    switch (indexPath.section) {
        case 0:
            self.offeringDeal = value;
            break;
        case 1:
            if (value && indexPath != self.activeDistanceCellIndexPath) {
                SwitchCell *oldActiveCell = (SwitchCell *)[self.tableView cellForRowAtIndexPath:self.activeDistanceCellIndexPath];
                [oldActiveCell setOn:NO];
                self.activeDistanceCellIndexPath = indexPath;
            }
            break;
        case 2:
            if (value && indexPath != self.activeSortOptionIndexPath) {
                SwitchCell *oldActiveCell = (SwitchCell *)[self.tableView cellForRowAtIndexPath:self.activeSortOptionIndexPath];
                [oldActiveCell setOn:NO];
                self.activeSortOptionIndexPath = indexPath;
            }
            break;
        case 3:
            if (value) {
                [self.selectedCategories addObject:self.categories[indexPath.row]];
            } else {
                [self.selectedCategories removeObject:self.categories[indexPath.row]];
            }
            break;
        default:
            break;
    }
}

#pragma mark - Private methods

- (NSDictionary *)filters {
    NSMutableDictionary *filters = [NSMutableDictionary dictionary];
    
    if (self.selectedCategories.count > 0) {
        NSMutableArray *names = [NSMutableArray array];
        for (NSDictionary *category in self.selectedCategories) {
            [names addObject:category[@"code"]];
        }
        NSString *categoryFilter = [names componentsJoinedByString:@","];
        [filters setObject:categoryFilter forKey:@"category_filter"];
    }
    [filters setObject:@(self.offeringDeal) forKey:@"deals_filter"];
    [filters setObject:self.sortOptions[self.activeSortOptionIndexPath.row][@"code"] forKey:@"sort"];
    if (self.activeDistanceCellIndexPath.row > 0) {
        // row is not set to 'Best Match' default, so add meters param
        [filters setObject:self.distances[self.activeDistanceCellIndexPath.row][@"meters"] forKey:@"radius_filter"];
    }
    return filters;
}

- (void)onCancelButton {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)onApplyButton {
    [self.delegate filtersViewController:self didChangeFilters:self.filters];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)initSortOptions {
    self.sortOptions =
    @[@{@"name" : @"Best Match", @"code": @(0) },
      @{@"name" : @"Distance", @"code": @(1) },
      @{@"name" : @"Highest Rated", @"code": @(2) }
    ];
}

- (void)initDistances {
    self.distances =
    @[@{@"distance" : @"Best Match" },
      @{@"distance" : @"0.3 miles", @"meters": @(482.803) },
      @{@"distance" : @"1 mile", @"meters": @(1609.34) },
      @{@"distance" : @"5 miles", @"meters": @(8046.72) },
      @{@"distance" : @"20 miles", @"meters": @(32186.9) },
    ];
}

- (void)initCategories {
    self.categories =
    @[@{@"name" : @"Afghan", @"code": @"afghani" },
      @{@"name" : @"African", @"code": @"african" },
      @{@"name" : @"American, New", @"code": @"newamerican" },
      @{@"name" : @"American, Traditional", @"code": @"tradamerican" },
      @{@"name" : @"Arabian", @"code": @"arabian" },
      @{@"name" : @"Argentine", @"code": @"argentine" },
      @{@"name" : @"Armenian", @"code": @"armenian" },
      @{@"name" : @"Asian Fusion", @"code": @"asianfusion" },
      @{@"name" : @"Australian", @"code": @"australian" },
      @{@"name" : @"Austrian", @"code": @"austrian" },
      @{@"name" : @"Bangladeshi", @"code": @"bangladeshi" },
      @{@"name" : @"Barbeque", @"code": @"bbq" },
      @{@"name" : @"Basque", @"code": @"basque" },
      @{@"name" : @"Belgian", @"code": @"belgian" },
      @{@"name" : @"Brasseries", @"code": @"brasseries" },
      @{@"name" : @"Brazilian", @"code": @"brazilian" },
      @{@"name" : @"Breakfast & Brunch", @"code": @"breakfast_brunch" },
      @{@"name" : @"British", @"code": @"british" },
      @{@"name" : @"Buffets", @"code": @"buffets" },
      @{@"name" : @"Burgers", @"code": @"burgers" },
      @{@"name" : @"Burmese", @"code": @"burmese" },
      @{@"name" : @"Cafes", @"code": @"cafes" },
      @{@"name" : @"Cafeteria", @"code": @"cafeteria" },
      @{@"name" : @"Cajun/Creole", @"code": @"cajun" },
      @{@"name" : @"Cambodian", @"code": @"cambodian" },
      @{@"name" : @"Caribbean", @"code": @"caribbean" },
      @{@"name" : @"Dominican", @"code": @"dominican" },
      @{@"name" : @"Haitian", @"code": @"haitian" },
      @{@"name" : @"Puerto Rican", @"code": @"puertorican" },
      @{@"name" : @"Trinidadian", @"code": @"trinidadian" },
      @{@"name" : @"Catalan", @"code": @"catalan" },
      @{@"name" : @"Cheesesteaks", @"code": @"cheesesteaks" },
      @{@"name" : @"Chicken Shop", @"code": @"chickenshop" },
      @{@"name" : @"Chicken Wings", @"code": @"chicken_wings" },
      @{@"name" : @"Chinese", @"code": @"chinese" },
      @{@"name" : @"Cantonese", @"code": @"cantonese" },
      @{@"name" : @"Dim Sum", @"code": @"dimsum" },
      @{@"name" : @"Shanghainese", @"code": @"shanghainese" },
      @{@"name" : @"Szechuan", @"code": @"szechuan" },
      @{@"name" : @"Comfort Food", @"code": @"comfortfood" },
      @{@"name" : @"Corsican", @"code": @"corsican" },
      @{@"name" : @"Creperies", @"code": @"creperies" },
      @{@"name" : @"Cuban", @"code": @"cuban" },
      @{@"name" : @"Czech", @"code": @"czech" },
      @{@"name" : @"Delis", @"code": @"delis" },
      @{@"name" : @"Diners", @"code": @"diners" },
      @{@"name" : @"Fast Food", @"code": @"hotdogs" },
      @{@"name" : @"Filipino", @"code": @"filipino" },
      @{@"name" : @"Fish & Chips", @"code": @"fishnchips" },
      @{@"name" : @"Fondue", @"code": @"fondue" },
      @{@"name" : @"Food Court", @"code": @"food_court" },
      @{@"name" : @"Food Stands", @"code": @"foodstands" },
      @{@"name" : @"French", @"code": @"french" },
      @{@"name" : @"Gastropubs", @"code": @"gastropubs" },
      @{@"name" : @"German", @"code": @"german" },
      @{@"name" : @"Gluten-Free", @"code": @"gluten_free" },
      @{@"name" : @"Greek", @"code": @"greek" },
      @{@"name" : @"Halal", @"code": @"halal" },
      @{@"name" : @"Hawaiian", @"code": @"hawaiian" },
      @{@"name" : @"Himalayan/Nepalese", @"code": @"himalayan" },
      @{@"name" : @"Hong Kong Style Cafe", @"code": @"hkcafe" },
      @{@"name" : @"Hot Dogs", @"code": @"hotdog" },
      @{@"name" : @"Hot Pot", @"code": @"hotpot" },
      @{@"name" : @"Hungarian", @"code": @"hungarian" },
      @{@"name" : @"Iberian", @"code": @"iberian" },
      @{@"name" : @"Indian", @"code": @"indpak" },
      @{@"name" : @"Indonesian", @"code": @"indonesian" },
      @{@"name" : @"Irish", @"code": @"irish" },
      @{@"name" : @"Italian", @"code": @"italian" },
      @{@"name" : @"Japanese", @"code": @"japanese" },
      @{@"name" : @"Ramen", @"code": @"ramen" },
      @{@"name" : @"Teppanyaki", @"code": @"teppanyaki" },
      @{@"name" : @"Korean", @"code": @"korean" },
      @{@"name" : @"Kosher", @"code": @"kosher" },
      @{@"name" : @"Laotian", @"code": @"laotian" },
      @{@"name" : @"Latin American", @"code": @"latin" },
      @{@"name" : @"Colombian", @"code": @"colombian" },
      @{@"name" : @"Salvadorean", @"code": @"salvadorean" },
      @{@"name" : @"Venezuelan", @"code": @"venezuelan" },
      @{@"name" : @"Live/Raw Food", @"code": @"raw_food" },
      @{@"name" : @"Malaysian", @"code": @"malaysian" },
      @{@"name" : @"Mediterranean", @"code": @"mediterranean" },
      @{@"name" : @"Falafel", @"code": @"falafel" },
      @{@"name" : @"Mexican", @"code": @"mexican" },
      @{@"name" : @"Middle Eastern", @"code": @"mideastern" },
      @{@"name" : @"Egyptian", @"code": @"egyptian" },
      @{@"name" : @"Lebanese", @"code": @"lebanese" },
      @{@"name" : @"Modern European", @"code": @"modern_european" },
      @{@"name" : @"Mongolian", @"code": @"mongolian" },
      @{@"name" : @"Moroccan", @"code": @"moroccan" },
      @{@"name" : @"Pakistani", @"code": @"pakistani" },
      @{@"name" : @"Persian/Iranian", @"code": @"persian" },
      @{@"name" : @"Peruvian", @"code": @"peruvian" },
      @{@"name" : @"Pizza", @"code": @"pizza" },
      @{@"name" : @"Polish", @"code": @"polish" },
      @{@"name" : @"Portuguese", @"code": @"portuguese" },
      @{@"name" : @"Poutineries", @"code": @"poutineries" },
      @{@"name" : @"Russian", @"code": @"russian" },
      @{@"name" : @"Salad", @"code": @"salad" },
      @{@"name" : @"Sandwiches", @"code": @"sandwiches" },
      @{@"name" : @"Scandinavian", @"code": @"scandinavian" },
      @{@"name" : @"Scottish", @"code": @"scottish" },
      @{@"name" : @"Seafood", @"code": @"seafood" },
      @{@"name" : @"Senegalese", @"code": @"senegalese" },
      @{@"name" : @"Singaporean", @"code": @"singaporean" },
      @{@"name" : @"South African", @"code": @"southafrican" },
      @{@"name" : @"Slovakian", @"code": @"slovakian" },
      @{@"name" : @"Soul Food", @"code": @"soulfood" },
      @{@"name" : @"Soup", @"code": @"soup" },
      @{@"name" : @"Southern", @"code": @"southern" },
      @{@"name" : @"Spanish", @"code": @"spanish" },
      @{@"name" : @"Sri Lankan", @"code": @"srilankan" },
      @{@"name" : @"Steakhouses", @"code": @"steak" },
      @{@"name" : @"Sushi Bars", @"code": @"sushi" },
      @{@"name" : @"Taiwanese", @"code": @"taiwanese" },
      @{@"name" : @"Tapas Bars", @"code": @"tapas" },
      @{@"name" : @"Tapas/Small Plates", @"code": @"tapasmallplates" },
      @{@"name" : @"Tex-Mex", @"code": @"tex-mex" },
      @{@"name" : @"Thai", @"code": @"thai" },
      @{@"name" : @"Turkish", @"code": @"turkish" },
      @{@"name" : @"Ukrainian", @"code": @"ukrainian" },
      @{@"name" : @"Uzbek", @"code": @"uzbek" },
      @{@"name" : @"Vegan", @"code": @"vegan" },
      @{@"name" : @"Vegetarian", @"code": @"vegetarian" },
      @{@"name" : @"Vietnamese", @"code": @"vietnamese" }];
}


@end
