/**
 * Copyright (c) Seamless Payments, Inc.
 *
 * This source code is licensed under the MIT license found in the
 * LICENSE file in the root directory of this source tree.
 */

#import "SPBINRange.h"
#import "NSString+Extras.h"

@interface SPBINRange ()

@property(nonatomic) NSUInteger length;
@property(nonatomic) NSString *qRangeLow;
@property(nonatomic) NSString *qRangeHigh;
@property(nonatomic) SPCardBrand brand;

- (BOOL)matchesNumber:(NSString *)number;

@end

@implementation SPBINRange

+ (NSArray<SPBINRange *> *)allRanges {

  static NSArray<SPBINRange *> *SPBINRangeAllRanges;

  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSArray *ranges = @[
      // Unknown
      @[ @"", @"", @16, @(SPCardBrandUnknown) ],

      // American Express
      @[ @"34", @"34", @15, @(SPCardBrandAmex) ],
      @[ @"37", @"37", @15, @(SPCardBrandAmex) ],

      // Diners Club
      @[ @"30", @"30", @14, @(SPCardBrandDinersClub) ],
      @[ @"36", @"36", @14, @(SPCardBrandDinersClub) ],
      @[ @"38", @"39", @14, @(SPCardBrandDinersClub) ],

      // Discover
      @[ @"60", @"60", @16, @(SPCardBrandDiscover) ],
      @[ @"64", @"65", @16, @(SPCardBrandDiscover) ],

      // JCB
      @[ @"35", @"35", @16, @(SPCardBrandJCB) ],

      // Mastercard
      @[ @"50", @"59", @16, @(SPCardBrandMasterCard) ],
      @[ @"22", @"27", @16, @(SPCardBrandMasterCard) ],
      @[ @"67", @"67", @16, @(SPCardBrandMasterCard) ], // Maestro

      // UnionPay
      @[ @"62", @"62", @16, @(SPCardBrandUnionPay) ],

      // Visa
      @[ @"40", @"49", @16, @(SPCardBrandVisa) ],
      @[ @"413600", @"413600", @13, @(SPCardBrandVisa) ],
      @[ @"444509", @"444509", @13, @(SPCardBrandVisa) ],
      @[ @"444509", @"444509", @13, @(SPCardBrandVisa) ],
      @[ @"444550", @"444550", @13, @(SPCardBrandVisa) ],
      @[ @"450603", @"450603", @13, @(SPCardBrandVisa) ],
      @[ @"450617", @"450617", @13, @(SPCardBrandVisa) ],
      @[ @"450628", @"450629", @13, @(SPCardBrandVisa) ],
      @[ @"450636", @"450636", @13, @(SPCardBrandVisa) ],
      @[ @"450640", @"450641", @13, @(SPCardBrandVisa) ],
      @[ @"450662", @"450662", @13, @(SPCardBrandVisa) ],
      @[ @"463100", @"463100", @13, @(SPCardBrandVisa) ],
      @[ @"476142", @"476142", @13, @(SPCardBrandVisa) ],
      @[ @"476143", @"476143", @13, @(SPCardBrandVisa) ],
      @[ @"492901", @"492902", @13, @(SPCardBrandVisa) ],
      @[ @"492920", @"492920", @13, @(SPCardBrandVisa) ],
      @[ @"492923", @"492923", @13, @(SPCardBrandVisa) ],
      @[ @"492928", @"492930", @13, @(SPCardBrandVisa) ],
      @[ @"492937", @"492937", @13, @(SPCardBrandVisa) ],
      @[ @"492939", @"492939", @13, @(SPCardBrandVisa) ],
      @[ @"492960", @"492960", @13, @(SPCardBrandVisa) ],
    ];
    NSMutableArray *binRanges = [NSMutableArray array];
    for (NSArray *range in ranges) {
      SPBINRange *binRange = [self.class new];
      binRange.qRangeLow = range[0];
      binRange.qRangeHigh = range[1];
      binRange.length = [range[2] unsignedIntegerValue];
      binRange.brand = [range[3] integerValue];
      [binRanges addObject:binRange];
    }
    SPBINRangeAllRanges = [binRanges copy];
  });
  return SPBINRangeAllRanges;
}

/**
 Number matching strategy: Truncate the longer of the two numbers (theirs and
 our bounds) to match the length of the shorter one, then do numerical compare.
 */
- (BOOL)matchesNumber:(NSString *)number {

  BOOL withinLowRange = NO;
  BOOL withinHighRange = NO;

  if (number.length < self.qRangeLow.length) {
    withinLowRange =
        number.integerValue >=
        [self.qRangeLow substringToIndex:number.length].integerValue;
  } else {
    withinLowRange =
        [number substringToIndex:self.qRangeLow.length].integerValue >=
        self.qRangeLow.integerValue;
  }

  if (number.length < self.qRangeHigh.length) {
    withinHighRange =
        number.integerValue <=
        [self.qRangeHigh substringToIndex:number.length].integerValue;
  } else {
    withinHighRange =
        [number substringToIndex:self.qRangeHigh.length].integerValue <=
        self.qRangeHigh.integerValue;
  }

  return withinLowRange && withinHighRange;
}

- (NSComparisonResult)compare:(SPBINRange *)other {
  return [@(self.qRangeLow.length) compare:@(other.qRangeLow.length)];
}

+ (NSArray<SPBINRange *> *)binRangesForNumber:(NSString *)number {
  return [[self allRanges]
      filteredArrayUsingPredicate:[NSPredicate
                                      predicateWithBlock:^BOOL(
                                          SPBINRange *range,
                                          __unused NSDictionary *bindings) {
                                        return [range matchesNumber:number];
                                      }]];
}

+ (instancetype)mostSpecificBINRangeForNumber:(NSString *)number {
  NSArray *validRanges = [[self allRanges]
      filteredArrayUsingPredicate:[NSPredicate
                                      predicateWithBlock:^BOOL(
                                          SPBINRange *range,
                                          __unused NSDictionary *bindings) {
                                        return [range matchesNumber:number];
                                      }]];
  return
      [[validRanges sortedArrayUsingSelector:@selector(compare:)] lastObject];
}

+ (NSArray<SPBINRange *> *)binRangesForBrand:(SPCardBrand)brand {
  return [[self allRanges]
      filteredArrayUsingPredicate:[NSPredicate
                                      predicateWithBlock:^BOOL(
                                          SPBINRange *range,
                                          __unused NSDictionary *bindings) {
                                        return range.brand == brand;
                                      }]];
}

@end
