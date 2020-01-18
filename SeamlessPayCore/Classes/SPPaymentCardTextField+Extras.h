//
//  SPPaymentCardTextField+Extras.h
//


#import "SPPaymentCardTextField.h"


@class SPFormTextField;

@interface SPPaymentCardTextField (Extras)
@property (nonatomic, strong) NSArray<SPFormTextField *> *allFields;
- (void)commonInit;
@end
