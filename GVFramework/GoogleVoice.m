//
//  GoogleVoice.m
//  GVFramework
//
//  Created by Stuart Moore on 4/15/14.
//  Copyright (c) 2014 Stuart J. Moore. All rights reserved.
//

#import "GoogleVoice.h"

#import "GVMissedCall.h"
#import "GVVoicemail.h"
#import "GVConversation.h"
#import "GVConnection.h"

@interface GoogleVoice ()

@property (nonatomic, strong) NSString *auth, *sid, *lsid, *r;
@property (nonatomic, strong) NSOrderedSet *inbox;
@property (nonatomic, strong) NSSet *addressBook;

- (GVMessage*)messageWithId:(NSString*)identifier;
- (GVContact*)contactWithId:(NSString*)identifier;

@end

#pragma mark -

@implementation GoogleVoice

- (instancetype)init {
    self = [super init];
    if (self) {
        self.inbox = [NSOrderedSet new];
        self.addressBook = [NSSet new];
    }
    return self;
}

#pragma mark - Login

- (void)login {
    NSError *error;
    NSDictionary *dictionary = [GVConnection loginWithUsername:self.username andPassword:self.password error:&error];

    if(error) {
        NSLog(@"error: %@", error);
        return;
    }

    self.sid = dictionary[@"SID"];
    self.lsid = dictionary[@"LSID"];
    self.auth = dictionary[@"Auth"];
}

- (BOOL)isLoggedIn {
    return !!self.auth;
}

#pragma mark - Update

- (void)updateUnreadCounts {
    if(!self.isLoggedIn)
        [self login];

    NSError *error;
    NSDictionary *dictionary = [GVConnection requestJSONForUnreadCountsWithAuth:self.auth error:&error];

    if(error) {
        NSLog(@"error: %@", error);
        return;
    }

    self.r = dictionary[@"r"];
}

- (void)updateMessages {
    if(!self.isLoggedIn)
        [self login];

    NSInteger pageNum = 0;
    NSDictionary *dictionary;
    NSMutableOrderedSet *newInbox = [NSMutableOrderedSet new];

    do {
        pageNum++;

        NSError *error;
        dictionary = [GVConnection requestJSONInboxForPage:pageNum withAuth:self.auth error:&error];

        if(error) {
            NSLog(@"error: %@", error);
            return;
        }

        NSLog(@"dictionary: %@", dictionary);

        self.r = dictionary[@"r"];

        NSArray *messageList = dictionary[@"messageList"];

        for(NSDictionary *messageDict in messageList) {
            GVMessageType type = [messageDict[@"type"] integerValue];
            GVMessage *message;

            if(type == GVMessageTypeTextReceived || type == GVMessageTypeTextSent)
                message = [[GVConversation alloc] initWithJSON:messageDict];
            else if(type == GVMessageTypeMissedCall)
                message = [[GVMissedCall alloc] initWithJSON:messageDict];
            else if(type == GVMessageTypeVoicemail)
                message = [[GVVoicemail alloc] initWithJSON:messageDict];

            NSString *phoneNumber = messageDict[@"phoneNumber"];
            NSString *contactId = dictionary[@"contacts"][@"contactPhoneMap"][phoneNumber][@"contactId"];

            GVContact *contact = [self contactWithId:contactId];

            if(!contact) {
                contact = [[GVContact alloc] initWithJSON:dictionary[@"contacts"][@"contactMap"][contactId]];
                self.addressBook = [self.addressBook setByAddingObject:contact];
            }

            message.contact = contact;
            [newInbox addObject:message];
        }
    } while ([dictionary[@"totalSize"] integerValue] - pageNum * [dictionary[@"resultsPerPage"] integerValue] > 0);

    self.inbox = [NSOrderedSet orderedSetWithOrderedSet:newInbox];

    NSLog(@"addressBook: %@", self.addressBook);
    NSLog(@"inbox: %@", self.inbox);
}

#pragma mark -

- (GVMessage*)messageWithId:(NSString*)identifier {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    NSOrderedSet *filteredOrderedSet = [self.inbox filteredOrderedSetUsingPredicate:pred];

    return filteredOrderedSet.set.anyObject;
}

- (GVContact*)contactWithId:(NSString*)identifier {
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"identifier == %@", identifier];
    NSSet *filteredSet = [self.addressBook filteredSetUsingPredicate:pred];

    return filteredSet.anyObject;
}

@end
