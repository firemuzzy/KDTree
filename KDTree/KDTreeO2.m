//
//  KDTreeO2.m
//  KDTree
//
//  Created by Michael Charkin on 9/4/13.
//  Copyright (c) 2013 HeatNear. All rights reserved.
//

#import "KDTreeO2.h"
#import "kdtree.h"

@interface LocWrapper : NSObject

@property (nonatomic, strong, readonly) id obj;
@property (nonatomic, strong, readonly) CLLocation *loc;

+(instancetype) withObj:(id)obj atLat:(double)lat andLng:(double)lng;

@end

@implementation LocWrapper

+(instancetype) withObj:(id)obj atLat:(double)lat andLng:(double)lng {
    return [[LocWrapper alloc] initWithObj:obj atLat:lat andLng:lng];
}

-(instancetype) initWithObj:(id)obj atLat:(double)lat andLng:(double)lng {
    if(self = [super init]) {
        CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(lat, lng);
        NSParameterAssert(CLLocationCoordinate2DIsValid(coord));
        
        _obj = obj;
        _loc = [[CLLocation alloc] initWithLatitude:lat longitude:lng];
    }
    return self;
}

- (NSString *)description {
    NSString *str = [NSString stringWithFormat:@"<LocWrapper obj:%@ loc:%@>", self.obj, self.loc.description];
    return str;
}

@end


@interface KDTreeO2 ()

@property (nonatomic, strong) NSMutableDictionary *itemsDict;

@property (nonatomic, assign) NSUInteger maxCapacity;
@property (nonatomic, assign) double shrinkFactor;

@end

@implementation KDTreeO2 {
    struct kdtree *tree;
}

-(NSMutableDictionary *)itemsDict {
    if(_itemsDict) return _itemsDict;
    
    _itemsDict = [[NSMutableDictionary alloc] init];
    return _itemsDict;
}

- (instancetype)init {
    return [self initForKDimensions:2];
}

- (instancetype) initWithMaxCapacity:(NSUInteger)capacity andShrinkFactor:(double)shrkinFactor {
    NSParameterAssert(capacity > 0);
    NSParameterAssert(shrkinFactor > 0);
    
    if(self = [self init]) {
        _maxCapacity = capacity;
        _shrinkFactor = shrkinFactor;
    }
    return self;
}

- (void)_shrinkTreeRelativeToLocation:(CLLocation *)location {
    NSParameterAssert(location && CLLocationCoordinate2DIsValid(location.coordinate));
    
    if(self.maxCapacity > 0 && (self.itemsDict.count > self.maxCapacity * self.shrinkFactor)) {
        NSMutableArray *closestWrappedValues = [[NSMutableArray alloc] initWithCapacity:self.maxCapacity];
        
        NSArray *sorted = [[self.itemsDict allValues] sortedArrayUsingComparator:^NSComparisonResult(LocWrapper *w1, LocWrapper *w2) {
            CLLocationDistance locToW1 = [location distanceFromLocation:w1.loc];
            CLLocationDistance locToW2 = [location distanceFromLocation:w2.loc];

            return locToW1 - locToW2;
        }];
        
        [sorted enumerateObjectsUsingBlock:^(LocWrapper *w, NSUInteger idx, BOOL *stop) {
            if(idx >= self.maxCapacity) {
                *stop = YES;
            } else {
                [closestWrappedValues addObject:w];
            }
        }];
        
        kd_clear(tree);
        [_itemsDict removeAllObjects];
        
        [closestWrappedValues enumerateObjectsUsingBlock:^(LocWrapper *w, NSUInteger idx, BOOL *stop) {
            CLLocationCoordinate2D coord = w.loc.coordinate;
            double latE6d = ((double)((int)(coord.latitude * 10E6))) / 10E6 ;
            double lngE6d = ((double)((int)(coord.longitude * 10E6))) / 10E6 ;
            
            NSLog(@"Copying over: %@", [w.obj description]);
            
            [self.itemsDict setObject:w forKey:[NSNumber numberWithUnsignedInteger:[w hash]]];
            kd_insert2(tree, latE6d, lngE6d, (__bridge void *)w.obj);
        }];
    }
}

