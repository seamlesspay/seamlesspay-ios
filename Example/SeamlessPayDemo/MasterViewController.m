/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property NSMutableArray *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  // self.navigationItem.leftBarButtonItem = self.editButtonItem;

  //    UIBarButtonItem *addButton = [[UIBarButtonItem alloc]
  //    initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self
  //    action:@selector(insertNewObject:)];
  //    self.navigationItem.rightBarButtonItem = addButton;

  self.detailViewController = (DetailViewController *)
      [[self.splitViewController.viewControllers lastObject] topViewController];

  self.objects = [[NSMutableArray alloc] init];
  [self.objects addObject:@"Authentication"];
  [self.objects addObject:@"Add Credit/Debit Card"];
  [self.objects addObject:@"Add Gift Card"];
  [self.objects addObject:@"Add ACH"];
  [self.objects addObject:@"Create Customer"];
  [self.objects addObject:@"Retrieve a Customer"];
  [self.objects addObject:@"Update Customer"];
  [self.objects addObject:@"Create a Charge"];
  [self.objects addObject:@"Retrieve a Charge"];
  [self.objects addObject:@"Virtual Terminal (CHARGE)"];
  [self.objects addObject:@"Virtual Terminal (ACH)"];
  [self.objects addObject:@"Virtual Terminal (GIFT CARD)"];
  [self.objects addObject:@"UI Payment Card Text Field"];
}

- (void)viewWillAppear:(BOOL)animated {
  self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
  [super viewWillAppear:animated];
}

//- (void)insertNewObject:(id)sender {
//    if (!self.objects) {
//        self.objects = [[NSMutableArray alloc] init];
//    }
//
//    [self.objects insertObject:[NSDate date] atIndex:0];
//
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
//    [self.tableView insertRowsAtIndexPaths:@[indexPath]
//    withRowAnimation:UITableViewRowAnimationAutomatic];
//}

#pragma mark - Segues

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([[segue identifier] isEqualToString:@"showDetail"]) {
    NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
    NSString *object = self.objects[indexPath.row];
    DetailViewController *controller =
        (DetailViewController *)[[segue destinationViewController]
            topViewController];
    controller.detailItem = object;
    controller.navigationItem.leftBarButtonItem =
        self.splitViewController.displayModeButtonItem;
    controller.navigationItem.leftItemsSupplementBackButton = YES;
    self.detailViewController = controller;
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section {
  return self.objects.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell =
      [tableView dequeueReusableCellWithIdentifier:@"Cell"
                                      forIndexPath:indexPath];

  NSDate *object = self.objects[indexPath.row];
  cell.textLabel.text = [object description];

  if ([object.description isEqualToString:@"UI Payment Card Text Field"]) {
    cell.textLabel.textColor = [UIColor blueColor];
  }

  return cell;
}

- (BOOL)tableView:(UITableView *)tableView
    canEditRowAtIndexPath:(NSIndexPath *)indexPath {
  // Return NO if you do not want the specified item to be editable.
  return YES;
}

- (void)tableView:(UITableView *)tableView
    commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
     forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (editingStyle == UITableViewCellEditingStyleDelete) {
    [self.objects removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:@[ indexPath ]
                     withRowAnimation:UITableViewRowAnimationFade];
  } else if (editingStyle == UITableViewCellEditingStyleInsert) {
    // Create a new instance of the appropriate class, insert it into the array,
    // and add a new row to the table view.
  }
}

@end
