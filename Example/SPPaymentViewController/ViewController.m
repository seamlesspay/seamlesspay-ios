//
//  ViewController.m
//  SPPaymentViewController
//
//  Created by Oleksiy Shortov on 3/12/20.
//  Copyright © 2020 info@seamlesspay.com. All rights reserved.
//

#import "ViewController.h"

@import SeamlessPayCore;

@interface ViewController ()

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
    
    
    
    
}

@end
