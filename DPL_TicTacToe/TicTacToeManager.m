//
//  TicTakToeManager.m
//  DPL_TicTacToe
//
//  Created by Douglas Lanford on 6/25/17.
//  Copyright © 2017 Douglas Lanford. All rights reserved.
//

#import "TicTacToeManager.h"


#pragma mark ====================================
#pragma mark - Local Properties and variables

@interface TicTacToeManager() {
    TicTacToeCell* playGrid[GAME_BOARD_SIZE][GAME_BOARD_SIZE];
}

@end


#pragma mark ===========================================
#pragma mark - TicTacToeManager implementation

@implementation TicTacToeManager

#pragma mark ===========================================
#pragma mark - Initialization

- (instancetype)initWithDelegate:(id<TicTacToeManagerDelegate>)delegate {
    self = [super init];
    if (self) {
        self.delegate = delegate;
        
        self.emptyCells = [NSMutableArray<TicTacToeCell*> array];
        self.currentPlayer = TTTC_X;

        for (NSUInteger ix = 0; ix < GAME_BOARD_SIZE; ix++) {
            for (NSUInteger iy = 0; iy < GAME_BOARD_SIZE; iy++) {
                TicTacToeCell* cell = [[TicTacToeCell alloc] init];
                cell.state = TTTC_EMPTY;
                cell.posX = ix;
                cell.posY = iy;
                cell.button = [self.delegate getButtonForPositionX:ix y:iy];

                [self.emptyCells addObject:cell];
                self->playGrid[ix][iy] = cell;
            }
        }
    }
    return self;
}


#pragma mark ===========================================
#pragma mark - Public methods

- (TicTacToeCell*)getCellForButton:(UIButton*)button {
    for (NSUInteger ix = 0; ix < GAME_BOARD_SIZE; ix++) {
        for (NSInteger iy = 0; iy < GAME_BOARD_SIZE; iy++) {
            TicTacToeCell* curCell = self->playGrid[ix][iy];
            if (curCell.button == button) {
                return curCell;
            }
        }
    }
    return nil;
}


- (void)fillCellWithState:(TicTacToeCellState)state x:(NSUInteger)posX y:(NSUInteger)posY {
    if (posX > 2 || posY > 2 || (state != TTTC_X && state != TTTC_O)) {
        return;
    }

    TicTacToeCell* fillCell = self->playGrid[posX][posY];
    fillCell.state = state;
    fillCell.button.enabled = NO;
    [fillCell.button setTitle:(state == TTTC_X ? @"X" : @"O") forState:UIControlStateNormal];

    [self.emptyCells removeObject:fillCell];

    NSArray<TicTacToeCell*>* cellList = [self checkGameStatusWithNewCell:fillCell];
    if (cellList == nil) {
        self.currentPlayer = state == TTTC_X ? TTTC_O : TTTC_X;
        [self.delegate gameContinuesWithNextState:self.currentPlayer];
    }
    else if (cellList.count == GAME_BOARD_SIZE) {
        for (TicTacToeCell* cell in cellList) {
            cell.button.backgroundColor = [UIColor colorWithRed:0.0f green:0.75f blue:0.0f alpha:1.0f];
        }
        for (TicTacToeCell* cell in self.emptyCells) {
            cell.button.enabled = NO;
        }
        [self.delegate gameWinWithState:state];
    }
    else {
        for (TicTacToeCell* cell in cellList) {
            cell.button.enabled = NO;
            cell.button.backgroundColor = [UIColor colorWithRed:0.75f green:0.0f blue:0.0f alpha:1.0f];
        }
        [self.delegate gameDraw];
    }
}


- (void)doComputerSelectWithDifficulty:(float)difficulty {
    if (difficulty == 0.0f) {
        [self selectRandom];
    }
    else if (difficulty == 1.0f) {
        [self selectMinimax];
    }
    else {
        float randVal = ((float)arc4random() / (float)UINT32_MAX);
        if (randVal <= difficulty) {
            [self selectRandom];
        }
        else {
            [self selectMinimax];
        }
    }
}


#pragma mark ===========================================
#pragma mark - Private methods

