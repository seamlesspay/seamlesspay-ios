/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "MasterViewController.h"
#import "DetailViewController.h"
#import "SeamlessPayDemo-Swift.h"

@interface MasterViewController ()

@property NSArray *objects;
@end

@implementation MasterViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  self.objects = @[
    @"Authentication",
    @"Add Credit/Debit Card",
    @"Add Gift Card",
    @"Add ACH",
    @"Create Customer",
    @"Retrieve a Customer",
    @"Update Customer",
    @"Create a Charge",
    @"Retrieve a Charge",
    @"Virtual Terminal (CHARGE)",
    @"Virtual Terminal (ACH)",
    @"Virtual Terminal (GIFT CARD)",
    @"UI Payment Card Text Field",
    @"Verification",
  ];
}

- (void)viewWillAppear:(BOOL)animated {
  self.clearsSelectionOnViewWillAppear = self.splitViewController.isCollapsed;
  [super viewWillAppear:animated];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [self showDetailViewControllerForRow:indexPath.row];
}

// MARK: Private
- (void)showDetailViewControllerForRow:(NSInteger)row {
  if (self.objects.count > row) {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NSString *object = self.objects[row];

    UIViewController *viewController;
    if ([object isEqualToString:@"Verification"]) {
      viewController = [SwiftUIViewHostingControllerFactory verificationViewHostingController];
    } else {
      DetailViewController *detailViewController = (DetailViewController *)[storyboard instantiateViewControllerWithIdentifier:@"DetailViewControllerStoryboardIdentifier"];
      detailViewController.detailItem = object;
      viewController = detailViewController;
    }
    [self addDetailViewController:viewController];
  }
}

- (void)addDetailViewController:(UIViewController *)viewController {
  if (viewController) {
    UIUserInterfaceIdiom userInterfaceIdiom = [UIDevice currentDevice].userInterfaceIdiom;
    if (userInterfaceIdiom == UIUserInterfaceIdiomPhone) {
      // Running on iPhone, push the view controller onto the navigation stack
      UINavigationController *navigationController = self.navigationController;
      if (navigationController) {
        [navigationController pushViewController:viewController animated:YES];
      }
    } else if (userInterfaceIdiom == UIUserInterfaceIdiomPad) {
      // Running on iPad, add the view controller as the second view controller of a split view controller
      UISplitViewController *splitViewController = (UISplitViewController *)self.splitViewController;
      if (splitViewController) {
        UIViewController *masterViewController = [splitViewController.viewControllers firstObject];
        NSArray *viewControllers = @[masterViewController, viewController];
        splitViewController.viewControllers = viewControllers;
      }
    }
  } else {
    NSLog(@"Failed to instantiate view controller from storyboard.");
  }
}

@end
