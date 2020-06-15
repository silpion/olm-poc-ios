//
//  AliceBobTest.m
//  OlmPoc
//
//  Created by Marc Delling on 28.05.20.
//  Copyright © 2020 Silpion IT-Solutions GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OlmPoc-Bridging-Header.h"

@implementation AliceBobTest : NSObject

- (void)testAliceAndBob {
    NSError *error;

    OLMAccount *alice = [[OLMAccount alloc] initNewAccount];
    OLMAccount *bob = [[OLMAccount alloc] initNewAccount];
    [bob generateOneTimeKeys:5];
    NSDictionary *bobIdKeys = bob.identityKeys;
    NSString *bobIdKey = bobIdKeys[@"curve25519"];
    NSDictionary *bobOneTimeKeys = bob.oneTimeKeys;
    NSParameterAssert(bobIdKey != nil);
    NSParameterAssert(bobOneTimeKeys != nil);
    __block NSString *bobOneTimeKey = nil;
    NSDictionary *bobOtkCurve25519 = bobOneTimeKeys[@"curve25519"];
    [bobOtkCurve25519 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        bobOneTimeKey = obj;
    }];
    //XCTAssert([bobOneTimeKey isKindOfClass:[NSString class]]);
    
    OLMSession *aliceSession = [[OLMSession alloc] initOutboundSessionWithAccount:alice theirIdentityKey:bobIdKey theirOneTimeKey:bobOneTimeKey error:nil];
    NSString *message = @"Hello!";
    OLMMessage *aliceToBobMsg = [aliceSession encryptMessage:message error:&error];
    //XCTAssertNil(error);
    
    OLMSession *bobSession = [[OLMSession alloc] initInboundSessionWithAccount:bob oneTimeKeyMessage:aliceToBobMsg.ciphertext error:nil];
    NSString *plaintext = [bobSession decryptMessage:aliceToBobMsg error:&error];
    //XCTAssertEqualObjects(message, plaintext);
    //XCTAssertNil(error);
    NSLog(@"%@", plaintext);

    //XCTAssert([bobSession matchesInboundSession:aliceToBobMsg.ciphertext]);
    //XCTAssertFalse([aliceSession matchesInboundSession:@"ARandomOtkMessage"]);

    NSString *aliceIdKey = alice.identityKeys[@"curve25519"];
    NSLog(@"%@", aliceIdKey);
    //XCTAssert([bobSession matchesInboundSessionFrom:aliceIdKey oneTimeKeyMessage:aliceToBobMsg.ciphertext]);
    //XCTAssertFalse([bobSession matchesInboundSessionFrom:@"ARandomIdKey" oneTimeKeyMessage:aliceToBobMsg.ciphertext]);
    //XCTAssertFalse([bobSession matchesInboundSessionFrom:aliceIdKey oneTimeKeyMessage:@"ARandomOtkMessage"]);

    BOOL success = [bob removeOneTimeKeysForSession:bobSession];
    NSLog(@"%d", success);
    //XCTAssertTrue(success);
}

- (void) testBackAndForth {
    OLMAccount *alice = [[OLMAccount alloc] initNewAccount];
    OLMAccount *bob = [[OLMAccount alloc] initNewAccount];
    [bob generateOneTimeKeys:1];
    NSDictionary *bobIdKeys = bob.identityKeys;
    NSString *bobIdKey = bobIdKeys[@"curve25519"];
    NSDictionary *bobOneTimeKeys = bob.oneTimeKeys;
    NSParameterAssert(bobIdKey != nil);
    NSParameterAssert(bobOneTimeKeys != nil);
    __block NSString *bobOneTimeKey = nil;
    NSDictionary *bobOtkCurve25519 = bobOneTimeKeys[@"curve25519"];
    [bobOtkCurve25519 enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        bobOneTimeKey = obj;
    }];
    //XCTAssert([bobOneTimeKey isKindOfClass:[NSString class]]);
    
    OLMSession *aliceSession = [[OLMSession alloc] initOutboundSessionWithAccount:alice theirIdentityKey:bobIdKey theirOneTimeKey:bobOneTimeKey error:nil];
    NSString *message = @"Hello I'm Alice!";
    OLMMessage *aliceToBobMsg = [aliceSession encryptMessage:message error:nil];
    
    OLMSession *bobSession = [[OLMSession alloc] initInboundSessionWithAccount:bob oneTimeKeyMessage:aliceToBobMsg.ciphertext error:nil];
    NSString *plaintext = [bobSession decryptMessage:aliceToBobMsg error:nil];
    //XCTAssertEqualObjects(message, plaintext);
    BOOL success = [bob removeOneTimeKeysForSession:bobSession];
    //XCTAssertTrue(success);
    NSLog(@"%@ - %d", plaintext, success);
    
    NSString *msg1 = @"Hello I'm Bob!";
    NSString *msg2 = @"Isn't life grand?";
    NSString *msg3 = @"Let's go to the opera.";
    
    OLMMessage *eMsg1 = [bobSession encryptMessage:msg1 error:nil];
    OLMMessage *eMsg2 = [bobSession encryptMessage:msg2 error:nil];
    OLMMessage *eMsg3 = [bobSession encryptMessage:msg3 error:nil];
    
    NSString *dMsg1 = [aliceSession decryptMessage:eMsg1 error:nil];
    NSString *dMsg2 = [aliceSession decryptMessage:eMsg2 error:nil];
    NSString *dMsg3 = [aliceSession decryptMessage:eMsg3 error:nil];
    //XCTAssertEqualObjects(msg1, dMsg1);
    //XCTAssertEqualObjects(msg2, dMsg2);
    //XCTAssertEqualObjects(msg3, dMsg3);
    NSLog(@"%@, %@, %@", dMsg1, dMsg2, dMsg3);
    
}

@end