//----------------------------------
// Checks the game status. This is designed to be scalable (what if the game board is larger than 3x3?).
//
// IN: the cell that was just added to the game board.
//
// returns an array of cells.
// - If nil, then game is ongoing
// - if GAME_BOARD_SIZE cells, then game was won, and the list holds the winning line of cells
// - if all cells, then game was a draw, and the list holds all cells in the game grid
//-----------------------------------
- (NSArray<TicTacToeCell*>*)checkGameStatusWithNewCell:(TicTacToeCell*)cell {
    // check horizontal win.
    BOOL win = YES;
    NSMutableArray<TicTacToeCell*>* winList = [NSMutableArray<TicTacToeCell*> arrayWithObject:cell];
    for (NSInteger ix = 0; ix < cell.posX; ix++) {
        TicTacToeCell* curCell = self->playGrid[ix][cell.posY];
        if (curCell.state != cell.state) {
            win = NO;
            break;
        }

        [winList addObject:curCell];
    }

    if (win) {
        for (NSInteger ix = cell.posX + 1; ix < GAME_BOARD_SIZE; ix++) {
            TicTacToeCell* curCell = self->playGrid[ix][cell.posY];
            if (curCell.state != cell.state) {
                win = NO;
                break;
            }

            [winList addObject:curCell];
        }
    }

    if (win) {
        return winList;
    }

    // check vertical win.
    win = YES;
    winList = [NSMutableArray<TicTacToeCell*> arrayWithObject:cell];
    for (NSInteger iy = 0; iy < cell.posY; iy++) {
        TicTacToeCell* curCell = self->playGrid[cell.posX][iy];
        if (curCell.state != cell.state) {
            win = NO;
            break;
        }

        [winList addObject:curCell];
    }

    if (win) {
        for (NSInteger iy = cell.posY + 1; iy < GAME_BOARD_SIZE; iy++) {
            TicTacToeCell* curCell = self->playGrid[cell.posX][iy];
            if (curCell.state != cell.state) {
                win = NO;
                break;
            }

            [winList addObject:curCell];
        }
    }

    if (win) {
        return winList;
    }

    // check diagonally if on a diagonal.
    if (cell.posX == cell.posY) {
        // cell is on the forward diagonal.
        win = YES;
        winList = [NSMutableArray<TicTacToeCell*> arrayWithObject:cell];
        for (NSInteger ix = 0; ix < cell.posX; ix++) {
            TicTacToeCell* curCell = self->playGrid[ix][ix];
            if (curCell.state != cell.state) {
                win = NO;
                break;
            }

            [winList addObject:curCell];
        }

        for (NSInteger ix = cell.posX + 1; ix < GAME_BOARD_SIZE; ix++) {
            TicTacToeCell* curCell = self->playGrid[ix][ix];
            if (curCell.state != cell.state) {
                win = NO;
                break;
            }

            [winList addObject:curCell];
        }

        if (win) {
            return winList;
        }
    }

    if (cell.posY == GAME_BOARD_SIZE - 1 - cell.posX) {
        // cell is on the backward diagonal
        win = YES;
        winList = [NSMutableArray<TicTacToeCell*> arrayWithObject:cell];
        for (NSInteger ix = 0; ix < cell.posX; ix++) {
            TicTacToeCell* curCell = self->playGrid[ix][GAME_BOARD_SIZE - 1 - ix];
            if (curCell.state != cell.state) {
                win = NO;
                break;
            }

            [winList addObject:curCell];
        }

        for (NSInteger ix = cell.posX + 1; ix < GAME_BOARD_SIZE; ix++) {
            TicTacToeCell* curCell = self->playGrid[ix][GAME_BOARD_SIZE - 1 - ix];
            if (curCell.state != cell.state) {
                win = NO;
                break;
            }

            [winList addObject:curCell];
        }

        if (win) {
            return winList;
        }
        
    }

    // check if all cells filled (a draw)
    if (self.emptyCells.count <= 0) {
        NSMutableArray<TicTacToeCell*>* drawCells = [NSMutableArray<TicTacToeCell*> array];
        for (NSUInteger ix = 0; ix < GAME_BOARD_SIZE; ix++) {
            for (NSInteger iy = 0; iy < GAME_BOARD_SIZE; iy++) {
                [drawCells addObject:self->playGrid[ix][iy]];
            }
        }
        return drawCells;
    }

    // No win or draw, game is ongoing.
    return nil;
}


- (void)selectRandom {
    NSUInteger randVal = arc4random_uniform((uint32_t)self.emptyCells.count);
    TicTacToeCell* randCell = [self.emptyCells objectAtIndex:randVal];
    [self fillCellWithState:self.currentPlayer x:randCell.posX y:randCell.posY];
}


- (void)selectMinimax {
    // TODO: implement the Minimax recursive algorithm for Tic Tac Toe.
    // Until then, use the random....
    [self selectRandom];
}

@end
