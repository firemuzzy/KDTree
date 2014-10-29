//
//  KDTreeTests.m
//  HearNear
//
//  Created by Michael Charkin on 10/9/13.
//  Copyright (c) 2013 HeatNear. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "KDTreeO2.h"

@interface KDTreeTests : XCTestCase

@end

@interface TestTuple : NSObject

@property (nonatomic, strong, readonly) NSString *value;
@property (nonatomic, assign, readonly) BOOL flag;
@property (nonatomic, assign, readonly) double lat;
@property (nonatomic, assign, readonly) double lng;


@end

@implementation TestTuple

@synthesize value = _value;
@synthesize flag = _flag;
@synthesize lat = _lat;
@synthesize lng = _lng;

-(TestTuple *)initWithValue:(NSString *)v andFlag:(BOOL)flag atLat:(double)lat andLng:(double)lng {
    if(self = [super init]) {
        _value = v;
        _flag = flag;
        _lat = lat;
        _lng = lng;
    }
    return self;
}

- (NSString *)description {
    NSString *str = [NSString stringWithFormat:@"v:%@ flag:%@ (%.6f,%.6f)", self.value, (self.flag) ? @"YES" : @"NO", self.lat, self.lng];
    return str;
}

@end


@interface KDTreeTests ()

@property (nonatomic, strong) KDTreeO2* kdTree;

@end

@implementation KDTreeTests

@synthesize kdTree = _kdTree;

- (void)setUp
{
    [super setUp];
    
    self.kdTree = [[KDTreeO2 alloc] initForKDimensions:3];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    [self.kdTree clear];
    
    [super tearDown];
}

//- (void)testDuplicateCoordinateInserts
//{
//    NSString *n1 = @"Point1";
//    NSString *n2 = @"Point1 duplicateCoordinate";
//    
//    TestTuple *t1 = [[TestTuple alloc] initWithValue:n1 andFlag:NO atLat:37.7943 andLng:-122.4011];
//    TestTuple *t2 = [[TestTuple alloc] initWithValue:n2 andFlag:NO atLat:37.7943 andLng:-122.4011];
//    
//    [self.kdTree insertObject:t1.value atLat:t1.lat Lng:t1.lng];
//    [self.kdTree insertObject:t2.value atLat:t2.lat Lng:t2.lng];
//    
//    TestTuple *t1Test = [self.kdTree nearestObjectToLat:t1.lat Lng:t1.lng];
//    TestTuple *t2Test = [self.kdTree nearestObjectToLat:t2.lat Lng:t2.lng];
//    
//    NSArray *points = [self.kdTree nearestObjectsToLat:t2.lat Lng:t2.lng];
//    STAssertEquals(points.count, 2u, @"expected 2 points");
//    STAssertTrue([points containsObject:t1.value], @"should points n1");
//    STAssertTrue([points containsObject:t2.value], @"should points n2");
//    
//    STAssertEqualObjects(t1.value, t1Test, @"not equal");
//    STAssertEqualObjects(t2.value, t2Test, @"not equal");
//}

