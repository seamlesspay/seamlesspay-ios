//
//  SPPaymentCardTextField+Extras.h
//
//  Copyright (c) 2017-2020 Seamless Payments, Inc. All Rights Reserved
//

@class SPFormTextField;

@interface SPPaymentCardTextField (Extras)
@property (nonatomic, strong) NSArray<SPFormTextField *> *allFields;
- (void)commonInit;
@end
