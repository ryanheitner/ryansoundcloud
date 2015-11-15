//
//  SCCollectionViewController.m
//  SoundCloud
//
//  Created by Ryan Heitner on 14/11/2015.
//  Copyright © 2015 Ryan Heitner. All rights reserved.
//

#import "SCCollectionViewController.h"
#import <CoreData/CoreData.h>
#import "AppDelegate.h"
#import "GridCell.h"
#import "ListCell.h"
#import "BaseCell.h"
#import "SCAPI.h"
#import "UIView+Toast.h"
#import "SCConfig.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "DetailViewController.h"

// Params (not used now)
#define kLimit      @"limit"
#define kOffset     @"offset"
#define kTrack      @"tracks"
#define kLicence    @"license='cc-by-sa'"

typedef void (^ADVCollectionViewUpdateBlock)();  // use this for updates in core data



@interface SCCollectionViewController () <UISearchResultsUpdating,UISearchControllerDelegate,NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableSet               *updates;
// use for search
@property (nonatomic, strong) UISearchController         *searchController;
@property (nonatomic, strong) NSArray                    *filteredList;


// use for either list of grid layout
@property (nonatomic        ) BOOL                       isGrid;

@end

@implementation SCCollectionViewController
// use for either list of grid layout

static NSString * const gridCellReuseIdentifier = @"GridCell";
static NSString * const listCellReuseIdentifier = @"ListCell";

float margin = 0;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // use grid by default (stored in defaults plist / can be overwritten to using defaults if we give the user that option)
    _isGrid = [[NSUserDefaults standardUserDefaults] boolForKey:kUseGrid];
    
    [self mySearchController];
    self.navigationItem.titleView        = self.searchController.searchBar;
    self.navigationItem.titleView.hidden = YES ;// initialy hide the search active with button;
    
    [self setFlowLayout];

    [self initializeFetchedResultsController];
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    
#warning TODO: rhe01
// move to its own class I have left this here for this project but it should be in its own class
    // this is in the config file
    NSString *soundCloudAppID = [SCConfig valueForKey:kKeySoundCloudAppID];
    NSString *resourcePath    = [NSString stringWithFormat:@"https://api.soundcloud.com/tracks?client_id=%@",soundCloudAppID];
    NSURL *resourceURL        = [NSURL URLWithString:resourcePath];
    SCRequest *scRrequest     = [[SCRequest alloc] initWithMethod:SCRequestMethodGET resource:resourceURL];
    
    [scRrequest performRequestWithSendingProgressHandler:^(unsigned long long bytesSend, unsigned long long bytesTotal) {
        DDLogDebug(@"progress %llu:%llu",bytesSend,bytesTotal);
    } responseHandler:^(NSURLResponse *response, NSData *responseData, NSError *error) {
        if (error)
        {
            NSString *message = [NSString stringWithFormat:@"Error:%@",error];
            [self.view makeToast:message];
            return ;
        }
        DDLogDebug(@"response %@",response);
        [Tracks parseTracks:responseData]; // this will create a callback to nsfetched results controller delegates
        
    }];
    

}



#pragma mark <UICollectionViewDataSource>
#pragma mark Collection View Data Source Methods
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if ([self useFilteredResults])
    {
        return 1;
    }
    else
    {
        return [[self.fetchedResultsController sections] count]; // will always be one in this project
    }
}



- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    
    // if we are using the search it uses the filtered list
    if ([[self.fetchedResultsController sections] count] == 0) {
        return 0;
    }
    
    
    if ([self useFilteredResults])
    {
        return [self.filteredList count];
    }
    else
    {
        id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
        return [sectionInfo numberOfObjects];
    }
}




- (id )getItemAtIndexPath:(NSIndexPath *)indexPath {
    
    Tracks *tracks  ;
    if ([self useFilteredResults])
    {
        tracks = [self.filteredList objectAtIndex:indexPath.row];
    }
    else
    {
        tracks = [self.fetchedResultsController objectAtIndexPath:indexPath];
    }
    return tracks;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    BaseCell *cell;
    if (_isGrid) {
         cell = (GridCell *)[collectionView dequeueReusableCellWithReuseIdentifier:gridCellReuseIdentifier forIndexPath:indexPath];
    } else {
         cell = (ListCell *)[collectionView dequeueReusableCellWithReuseIdentifier:listCellReuseIdentifier forIndexPath:indexPath];
    }
    // cell4
    // Configure the cell
   
    CGFloat hue = ( arc4random() % 256 / 256.0 );  //  0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5;  //  0.5 to 1.0, away from black
    UIColor *color = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
    cell.backgroundColor = color;
//    
    Tracks *tracks =(Tracks *)[self getItemAtIndexPath:indexPath];
//

    cell.labelTitle.text = tracks.title;
    
    // will download the artwork to a cache for fast access
    NSURL *artWorkURL = [NSURL URLWithString:tracks.artwork_url];
    [cell.myImageView sd_setImageWithURL:artWorkURL
                      placeholderImage:[UIImage imageNamed:@"icon_music_solid"]
                               options:(indexPath.row == 0 ? SDWebImageRefreshCached : 0)
                             completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                                 if (error == nil && image.size.height > 0) {

                                 } else {
                                
                                     DDLogWarn(@"image %@",error);
                                 }
                             }];
    
    
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // cell5
    Tracks *tracks =(Tracks *)[self getItemAtIndexPath:indexPath];
    _selectedTrack = tracks;
    [self performSegueWithIdentifier:kSegueDetail sender:self];

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // we pass the track to the track player
    if ([segue.identifier isEqualToString:kSegueDetail]) {
        DetailViewController *detailViewController = (DetailViewController *)[segue destinationViewController];
        detailViewController.tracks = _selectedTrack;
    }
    
}


- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // we change thie size for the grisd or list
    // size4
    float width = self.view.frame.size.width;
    
    int numberOfCells ;
    if (_isGrid) {
        numberOfCells = 3;
        float maxCellWidth = (width - (numberOfCells )) / numberOfCells;
        return CGSizeMake(maxCellWidth, maxCellWidth * 1.5);
    } else {
        numberOfCells = 1;
        float maxCellWidth = (width - (numberOfCells )) / numberOfCells;
        return CGSizeMake(maxCellWidth, maxCellWidth / 6);
    }
    

}
#pragma mark flowlayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    
    if (self.fetchedResultsController.sections.count) {
        return CGSizeMake(self.view.frame.size.width, 30.0f);
        
    }
    return CGSizeMake(0, 0);
}

- (void)setFlowLayout {
    
    // set the flowlayout to use minimum spaces
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    float width = self.view.frame.size.width;
    float maxCellWidth = (width - (3 * margin)) / 3;
    
    [flowLayout setItemSize:CGSizeMake(maxCellWidth, maxCellWidth)];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    [flowLayout setSectionInset:UIEdgeInsetsMake(0, 0, 0, 0)];   // { CGFloat top, left , bottom, right ; }
    [flowLayout setMinimumLineSpacing:margin];
    [flowLayout setMinimumInteritemSpacing:0];
    
    [self.collectionView setCollectionViewLayout:flowLayout];
}

#pragma mark buttons pushed


- (IBAction)pushedButtonGrid:(id)sender {
    if (!_isGrid) {
        _isGrid = YES;
        [self.collectionView reloadData];
    }
}

- (IBAction)pushedButtonList:(id)sender {
    if (_isGrid) {
        _isGrid = NO;
        [self.collectionView reloadData];
    }
}


#pragma mark -
#pragma mark search

#pragma mark -
- (void)mySearchController {
    _searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater                 = self;
    self.searchController.dimsBackgroundDuringPresentation     = NO;
    self.searchController.hidesNavigationBarDuringPresentation = NO;
    [self.searchController.searchBar sizeToFit];
    self.searchController.delegate                             = self;
    self.searchController.searchBar.searchBarStyle             = UISearchBarStyleProminent;
    self.searchController.searchBar.placeholder                = @"Search" ;
}

- (BOOL)useFilteredResults{
    if (!self.searchController.active) {
        return NO;
    }
    
    NSString *searchText = _searchController.searchBar.text;
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (strippedString.length == 0) {
        return NO;
    }
    return YES;
}

- (void)didPresentSearchController:(UISearchController *)searchController {
    searchController.searchBar.showsCancelButton = NO;
    
}
- (IBAction)pushedButtonSearch:(id)sender {
    [self.navigationItem.titleView setHidden:!self.navigationItem.titleView.isHidden ];
    [self.searchController setActive:!self.searchController.isActive];
    
    [self.collectionView reloadData];
}