- (void)testNearestSingleObjectWithInclusionFilter
{
    NSString *n1 = @"Federal Reserve Bank of San Francisco";
    NSString *n2 = @"First San Francisco Mint";
    NSString *n3 = @"Mills Building";
    NSString *n4 = @"V. C. Morris Gift Shop";
    NSString *n5 = @"Cable Car Museum";
    NSString *n6 = @"Ferry Building";
    
    TestTuple *t1 = [[TestTuple alloc] initWithValue:n1 andFlag:YES atLat:37.7943 andLng:-122.4011];
    TestTuple *t2 = [[TestTuple alloc] initWithValue:n2 andFlag:NO atLat:37.79443597993225 andLng:-122.40334063768387];
    TestTuple *t3 = [[TestTuple alloc] initWithValue:n3 andFlag:NO atLat:37.79127 andLng:-122.40129];
    TestTuple *t4 = [[TestTuple alloc] initWithValue:n4 andFlag:YES atLat:37.788265 andLng:-122.405945];
    TestTuple *t5 = [[TestTuple alloc] initWithValue:n5 andFlag:YES atLat:37.794809 andLng:-122.411798];
    TestTuple *t6 = [[TestTuple alloc] initWithValue:n6 andFlag:YES atLat:37.795356 andLng:-122.393791];
    
    [self.kdTree insertObject:t1 atLat:t1.lat Lng:t1.lng];
    [self.kdTree insertObject:t2 atLat:t2.lat Lng:t2.lng];
    [self.kdTree insertObject:t3 atLat:t3.lat Lng:t3.lng];
    [self.kdTree insertObject:t4 atLat:t4.lat Lng:t4.lng];
    [self.kdTree insertObject:t5 atLat:t5.lat Lng:t5.lng];
    [self.kdTree insertObject:t6 atLat:t6.lat Lng:t6.lng];
    
    TestTuple *t1Test = [self.kdTree nearestObjectToLat:t1.lat Lng:t1.lng];
    TestTuple *t2Test = [self.kdTree nearestObjectToLat:t2.lat Lng:t2.lng];
    TestTuple *t3Test = [self.kdTree nearestObjectToLat:t3.lat Lng:t3.lng];
    TestTuple *t4Test = [self.kdTree nearestObjectToLat:t4.lat Lng:t4.lng];
    TestTuple *t5Test = [self.kdTree nearestObjectToLat:t5.lat Lng:t5.lng];
    TestTuple *t6Test = [self.kdTree nearestObjectToLat:t6.lat Lng:t6.lng];
    
    XCTAssertEqualObjects(t1, t1Test, @"not equal");
    XCTAssertEqualObjects(t2, t2Test, @"not equal");
    XCTAssertEqualObjects(t3, t3Test, @"not equal");
    XCTAssertEqualObjects(t4, t4Test, @"not equal");
    XCTAssertEqualObjects(t5, t5Test, @"not equal");
    XCTAssertEqualObjects(t6, t6Test, @"not equal");
    
    
    TestTuple *nearMintYesFlag = [self.kdTree nearestObjectToLat:t2.lat Lng:t2.lng withInclusionFilter:^BOOL(id obj) {
        TestTuple *t = (TestTuple *)obj;
        return t.flag;
    }];
    XCTAssertEqualObjects(nearMintYesFlag, t1, @"not equal");
    TestTuple *nearMintNoFlag = [self.kdTree nearestObjectToLat:t2.lat Lng:t2.lng withInclusionFilter:^BOOL(id obj) {
        TestTuple *t = (TestTuple *)obj;
        return !t.flag;
    }];
    XCTAssertEqualObjects(nearMintNoFlag, t2, @"not equal");
}

