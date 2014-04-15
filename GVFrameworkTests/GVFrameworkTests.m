//
//  GVFrameworkTests.m
//  GVFrameworkTests
//
//  Created by Stuart Moore on 4/15/14.
//  Copyright (c) 2014 Stuart J. Moore. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <GVFramework/GVUser.h>

@interface GVFrameworkTests : XCTestCase

@property (nonatomic, strong) GVUser *user;

@end

@implementation GVFrameworkTests

- (void)setUp
{
    [super setUp];

    NSString *credsFilepath = [[NSBundle bundleForClass:self.class] pathForResource:@"Creds" ofType:@"plist"];
    NSDictionary *creds = [NSDictionary dictionaryWithContentsOfFile:credsFilepath];

    self.user = [GVUser new];
    self.user.username = creds[@"username"];
    self.user.password = creds[@"password"];
}

- (void)testUnreadCounts
{
    if(!self.user.isLoggedIn)
        [self.user login];

    [self.user updateUnreadCounts];
}

- (void)testMessages
{
    if(!self.user.isLoggedIn)
        [self.user login];

    [self.user updateMessages];
}

- (void)tearDown
{
    [super tearDown];
}

@end