#pragma mark UISearchControllerDelegate

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController {
    // update the filtered array based on the search text
    NSString *searchText = searchController.searchBar.text;
    // strip out all the leading and trailing spaces
    NSString *strippedString = [searchText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    
    // break up the search terms (separated by spaces)
    NSArray *searchItems = nil;
    if (strippedString.length > 0) {
        searchItems = [strippedString componentsSeparatedByString:@" "];
    } else {
        return;
    }
    
    // build all the "AND" expressions for each value in the searchString
    //
    NSMutableArray *andMatchPredicates = [NSMutableArray array];
    NSMutableArray *searchItemsPredicate = [NSMutableArray array];
    
    for (NSString *searchString in searchItems) {
        NSPredicate *finalPredicate = [self predicateForKeyPath:@"title" searchString:searchString];
        [searchItemsPredicate addObject:finalPredicate];
    }
    
    // at this OR predicate to our master AND predicate
    NSCompoundPredicate *orMatchPredicates = [NSCompoundPredicate orPredicateWithSubpredicates:searchItemsPredicate];
    [andMatchPredicates addObject:orMatchPredicates];
    
    NSMutableArray *searchResults = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    searchResults = [[searchResults filteredArrayUsingPredicate:orMatchPredicates] mutableCopy];
    
    // hand over the filtered results to our search results table
    self.filteredList = searchResults;
    [self.collectionView reloadData];
}

- (NSPredicate *)predicateForKeyPath:(NSString *)keyPath searchString:(NSString *)searchString{
    NSExpression *lhs = [NSExpression expressionForKeyPath:keyPath];
    NSExpression *rhs = [NSExpression expressionForConstantValue:searchString];
    NSPredicate *finalPredicate = [NSComparisonPredicate
                                   predicateWithLeftExpression:lhs
                                   rightExpression:rhs
                                   modifier:NSDirectPredicateModifier
                                   type:NSContainsPredicateOperatorType
                                   options:NSCaseInsensitivePredicateOption];
    return finalPredicate;
}

#pragma mark Fetched Results Controller #pragma mark -
- (void)initializeFetchedResultsController
{
    [NSFetchedResultsController deleteCacheWithName:nil];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tracks"];
    
    NSSortDescriptor *titleSort = [NSSortDescriptor sortDescriptorWithKey:kSC_title ascending:YES];
    
    [request setSortDescriptors:@[titleSort]];
    
    AppDelegate *appdelegate =  (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = appdelegate.managedObjectContext; //Retrieve the main queue NSManagedObjectContext
    
    [self setFetchedResultsController:[[NSFetchedResultsController alloc] initWithFetchRequest:request managedObjectContext:moc sectionNameKeyPath:nil cacheName:nil]];
    [[self fetchedResultsController] setDelegate:self];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"Failed to initialize FetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    DDLogDebug(@"found %d object",self.fetchedResultsController.fetchedObjects.count);
}

#pragma mark Fetched Results Controller Delegate Methods NSFetchedResultsControllerDelegate
- (void) controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    DDLogDebug(@"");
    self.updates = [NSMutableSet new];
    
}

- (void) controller:(NSFetchedResultsController *)control
   didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
            atIndex:(NSUInteger)sectionIndex
      forChangeType:(NSFetchedResultsChangeType)type
{
    
    ADVCollectionViewUpdateBlock update;
    __weak UICollectionView *collectionView = self.collectionView;
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
    
    DDLogDebug(@"updatesIndexes added:%d",sectionIndex);
    
    switch (type)
    {
        case NSFetchedResultsChangeInsert: {
            update = ^{
                [collectionView insertSections:sections];
            };
            break;
        }
        case NSFetchedResultsChangeDelete: {
            update = ^{
                [collectionView deleteSections:sections];
            };
            break;
        }
        case NSFetchedResultsChangeMove:
        case NSFetchedResultsChangeUpdate:
            // Nothing to do here
            return;
            //		case NSFetchedResultsChangeUpdate: {
            //			update = ^{
            //				[collectionView reloadSections:sections];
            //			};
            //			break;
    }
    [self.updates addObject:update];
    
}

- (void) controller:(NSFetchedResultsController *)controller
    didChangeObject:(id)anObject
        atIndexPath:(NSIndexPath *)indexPath
      forChangeType:(NSFetchedResultsChangeType)type
       newIndexPath:(NSIndexPath *)newIndexPath
{
    DDLogVerbose(@"%@",anObject);
    
    
    ADVCollectionViewUpdateBlock update;
    __weak UICollectionView *collectionView = self.collectionView;
    switch (type)
    {
        case NSFetchedResultsChangeInsert: { // 1
            
            update = ^{
                [collectionView insertItemsAtIndexPaths:@[newIndexPath]];
            };
            break;
        }
        case NSFetchedResultsChangeDelete: { // 2
            update = ^{
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            };
            break;
        }
        case NSFetchedResultsChangeUpdate: { // 4
            //			update = ^{
            // 				[collectionView reloadItemsAtIndexPaths:@[indexPath]];
            //			};
            return;
            break;
            
        }
        case NSFetchedResultsChangeMove: { // 3
            update = ^{
                [collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            };
            break;
            break;
            
        }
        default:
            DDLogError(@"invalid NSFetchedResultsChangeType %d",(int)type);
            return;
    }
    [self.updates addObject:update];
}

- (void) controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    
    if (self.updates.count == 0) {
        return;
    }
    [self.collectionView performBatchUpdates:^{
        for (ADVCollectionViewUpdateBlock update in self.updates) {
            update();
        }
    } completion:^(BOOL finished) {
        self.updates = nil;
        [self.collectionView.collectionViewLayout invalidateLayout];
    }];
}

@end
