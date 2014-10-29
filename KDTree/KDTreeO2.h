//
//  KDTreeO2.h
//  KDTree
//
//  Created by Michael Charkin on 9/4/13.
//  Copyright (c) 2013 HeatNear. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface KDTreeO2 : NSObject

- (instancetype)initForKDimensions:(int)dimension;
- (instancetype)initWithMaxCapacity:(NSUInteger)capacity andShrinkFactor:(double)shrkinFactor;

- (void)insertObject:(id)object atLat:(double)lat Lng:(double)lng;
- (void)insertObject:(id)object atLat:(double)lat Lng:(double)lng fromLocation:(CLLocation *)myLoc;
- (void)insertObject:(id)object atLat:(double)lat Lng:(double)lng duplicateCheck:(BOOL)dupCheck;
- (void)insertObject:(id)object atLat:(double)lat Lng:(double)lng fromLocation:(CLLocation *)myLoc duplicateCheck:(BOOL)dupCheck;

- (id) objectAtLat:(double)lat Lng:(double)lng;
- (id) objectForHash:(NSUInteger)hash;

- (id) nearestObjectToLat:(double)lat Lng:(double)lng;
- (id) nearestObjectToLat:(double)lat Lng:(double)lng withInclusionFilter:(BOOL (^)(id))inclusionFilter;
- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng;

- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng within:(double)radianDistance;
- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng withinKilometers:(double)km;
- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng withinKilometers:(double)km withInclusionFilter:(BOOL (^)(id))inclusionFilter;

- (NSArray *)allValues;

- (void) clear;

- (id)getWithHashOfObject:(id)object;

- (BOOL)isEmpty;

@end
