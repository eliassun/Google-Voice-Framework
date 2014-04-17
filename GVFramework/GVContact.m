//
//  GVContact.m
//  GVFramework
//
//  Created by Stuart Moore on 4/15/14.
//  Copyright (c) 2014 Stuart J. Moore. All rights reserved.
//

#import "GVContact.h"
#import "GVPhone.h"

@implementation GVContact

- (instancetype)initWithJSON:(NSDictionary*)dictionary {
    self = [super init];
    if (self) {
        self.identifier = dictionary[@"contactId"];
        self.name = [self.identifier isEqualToString:@"0"]? @"Unknown" : dictionary[@"name"];
        self.photoURL = [NSURL URLWithString:dictionary[@"photoUrl"]];

        self.phones = [NSSet new];
        self.emails = [NSSet setWithArray:dictionary[@"emails"]];

        for(NSDictionary *phoneDict in dictionary[@"numbers"]) {
            GVPhone *phone = [GVPhone new];
            phone.number = phoneDict[@"phoneNumber"];
            phone.name = phoneDict[@"phoneType"];
            phone.contact = self;
            self.phones = [self.phones setByAddingObject:phone];
        }
    }
    return self;
}

- (GVPhone*)phoneWithNumber:(NSString*)number {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", number];
    NSSet *filteredSet = [self.phones filteredSetUsingPredicate:pred];

    return filteredSet.anyObject;
}

- (BOOL)isEqual:(id)object {
    if (self == object)
        return YES;

    if (![object isKindOfClass:[GVContact class]])
        return NO;

    return [self isEqualToContact:(GVContact*)object];
}

- (BOOL)isEqualToContact:(GVContact*)object {
    return [self.identifier isEqualToString:object.identifier];
}

- (NSUInteger)hash {
    return self.identifier.hash;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"%@ <%@> %@", self.name, self.identifier, self.phones];
}

@end
