//
//  ViewController.m
//  SPPaymentViewController
//


#import "ViewController.h"

@import SeamlessPayCore;

#import "SPPaymentViewController.h"

@interface ViewController () <SPPaymentViewControllerDelegate>
@property(nonatomic, weak) SPPaymentViewController *paymentViewController;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.layer.cornerRadius = 5;
    button.backgroundColor = [UIColor blackColor];
    button.titleLabel.font = [UIFont systemFontOfSize:22];
    [button setTitle:@" SPPaymentViewController " forState:UIControlStateNormal];
    [button addTarget:self
               action:@selector(show)
     forControlEvents:UIControlEventTouchUpInside];
    [button sizeToFit];
    button.center = self.view.center;
    
    [self.view addSubview:button];
    
}

- (void) show {
    
    SPPaymentViewController *pk = [[SPPaymentViewController alloc] initWithNibName:nil bundle:nil];
    pk.paymentDescription = @"Order payment description";
    pk.logoImage = [UIImage imageNamed:@"Icon-72.png"];
    pk.paymentAmount = @"10.2";
    pk.delegate = self;
    self.paymentViewController = pk;
    [self presentViewController:self.paymentViewController animated:YES completion:nil];
}


- (void)paymentViewController:(SPPaymentViewController*)paymentViewController chargeSuccess:(SPCharge*)charge {
    NSString *success = [NSString
        stringWithFormat:@"Amount: $%@\nStatus: %@\nStatus message: "
                         @"%@\ntxnID #: %@",
                         charge.amount, charge.status,
                         charge.statusDescription, charge.chargeId];

    [self displayAlertWithTitle:@"Success"
                        message:success];
}
- (void)paymentViewController:(SPPaymentViewController*)paymentViewController paymentMethodError:(SPError*)error {
    [self displayAlertWithTitle:@"Error" message:error.errorMessage];
}
- (void)paymentViewController:(SPPaymentViewController*)paymentViewController chargeError:(SPError*)error {
    [self displayAlertWithTitle:@"Error" message:error.errorMessage];
}

- (void)displayAlertWithTitle:(NSString *)title
                      message:(NSString *)message
                      {
  dispatch_async(dispatch_get_main_queue(), ^{
    UIAlertController *alert = [UIAlertController
        alertControllerWithTitle:title
                         message:message
                  preferredStyle:UIAlertControllerStyleAlert];
      
      [alert addAction:[UIAlertAction actionWithTitle:@"OK"
        style:UIAlertActionStyleCancel
      handler:nil]];
    [self.paymentViewController presentViewController:alert animated:YES completion:nil];
  });
}

@end