- (KDTreeO2 *)initForKDimensions:(int)dimensions {
    if(self = [super init]) {
        tree = kd_create(dimensions);
    }
    return self;
}

- (id)getWithHashOfObject:(id)object {
    @synchronized(self) {
        LocWrapper *result;
        result = [self.itemsDict objectForKey:[NSNumber numberWithUnsignedInteger:[object hash]]];
        return result.obj;
    }
}

- (void) insertObject:(id)object atLat:(double)lat Lng:(double)lng {
    return [self insertObject:object atLat:lat Lng:lng duplicateCheck:YES];
}
- (void) insertObject:(id)object atLat:(double)lat Lng:(double)lng duplicateCheck:(BOOL)dupCheck {
    return [self insertObject:object atLat:lat Lng:lng fromLocation:nil duplicateCheck:dupCheck];
}

- (void) insertObject:(id)object atLat:(double)lat Lng:(double)lng fromLocation:(CLLocation *)myLoc {
    return [self insertObject:object atLat:lat Lng:lng fromLocation:myLoc duplicateCheck:YES];
}
- (void)insertObject:(id)object atLat:(double)lat Lng:(double)lng fromLocation:(CLLocation *)myLoc duplicateCheck:(BOOL)dupCheck {
    NSParameterAssert(myLoc != nil || self.maxCapacity <= 0); // myLoc con only be obbited if the tree is not set up to auto shrink
    
    @synchronized(self) {
        if(myLoc) [self _shrinkTreeRelativeToLocation:myLoc];
        
        if(dupCheck) {
            id existingValue = [self.itemsDict objectForKey:[NSNumber numberWithUnsignedInteger:[object hash]]];
            if(existingValue) {
                return;
            }
        }
        
        double latE6d = ((double)((int)(lat * 10E6))) / 10E6 ;
        double lngE6d = ((double)((int)(lng * 10E6))) / 10E6 ;
        
        LocWrapper *wrapped = [LocWrapper withObj:object atLat:latE6d andLng:lngE6d];
        [self.itemsDict setObject:wrapped forKey:[NSNumber numberWithUnsignedInteger:[object hash]]];
        kd_insert2(tree, latE6d, lngE6d, (__bridge void *)object);
    }
    
}

- (id)objectForHash:(NSUInteger)hash {
    LocWrapper *wrapped = [self.itemsDict objectForKey:[NSNumber numberWithUnsignedInteger:hash]];
    return wrapped.obj;
}

- (id) objectAtLat:(double)lat Lng:(double)lng {
    @synchronized(self) {
        id nearest = nil;
        double latE6d = ((double)((int)(lat * 10E6))) / 10E6 ;
        double lngE6d = ((double)((int)(lng * 10E6))) / 10E6 ;
        
        struct kdres *nearestKDRes = kd_nearest_range2(tree, latE6d, lngE6d, 0);
        
        if(nearestKDRes && kd_res_size(nearestKDRes) > 0) {
            nearest = (__bridge id)kd_res_item(nearestKDRes, NULL);
        }
        
        if(nearestKDRes) {
            kd_res_free(nearestKDRes);
        }
        return nearest;
    }
}

- (id) nearestObjectToLat:(double)lat Lng:(double)lng {
    return [self nearestObjectToLat:lat Lng:lng withInclusionFilter:nil];
}

- (id) nearestObjectToLat:(double)lat Lng:(double)lng withInclusionFilter:(BOOL (^)(id))inclusionFilter {
    @synchronized(self) {
        struct kdres *nearestKDRes;
        if(inclusionFilter) {
            nearestKDRes = kd_nearest2_w_filter(tree, lat, lng, ^char(const void *obj) {
                return inclusionFilter((__bridge id)obj);
            });
        } else {
            nearestKDRes = kd_nearest2(tree, lat, lng);
        }
        
        id nearest = nil;
        if(nearestKDRes && kd_res_size(nearestKDRes) > 0) {
            nearest = (__bridge id)kd_res_item(nearestKDRes, NULL);
        }
        
        if(nearestKDRes) {
            kd_res_free(nearestKDRes);
        }

        return nearest;
    }
}

- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng {
    @synchronized(self) {
        struct kdres *nearestKDRes;
        nearestKDRes = kd_nearest2(tree, lat, lng);
        
        int count = nearestKDRes != NULL ? kd_res_size(nearestKDRes) : 0;
        NSMutableArray *nearestArr = [[NSMutableArray alloc] initWithCapacity:count];
        
        while(nearestKDRes && !kd_res_end(nearestKDRes)) {
            id nearest = (__bridge id)kd_res_item_data(nearestKDRes);
            [nearestArr addObject:nearest];
            
            kd_res_next(nearestKDRes);
        }
        
        if(nearestKDRes) kd_res_free(nearestKDRes);
        return nearestArr;
    }
}

- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng within:(double)radianDistance {
    @synchronized(self) {
        struct kdres *nearestKDRes;
        nearestKDRes = kd_nearest_range2(tree, lat, lng, radianDistance);
        
        int count = nearestKDRes != NULL ? kd_res_size(nearestKDRes) : 0;
        NSMutableArray *nearestArr = [[NSMutableArray alloc] initWithCapacity:count];
        
        while(nearestKDRes && !kd_res_end(nearestKDRes)) {
            id nearest = (__bridge id)kd_res_item_data(nearestKDRes);
            [nearestArr addObject:nearest];
            
            kd_res_next(nearestKDRes);
        }
        
        if(nearestKDRes) kd_res_free(nearestKDRes);
        
        return nearestArr;
    }
}

- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng withinKilometers:(double)km {
    return [self nearestObjectsToLat:lat Lng:lng withinKilometers:km withInclusionFilter:nil];
}

- (NSArray *) nearestObjectsToLat:(double)lat Lng:(double)lng withinKilometers:(double)km withInclusionFilter:(BOOL (^)(id))inclusionFilter {
    //struct kdres *nearestKDRes = kd_nearest_geo_range(tree, lat, lng, km, GEO_UNITS_KM);
    @synchronized(self) {
        struct kdres *nearestKDRes;
        
        if(inclusionFilter) {
            nearestKDRes = kd_nearest_geo_range_w_filter(tree, lat, lng, km, GEO_UNITS_KM, ^char(const void *obj) {
                return inclusionFilter((__bridge id)obj);
            });
        } else {
            nearestKDRes = kd_nearest_geo_range(tree, lat, lng, km, GEO_UNITS_KM);
        }
        
        int count = nearestKDRes != NULL ? kd_res_size(nearestKDRes) : 0;
        NSMutableArray *nearestArr = [[NSMutableArray alloc] initWithCapacity:count];
        
        while(!kd_res_end(nearestKDRes)) {
            id nearest = (__bridge id)kd_res_item_data(nearestKDRes);
            [nearestArr addObject:nearest];
            
            kd_res_next(nearestKDRes);
        }
        
        if(nearestKDRes) kd_res_free(nearestKDRes);
        
        return nearestArr;
    }
}

- (NSArray *)allValues {
    @synchronized(self) {
        NSArray *allValues = [self.itemsDict allValues];
        NSMutableArray *values = [[NSMutableArray alloc] initWithCapacity:allValues.count];
        [allValues enumerateObjectsUsingBlock:^(LocWrapper *wrapped, NSUInteger idx, BOOL *stop) {
            NSParameterAssert([wrapped isKindOfClass:[LocWrapper class]]);
            [values addObject:wrapped.obj];
        }];
        return values;
    }
}

- (void) clear {
    @synchronized(self) {
        kd_clear(tree);
    }
}


-(void)dealloc {
    kd_free(tree);
}

-(BOOL)isEmpty {
    BOOL isEmpty;
    @synchronized(self) {
        isEmpty = self.itemsDict.count <= 0;
    };
    
    return isEmpty;
}

@end
