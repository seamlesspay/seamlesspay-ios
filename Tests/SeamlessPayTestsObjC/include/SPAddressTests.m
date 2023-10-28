//
//  SPAddressTests.m
//  SeamlessPayCoreTests
//

#import <XCTest/XCTest.h>
#import <PassKit/PassKit.h>
#import <Contacts/Contacts.h>

#import "../../SeamlessPayCore/Classes/SPAddress.h"

@interface SPAddressTests : XCTestCase

@end

@implementation SPAddressTests

- (void)testInitWithPKContact_complete {
  PKContact *contact = [PKContact new];
  {
    NSPersonNameComponents *name = [NSPersonNameComponents new];
    name.givenName = @"John";
    name.familyName = @"Doe";
    contact.name = name;

    contact.emailAddress = @"foo@example.com";
    contact.phoneNumber = [CNPhoneNumber phoneNumberWithStringValue:@"888-555-1212"];

    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.street = @"55 John St";
    address.city = @"New York";
    address.state = @"NY";
    address.postalCode = @"10002";
    address.ISOCountryCode = @"US";
    address.country = @"United States";
    contact.postalAddress = address.copy;
  }

  SPAddress *address = [[SPAddress alloc] initWithPKContact:contact];
  XCTAssertEqualObjects(@"John Doe", address.name);
  XCTAssertEqualObjects(@"8885551212", address.phone);
  XCTAssertEqualObjects(@"foo@example.com", address.email);
  XCTAssertEqualObjects(@"55 John St", address.line1);
  XCTAssertEqualObjects(@"New York", address.city);
  XCTAssertEqualObjects(@"NY", address.state);
  XCTAssertEqualObjects(@"10002", address.postalCode);
  XCTAssertEqualObjects(@"US", address.country);
}

- (void)testInitWithPKContact_partial {
  PKContact *contact = [PKContact new];
  {
    NSPersonNameComponents *name = [NSPersonNameComponents new];
    name.givenName = @"John";
    contact.name = name;

    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.state = @"VA";
    contact.postalAddress = address.copy;
  }

  SPAddress *address = [[SPAddress alloc] initWithPKContact:contact];
  XCTAssertEqualObjects(@"John", address.name);
  XCTAssertNil(address.phone);
  XCTAssertNil(address.email);
  XCTAssertNil(address.line1);
  XCTAssertNil(address.city);
  XCTAssertEqualObjects(@"VA", address.state);
  XCTAssertNil(address.postalCode);
  XCTAssertNil(address.country);
}

- (void)testInitWithCNContact_complete {
  if ([CNContact class] == nil) {
    // Method not supported by iOS version
    return;
  }

  CNMutableContact *contact = [CNMutableContact new];
  {
    contact.givenName = @"John";
    contact.familyName = @"Doe";

    contact.emailAddresses = @[
      [CNLabeledValue labeledValueWithLabel:CNLabelHome
                                      value:@"foo@example.com"],
      [CNLabeledValue labeledValueWithLabel:CNLabelWork
                                      value:@"bar@example.com"],


    ];

    contact.phoneNumbers = @[
      [CNLabeledValue labeledValueWithLabel:CNLabelHome
                                      value:[CNPhoneNumber phoneNumberWithStringValue:@"888-555-1212"]],
      [CNLabeledValue labeledValueWithLabel:CNLabelWork
                                      value:[CNPhoneNumber phoneNumberWithStringValue:@"555-555-5555"]],


    ];

    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.street = @"55 John St";
    address.city = @"New York";
    address.state = @"NY";
    address.postalCode = @"10002";
    address.ISOCountryCode = @"US";
    address.country = @"United States";
    contact.postalAddresses = @[
      [CNLabeledValue labeledValueWithLabel:CNLabelHome
                                      value:address],
    ];
  }

  SPAddress *address = [[SPAddress alloc] initWithCNContact:contact];
  XCTAssertEqualObjects(@"John Doe", address.name);
  XCTAssertEqualObjects(@"8885551212", address.phone);
  XCTAssertEqualObjects(@"foo@example.com", address.email);
  XCTAssertEqualObjects(@"55 John St", address.line1);
  XCTAssertEqualObjects(@"New York", address.city);
  XCTAssertEqualObjects(@"NY", address.state);
  XCTAssertEqualObjects(@"10002", address.postalCode);
  XCTAssertEqualObjects(@"US", address.country);
}