//- (void)testObjectAt
//{
//    NSString *n1 = @"Federal Reserve Bank of San Francisco";
//    NSString *n2 = @"First San Francisco Mint";
//    NSString *n3 = @"Mills Building";
//    NSString *n4 = @"V. C. Morris Gift Shop";
//    NSString *n5 = @"Cable Car Museum";
//    NSString *n6 = @"Ferry Building";
//    
//    TestTuple *t1 = [[TestTuple alloc] initWithValue:n1 andFlag:YES atLat:37.7943 andLng:-122.4011];
//    TestTuple *t2 = [[TestTuple alloc] initWithValue:n2 andFlag:NO atLat:37.79443597993225 andLng:-122.40334063768387];
//    TestTuple *t3 = [[TestTuple alloc] initWithValue:n3 andFlag:NO atLat:37.79127 andLng:-122.40129];
//    TestTuple *t4 = [[TestTuple alloc] initWithValue:n4 andFlag:YES atLat:37.788265 andLng:-122.405945];
//    TestTuple *t5 = [[TestTuple alloc] initWithValue:n5 andFlag:YES atLat:37.794809 andLng:-122.411798];
//    TestTuple *t6 = [[TestTuple alloc] initWithValue:n6 andFlag:YES atLat:37.795356 andLng:-122.393791];
//    
//    [self.kdTree insertObject:t1 atLat:t1.lat Lng:t1.lng];
//    [self.kdTree insertObject:t2 atLat:t2.lat Lng:t2.lng];
//    [self.kdTree insertObject:t3 atLat:t3.lat Lng:t3.lng];
//    [self.kdTree insertObject:t4 atLat:t4.lat Lng:t4.lng];
//    [self.kdTree insertObject:t5 atLat:t5.lat Lng:t5.lng];
//    [self.kdTree insertObject:t6 atLat:t6.lat Lng:t6.lng];
//    
//    TestTuple *t1Test = [self.kdTree objectAtLat:t1.lat Lng:t1.lng];
//    TestTuple *t2Test = [self.kdTree objectAtLat:t2.lat Lng:t2.lng];
//    TestTuple *t3Test = [self.kdTree objectAtLat:t3.lat Lng:t3.lng];
//    TestTuple *t4Test = [self.kdTree objectAtLat:t4.lat Lng:t4.lng];
//    TestTuple *t5Test = [self.kdTree objectAtLat:t5.lat Lng:t5.lng];
//    TestTuple *t6Test = [self.kdTree objectAtLat:t6.lat Lng:t6.lng];
//    TestTuple *tNone = [self.kdTree objectAtLat:0.0 Lng:21.0];
//
//    
//    XCTAssertEqualObjects(t1, t1Test, @"not equal");
//    XCTAssertEqualObjects(t2, t2Test, @"not equal");
//    XCTAssertEqualObjects(t3, t3Test, @"not equal");
//    XCTAssertEqualObjects(t4, t4Test, @"not equal");
//    XCTAssertEqualObjects(t5, t5Test, @"not equal");
//    XCTAssertEqualObjects(t6, t6Test, @"not equal");
//    XCTAssertNil(tNone, @"not nil");
//
//}
//
//- (void)testNearestObjectsWithInclusionFilter
//{
//    NSString *n1 = @"Federal Reserve Bank of San Francisco";
//    NSString *n2 = @"First San Francisco Mint";
//    NSString *n3 = @"Mills Building";
//    NSString *n4 = @"V. C. Morris Gift Shop";
//    NSString *n5 = @"Cable Car Museum";
//    NSString *n6 = @"Ferry Building";
//    
//    TestTuple *t1 = [[TestTuple alloc] initWithValue:n1 andFlag:YES atLat:37.7943 andLng:-122.4011];
//    TestTuple *t2 = [[TestTuple alloc] initWithValue:n2 andFlag:NO atLat:37.79443597993225 andLng:-122.40334063768387];
//    TestTuple *t3 = [[TestTuple alloc] initWithValue:n3 andFlag:NO atLat:37.79127 andLng:-122.40129];
//    TestTuple *t4 = [[TestTuple alloc] initWithValue:n4 andFlag:YES atLat:37.788265 andLng:-122.405945];
//    TestTuple *t5 = [[TestTuple alloc] initWithValue:n5 andFlag:YES atLat:37.794809 andLng:-122.411798];
//    TestTuple *t6 = [[TestTuple alloc] initWithValue:n6 andFlag:YES atLat:37.795356 andLng:-122.393791];
//    
//    [self.kdTree insertObject:t1 atLat:t1.lat Lng:t1.lng];
//    [self.kdTree insertObject:t2 atLat:t2.lat Lng:t2.lng];
//    [self.kdTree insertObject:t3 atLat:t3.lat Lng:t3.lng];
//    [self.kdTree insertObject:t4 atLat:t4.lat Lng:t4.lng];
//    [self.kdTree insertObject:t5 atLat:t5.lat Lng:t5.lng];
//    [self.kdTree insertObject:t6 atLat:t6.lat Lng:t6.lng];
//    
//    TestTuple *t1Test = [self.kdTree nearestObjectToLat:t1.lat Lng:t1.lng];
//    TestTuple *t2Test = [self.kdTree nearestObjectToLat:t2.lat Lng:t2.lng];
//    TestTuple *t3Test = [self.kdTree nearestObjectToLat:t3.lat Lng:t3.lng];
//    TestTuple *t4Test = [self.kdTree nearestObjectToLat:t4.lat Lng:t4.lng];
//    TestTuple *t5Test = [self.kdTree nearestObjectToLat:t5.lat Lng:t5.lng];
//    TestTuple *t6Test = [self.kdTree nearestObjectToLat:t6.lat Lng:t6.lng];
//    
//    XCTAssertEqualObjects(t1, t1Test, @"not equal");
//    XCTAssertEqualObjects(t2, t2Test, @"not equal");
//    XCTAssertEqualObjects(t3, t3Test, @"not equal");
//    XCTAssertEqualObjects(t4, t4Test, @"not equal");
//    XCTAssertEqualObjects(t5, t5Test, @"not equal");
//    XCTAssertEqualObjects(t6, t6Test, @"not equal");
//    
//    
//    NSArray *nearFilteredYesFlag = [self.kdTree nearestObjectsToLat:37.793609 Lng:-122.401306 withinKilometers:4 withInclusionFilter:^BOOL(id obj) {
//        TestTuple *t = (TestTuple *)obj;
//        return t.flag;
//    }];
//    for(TestTuple *t in nearFilteredYesFlag) {
//        NSLog(@"Near filtered: %@", t.description);
//    }
//    XCTAssertTrue(nearFilteredYesFlag.count == 4, @"count of filtered points near the downtown is %ld", nearFilteredYesFlag.count);
//    XCTAssertTrue([nearFilteredYesFlag containsObject:t1], @"does not contain test tuple");
//    XCTAssertTrue([nearFilteredYesFlag containsObject:t4], @"does not contain test tuple");
//    XCTAssertTrue([nearFilteredYesFlag containsObject:t5], @"does not contain test tuple");
//    XCTAssertTrue([nearFilteredYesFlag containsObject:t6], @"does not contain test tuple");
//    
//    
//    NSArray *nearFilteredNoFlag = [self.kdTree nearestObjectsToLat:37.793609 Lng:-122.401306 withinKilometers:4 withInclusionFilter:^BOOL(id obj) {
//        TestTuple *t = (TestTuple *)obj;
//        return !t.flag;
//    }];
//    XCTAssertTrue(nearFilteredNoFlag.count == 2, @"count of filtered points near the downtown is %ld", nearFilteredYesFlag.count);
//    XCTAssertTrue([nearFilteredNoFlag containsObject:t2], @"does not contain test tuple");
//    XCTAssertTrue([nearFilteredNoFlag containsObject:t3], @"does not contain test tuple");
//}
//
//- (void)testExample
//{
//    NSString *p1 = @"Federal Reserve Bank of San Francisco";
//    NSString *p2 = @"First San Francisco Mint";
//    NSString *p3 = @"Mills Building";
//    NSString *p4 = @"V. C. Morris Gift Shop";
//    NSString *p5 = @"Cable Car Museum";
//    NSString *p6 = @"Ferry Building";
//    NSString *p7 = @"Ferry Building";
//    
//    [self.kdTree insertObject:p1 atLat:37.7943 Lng:-122.4011];
//    [self.kdTree insertObject:p2 atLat:37.79443597993225 Lng:-122.40334063768387];
//    [self.kdTree insertObject:p3 atLat:37.79127 Lng:-122.40129];
//    [self.kdTree insertObject:p4 atLat:37.788265 Lng:-122.405945];
//    [self.kdTree insertObject:p5 atLat:37.794809 Lng:-122.411798];
//    [self.kdTree insertObject:p6 atLat:37.795356 Lng:-122.393791];
//    [self.kdTree insertObject:p7 atLat:37.795356 Lng:-122.393791];
//    
//    NSString *p1ByHash = [self.kdTree getWithHashOfObject:p1];
//    NSString *p1ByHashString = [self.kdTree getWithHashOfObject:@"Federal Reserve Bank of San Francisco"];
//    XCTAssertEqualObjects(p1, p1ByHash, @"not equal");
//    XCTAssertEqualObjects(p1, p1ByHashString, @"not equal");
//    
//    NSString *p1Test = [self.kdTree nearestObjectToLat:37.7943 Lng:-122.4011];
//    NSString *p2Test = [self.kdTree nearestObjectToLat:37.79443597993225 Lng:-122.40334063768387];
//    NSString *p3Test = [self.kdTree nearestObjectToLat:37.79127 Lng:-122.40129];
//    NSString *p4Test = [self.kdTree nearestObjectToLat:37.788265 Lng:-122.405945];
//    NSString *p5Test = [self.kdTree nearestObjectToLat:37.794809 Lng:-122.411798];
//    NSString *p6Test = [self.kdTree nearestObjectToLat:37.795356 Lng:-122.393791];
//    
//    XCTAssertEqualObjects(p1, p1Test, @"not equal");
//    XCTAssertEqualObjects(p2, p2Test, @"not equal");
//    XCTAssertEqualObjects(p3, p3Test, @"not equal");
//    XCTAssertEqualObjects(p4, p4Test, @"not equal");
//    XCTAssertEqualObjects(p5, p5Test, @"not equal");
//    XCTAssertEqualObjects(p6, p6Test, @"not equal");
//    
//    NSString *closeToP1 = [self.kdTree nearestObjectToLat:37.794023 Lng:-122.401362];
//    NSString *closeToP2 = [self.kdTree nearestObjectToLat:37.794673 Lng:-122.403172];
//    NSString *closeToP3 = [self.kdTree nearestObjectToLat:37.790913 Lng:-122.402397];
//    NSString *closeToP4 = [self.kdTree nearestObjectToLat:37.787793 Lng:-122.405165];
//    NSString *closeToP5 = [self.kdTree nearestObjectToLat:37.794508 Lng:-122.411452];
//    NSString *closeToP6 = [self.kdTree nearestObjectToLat:37.79383 Lng:-122.395552];
//    
//    XCTAssertEqualObjects(p1, closeToP1, @"not equal");
//    XCTAssertEqualObjects(p2, closeToP2, @"not equal");
//    XCTAssertEqualObjects(p3, closeToP3, @"not equal");
//    XCTAssertEqualObjects(p4, closeToP4, @"not equal");
//    XCTAssertEqualObjects(p5, closeToP5, @"not equal");
//    XCTAssertEqualObjects(p6, closeToP6, @"not equal");
//    
//    NSArray *nearFerryBuilding = [self.kdTree nearestObjectsToLat:37.79539 Lng:-122.394715 withinKilometers:0.2];
//    XCTAssertTrue(nearFerryBuilding.count == 1, @"count of points near the ferry building is %ld", nearFerryBuilding.count);
//    XCTAssertEqualObjects([nearFerryBuilding objectAtIndex:0], p6, @"not equal");
//    
//    NSArray *farFromFerryBuilding = [self.kdTree nearestObjectsToLat:37.795322 Lng:-122.390746 withinKilometers:0.2];
//    XCTAssertTrue(farFromFerryBuilding.count == 0, @"cound of points around far from ferry building");
//    
//    NSArray *with5km = [self.kdTree nearestObjectsToLat:37.793609 Lng:-122.401306 withinKilometers:4];
//    XCTAssertTrue(with5km.count == 6, @"cound of points around 5 km of down town");
//}

@end
