//
//  PGCardsPokerTable.m
//  VideoPoker
//
//  Created by Paul Griffiths on 12/21/13.
//  Copyright (c) 2013 Paul Griffiths. All rights reserved.
//

#import "PGCardsPokerTable.h"
#import "PGCardsCard.h"
#import "PGCardsDeck.h"
#import "PGCardsPokerHand.h"

@implementation PGCardsPokerTable {
    PGCardsPokerHand * _hand;
    PGCardsDeck * _deck;
    BOOL _flipped[5];
}

//  Initialization methods

- (PGCardsPokerTable *)init {
    if ( (self = [super init]) ) {
        _deck = [[PGCardsDeck alloc] init];
        _hand = [[PGCardsPokerHand alloc] init];
        _gameState = POKER_GAMESTATE_INITIAL;
        [self flipCards];
    }
    
    return self;
}


//  Private methods for flipping cards

- (void)flipCard:(int)position {
    _flipped[position - 1] = YES;
}

- (void)flipCards {
    for ( int position = 1; position < 6; ++position ) {
        [self flipCard:position];
    }
}

- (void)unflipCard:(int)position {
    _flipped[position - 1] = NO;
}

- (void)unflipCards {
    for ( int position = 1; position < 6; ++position ) {
        [self unflipCard:position];
    }
}


//  Public methods for flipping cards and querying flipped status

- (BOOL)isCardFlipped:(int)position {
    return _flipped[position - 1];
}

- (void)switchCardFlip:(int)position {
    if ( [self isCardFlipped:position] ) {
        [self unflipCard:position];
    } else {
        [self flipCard:position];
    }
}

- (void)replaceFlippedCards {
    for ( int position = 1; position < 6; ++position ) {
        if ( [self isCardFlipped:position] ) {
            [_hand replaceCardAtPosition:position fromDeck:_deck];
        }
    }
}


//  Public method for getting index value of individual card

- (int)cardIndexAtPosition:(int)position {
    return [_hand cardIndexAtPosition:position];
}


//  Public method for advancing the game state

- (void)advanceGameState {
    if ( _gameState == POKER_GAMESTATE_INITIAL ) {
        [_deck shuffle];
        [_hand drawCards:5 fromDeck:_deck];
        [self unflipCards];
        
        _gameState = POKER_GAMESTATE_DEALED;
    } else if ( _gameState == POKER_GAMESTATE_DEALED ) {
        _gameState = POKER_GAMESTATE_FLIPPED;
    } else if ( _gameState == POKER_GAMESTATE_FLIPPED ) {
        [self replaceFlippedCards];
        [self unflipCards];
        [_hand evaluate];
        
        _gameState = POKER_GAMESTATE_EVALUATED;
    } else {
        [_hand discardAllCardsToDeck:_deck];
        [_deck replaceDiscards];
        [_deck shuffle];
        [_hand drawCards:5 fromDeck:_deck];

        _gameState = POKER_GAMESTATE_DEALED;
    }
}

- (NSString *)evaluationString {
    return [_hand evaluateString];
}

@end