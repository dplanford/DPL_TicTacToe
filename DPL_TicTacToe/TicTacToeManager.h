//
//  TicTakToeManager.h
//  DPL_TicTacToe
//
//  Created by Douglas Lanford on 6/25/17.
//  Copyright © 2017 Douglas Lanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#include "TicTacToeCell.h"

typedef enum {
    TTTM_1_PLAYER,  // 1 player against the computer
    TTTM_2_PLAYER,  // 2 players
    TTTM_NO_PLAYER  // computer plays itself
} TicTacToePlayState;


@protocol TicTacToeManagerDelegate <NSObject>

- (void)gameWinWithState:(TicTacToeCellState)state;
- (void)gameDraw;
- (void)gameContinuesWithNextState:(TicTacToeCellState)state;

- (UIButton*)getButtonForPositionX:(NSUInteger)posX y:(NSUInteger)posY;

@end


@interface TicTacToeManager : NSObject

@property (nonatomic, retain) id<TicTacToeManagerDelegate> delegate;

@property (nonatomic, retain) NSMutableArray<TicTacToeCell*>* emptyCells;
@property (nonatomic, assign) TicTacToeCellState currentPlayer;

- (instancetype)initWithDelegate:(id<TicTacToeManagerDelegate>)delegate;

- (TicTacToeCell*)getCellForButton:(UIButton*)button;

- (void)fillCellWithState:(TicTacToeCellState)state x:(NSUInteger)posX y:(NSUInteger)posY;

- (void)doComputerSelectWithDifficulty:(float)difficulty;

@end