- (void)testInitWithCNContact_partial {
  if ([CNContact class] == nil) {
    // Method not supported by iOS version
    return;
  }

  CNMutableContact *contact = [CNMutableContact new];
  {
    contact.givenName = @"John";

    CNMutablePostalAddress *address = [CNMutablePostalAddress new];
    address.state = @"VA";
    contact.postalAddresses = @[
      [CNLabeledValue labeledValueWithLabel:CNLabelHome
                                      value:address],
    ];
  }

  SPAddress *address = [[SPAddress alloc] initWithCNContact:contact];
  XCTAssertEqualObjects(@"John", address.name);
  XCTAssertNil(address.phone);
  XCTAssertNil(address.email);
  XCTAssertNil(address.line1);
  XCTAssertNil(address.city);
  XCTAssertEqualObjects(@"VA", address.state);
  XCTAssertNil(address.postalCode);
  XCTAssertNil(address.country);
}

- (void)testPKContactValue {
  SPAddress *address = [SPAddress new];
  address.name = @"John Smith Doe";
  address.phone = @"8885551212";
  address.email = @"foo@example.com";
  address.line1 = @"55 John St";
  address.city = @"New York";
  address.state = @"NY";
  address.postalCode = @"10002";
  address.country = @"US";

  PKContact *contact = [address PKContactValue];
  XCTAssertEqualObjects(contact.name.givenName, @"John");
  XCTAssertEqualObjects(contact.name.familyName, @"Smith Doe");
  XCTAssertEqualObjects(contact.phoneNumber.stringValue, @"8885551212");
  XCTAssertEqualObjects(contact.emailAddress, @"foo@example.com");
  CNPostalAddress *postalAddress = contact.postalAddress;
  XCTAssertEqualObjects(postalAddress.street, @"55 John St");
  XCTAssertEqualObjects(postalAddress.city, @"New York");
  XCTAssertEqualObjects(postalAddress.state, @"NY");
  XCTAssertEqualObjects(postalAddress.postalCode, @"10002");
  XCTAssertEqualObjects(postalAddress.country, @"US");
}

- (void)testContainsRequiredFieldsNone {
  SPAddress *address = [SPAddress new];
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsNone]);
  address.line1 = @"55 John St";
  address.city = @"New York";
  address.state = @"NY";
  address.postalCode = @"10002";
  address.country = @"US";
  address.phone = @"8885551212";
  address.email = @"foo@example.com";
  address.name = @"John Doe";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsNone]);
  address.country = @"UK";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsNone]);
}


- (void)testContainsRequiredFieldsFull {
  SPAddress *address = [SPAddress new];

  /**
   Required fields for full are:
   line1, city, country, state (US only) and a valid postal code (based on country)
   */

  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.country = @"US";
  address.line1 = @"55 John St";

  // Fail on partial
  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsFull]);

  address.city = @"New York";

  // For US fail if missing state or zip
  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.state = @"NY";
  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.postalCode = @"ABCDE";
  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsFull]);
  //postal must be numeric for US
  address.postalCode = @"10002";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.phone = @"8885551212";
  address.email = @"foo@example.com";
  address.name = @"John Doe";
  // Name/phone/email should have no effect
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);

  // Non US countries don't require state
  address.country = @"UK";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.state = nil;
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
  // alphanumeric postal ok in some countries
  address.postalCode = @"ABCDE";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
  // UK requires ZIP
  address.postalCode = nil;
  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsFull]);


  address.country = @"IE"; // Doesn't require postal or state, but allows them
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.postalCode = @"ABCDE";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
  address.state = @"Test";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsFull]);
}

- (void)testContainsRequiredFieldsName {
  SPAddress *address = [SPAddress new];

  XCTAssertFalse([address containsRequiredFields:SPBillingAddressFieldsName]);
  address.name = @"Jane Doe";
  XCTAssertTrue([address containsRequiredFields:SPBillingAddressFieldsName]);
}

- (void)testContainsContentForBillingAddressFields {
  SPAddress *address = [SPAddress new];

  // Empty address should return false for everything
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsNone]);
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsFull]);
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsName]);

  // 1+ characters in postalCode will return true for .PostalCode && .Full
  address.postalCode = @"0";
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsNone]);
  XCTAssertTrue([address containsContentForBillingAddressFields:SPBillingAddressFieldsFull]);
  // empty string returns false
  address.postalCode = @"";
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsNone]);
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsFull]);
  address.postalCode = nil;

  // 1+ characters in name will return true for .Name
  address.name = @"Jane Doe";
  XCTAssertTrue([address containsContentForBillingAddressFields:SPBillingAddressFieldsName]);
  // empty string returns false
  address.name = @"";
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsName]);
  address.name = nil;

  // Test every other property that contributes to the full address, ensuring it returns True for .Full only
  // This is *not* refactoring-safe, but I think it's better than a bunch of duplicated code
  for (NSString *propertyName in @[@"line1", @"line2", @"city", @"state", @"country"]) {
    for (NSString *testValue in @[@"a", @"0", @"Foo Bar"]) {
      [address setValue:testValue forKey:propertyName];
      XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsNone]);
      XCTAssertTrue([address containsContentForBillingAddressFields:SPBillingAddressFieldsFull]);
      XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsName]);
      [address setValue:nil forKey:propertyName];
    }

    // Make sure that empty string is treated like nil, and returns false for these properties
    [address setValue:@"" forKey:propertyName];
    XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsNone]);
    XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsFull]);
    XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsName]);
    [address setValue:nil forKey:propertyName];
  }

  // ensure it still returns false for everything since it has been cleared
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsNone]);
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsFull]);
  XCTAssertFalse([address containsContentForBillingAddressFields:SPBillingAddressFieldsName]);
}

