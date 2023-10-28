//
//  SPPaymentCardTextFieldTest.m
//  SeamlessPayCoreTests
//


#import <XCTest/XCTest.h>

#import "../../SeamlessPayCoreObjC/include/SPPaymentCardTextField.h"
#import "../../SeamlessPayCoreObjC/include/SPFormTextField.h"
#import "../../SeamlessPayCoreObjC/include/SPPaymentCardTextFieldViewModel.h"


@interface SPPaymentCardTextField (Testing)
@property (nonatomic, readwrite, weak) UIImageView *brandImageView;
@property (nonatomic, readwrite, weak) SPFormTextField *numberField;
@property (nonatomic, readwrite, weak) SPFormTextField *expirationField;
@property (nonatomic, readwrite, weak) SPFormTextField *cvcField;
@property (nonatomic, readwrite, weak) SPFormTextField *postalCodeField;
@property (nonatomic, readonly, weak) SPFormTextField *currentFirstResponderField;
@property (nonatomic, readwrite, strong) SPPaymentCardTextFieldViewModel *viewModel;
@property (nonatomic, copy) NSNumber *focusedTextFieldForLayout;
+ (UIImage *)cvcImageForCardBrand:(SPCardBrand)cardBrand;
+ (UIImage *)brandImageForCardBrand:(SPCardBrand)cardBrand;
@end

/**
 Class that implements SPPaymentCardTextFieldDelegate and uses a block for each delegate method.
 */
@interface PaymentCardTextFieldBlockDelegate: NSObject <SPPaymentCardTextFieldDelegate>
@property (nonatomic, strong, nullable) void (^didChange)(SPPaymentCardTextField *);
@property (nonatomic, strong, nullable) void (^willEndEditingForReturn)(SPPaymentCardTextField *);
@property (nonatomic, strong, nullable) void (^didEndEditing)(SPPaymentCardTextField *);
// add more properties for other delegate methods as this test needs them
@end
@implementation PaymentCardTextFieldBlockDelegate
- (void)paymentCardTextFieldDidChange:(SPPaymentCardTextField *)textField {
  if (self.didChange) {
    self.didChange(textField);
  }
}
- (void)paymentCardTextFieldWillEndEditingForReturn:(SPPaymentCardTextField *)textField {
  if (self.willEndEditingForReturn) {
    self.willEndEditingForReturn(textField);
  }
}
- (void)paymentCardTextFieldDidEndEditing:(SPPaymentCardTextField *)textField {
  if (self.didEndEditing) {
    self.didEndEditing(textField);
  }
}
@end



@interface SPPaymentCardTextFieldTest : XCTestCase

@end

@implementation SPPaymentCardTextFieldTest

- (void)testIntrinsicContentSize {
  SPPaymentCardTextField *textField = [SPPaymentCardTextField new];

  UIFont *iOS8SystemFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
  textField.font = iOS8SystemFont;
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 135, 0.1);

  UIFont *iOS9SystemFont = [UIFont systemFontOfSize:18];;
  textField.font = iOS9SystemFont;
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 130, 0.1);

  textField.font = [UIFont fontWithName:@"Avenir" size:44];
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 62, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 272, 0.1);
}

- (void)testSetCard_numberUnknown {
  SPPaymentCardTextField *sut = [SPPaymentCardTextField new];
  NSString *number = @"1";
  sut.numberField.text = number;
  XCTAssertEqualObjects(sut.numberField.text, number);
  XCTAssertEqual(sut.expirationField.text.length, (NSUInteger)0);
  XCTAssertEqual(sut.cvcField.text.length, (NSUInteger)0);
  XCTAssertNil(sut.currentFirstResponderField);
}

- (void)testSettingTextUpdatesViewModelText {
  SPPaymentCardTextField *sut = [SPPaymentCardTextField new];
  sut.numberField.text = @"4242424242424242";
  XCTAssertEqualObjects(sut.viewModel.cardNumber, sut.numberField.text);

  sut.cvcField.text = @"123";
  XCTAssertEqualObjects(sut.viewModel.cvc, sut.cvcField.text);

  sut.expirationField.text = @"10/99";
  XCTAssertEqualObjects(sut.viewModel.rawExpiration, sut.expirationField.text);
  XCTAssertEqualObjects(sut.viewModel.expirationMonth, @"10");
  XCTAssertEqualObjects(sut.viewModel.expirationYear, @"99");
}

@end
