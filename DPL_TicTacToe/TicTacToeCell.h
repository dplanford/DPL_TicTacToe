//
//  TicTacToeCell.h
//  DPL_TicTacToe
//
//  Created by Douglas Lanford on 6/25/17.
//  Copyright © 2017 Douglas Lanford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define GAME_BOARD_SIZE 3

typedef enum {
    TTTC_EMPTY,
    TTTC_X,
    TTTC_O
} TicTacToeCellState;


@interface TicTacToeCell : NSObject

@property (nonatomic, assign) TicTacToeCellState state;
@property (nonatomic, assign) NSUInteger posX;
@property (nonatomic, assign) NSUInteger posY;
@property (nonatomic, assign) UIButton* button;

@end
