//
//  SingleLineCardFormTest.m
//  SeamlessPayTests
//


#import <XCTest/XCTest.h>

#import "SingleLineCardForm.h"
#import "SPFormTextField.h"
#import "SingleLineCardForm.h"

@interface SingleLineCardFormTest : XCTestCase

@end

@implementation SingleLineCardFormTest

- (void)testIntrinsicContentSize {
  SingleLineCardForm *textField = [SingleLineCardForm new];

  UIFont *defaultFont = [UIFont systemFontOfSize:18];
  textField.font = defaultFont;
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 162, 0.1);

  UIFont *iOS8SystemFont = [UIFont fontWithName:@"HelveticaNeue" size:18];
  textField.font = iOS8SystemFont;
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 167, 0.1);

  UIFont *iOS9SystemFont = [UIFont systemFontOfSize:18];;
  textField.font = iOS9SystemFont;
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 44, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 162, 0.1);

  textField.font = [UIFont fontWithName:@"Avenir" size:44];
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.height, 62, 0.1);
  XCTAssertEqualWithAccuracy(textField.intrinsicContentSize.width, 304, 0.1);
}

@end