- (void)testContainsRequiredShippingAddressFields {
  SPAddress *address = [SPAddress new];
  XCTAssertTrue([address containsRequiredShippingAddressFields:nil]);
  NSSet<SPContactField> *allFields = [NSSet setWithArray:@[SPContactFieldPostalAddress,
                                                           SPContactFieldEmailAddress,
                                                           SPContactFieldPhoneNumber,
                                                           SPContactFieldName]];
  XCTAssertFalse([address containsRequiredShippingAddressFields:allFields]);

  address.name = @"John Smith";
  XCTAssertTrue(([address containsRequiredShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertFalse(([address containsRequiredShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));

  address.email = @"john@example.com";
  XCTAssertTrue(([address containsRequiredShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName, SPContactFieldEmailAddress]]]));
  XCTAssertFalse(([address containsRequiredShippingAddressFields:allFields]));

  address.phone = @"5555555555";
  XCTAssertTrue(([address containsRequiredShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName, SPContactFieldEmailAddress, SPContactFieldPhoneNumber]]]));
  XCTAssertFalse(([address containsRequiredShippingAddressFields:allFields]));
  address.country = @"GB";
  XCTAssertTrue(([address containsRequiredShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName, SPContactFieldEmailAddress, SPContactFieldPhoneNumber]]]));

  address.country = @"US";
  address.phone = @"5555555555";
  address.line1 = @"55 John St";
  address.city = @"New York";
  address.state = @"NY";
  address.postalCode = @"12345";
  XCTAssertTrue([address containsRequiredShippingAddressFields:allFields]);
}

- (void)testContainsContentForShippingAddressFields {
  SPAddress *address = [SPAddress new];

  // Empty address should return false for everything
  XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));

  // Name
  address.name = @"Smith";
  XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));
  address.name = @"";

  // Phone
  address.phone = @"1";
  XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));
  address.phone = @"";

  // Email
  address.email = @"f";
  XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));
  address.email = @"";

  // Test every property that contributes to the full address
  // This is *not* refactoring-safe, but I think it's better than a bunch more duplicated code
  for (NSString *propertyName in @[@"line1", @"line2", @"city", @"state", @"postalCode", @"country"]) {
    for (NSString *testValue in @[@"a", @"0", @"Foo Bar"]) {
      [address setValue:testValue forKey:propertyName];
      XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
      XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
      XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
      XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
      XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));
      [address setValue:@"" forKey:propertyName];
    }
  }

  // ensure it still returns false for everything with empty strings
  XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));

  // Try a hybrid address, and make sure some bitwise combinations work
  address.name = @"a";
  address.phone = @"1";
  address.line1 = @"_";
  XCTAssertFalse(([address containsContentForShippingAddressFields:nil]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName]]]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber]]]));
  XCTAssertFalse(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldEmailAddress]]]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress]]]));

  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldName, SPContactFieldEmailAddress]]]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPhoneNumber, SPContactFieldEmailAddress]]]));
  XCTAssertTrue(([address containsContentForShippingAddressFields:[NSSet setWithArray:@[SPContactFieldPostalAddress,
                                                                                        SPContactFieldEmailAddress,
                                                                                        SPContactFieldPhoneNumber,
                                                                                        SPContactFieldName]]]));

}

#pragma mark STPFormEncodable Tests

- (void)testRootObjectName {
  XCTAssertNil([SPAddress rootObjectName]);
}

- (void)testPropertyNamesToFormFieldNamesMapping {
  SPAddress *address = [SPAddress new];

  NSDictionary *mapping = [SPAddress propertyNamesToFormFieldNamesMapping];

  for (NSString *propertyName in [mapping allKeys]) {
    XCTAssertFalse([propertyName containsString:@":"]);
    XCTAssert([address respondsToSelector:NSSelectorFromString(propertyName)]);
  }

  for (NSString *formFieldName in [mapping allValues]) {
    XCTAssert([formFieldName isKindOfClass:[NSString class]]);
    XCTAssert([formFieldName length] > 0);
  }

  XCTAssertEqual([[mapping allValues] count], [[NSSet setWithArray:[mapping allValues]] count]);
}

@end
